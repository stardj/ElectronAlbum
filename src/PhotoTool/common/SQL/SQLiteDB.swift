//
//  SQLiteDB.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/3.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//

import Foundation

let SQLITE_DATE = SQLITE_NULL + 1

private let SQLITE_STATIC = unsafeBitCast(0, to:sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to:sqlite3_destructor_type.self)

// MARK:- SQLiteDB Class
/// Simple wrapper class to provide basic SQLite database access.
@objc(SQLiteDB)
class SQLiteDB:NSObject {
    /// The SQLite database file name - defaults to `data.db`.
    var DB_NAME = "data.db"
    /// Singleton instance for access to the SQLiteDB class
    static let shared = SQLiteDB()
    /// Internal name for GCD queue used to execute SQL commands so that all commands are executed sequentially
    private let QUEUE_LABEL = "SQLiteDB"
    /// The internal GCD queue
    private var queue:DispatchQueue!
    /// Internal handle to the currently open SQLite DB instance
    private var db:OpaquePointer? = nil
    /// Internal DateFormatter instance used to manage date formatting
    private let fmt = DateFormatter()
    /// Internal reference to the currently open database path
    private var path:String!
    
    private override init() {
        super.init()
        // Set up essentials
        queue = DispatchQueue(label:QUEUE_LABEL, attributes:[])
        // You need to set the locale in order for the 24-hour date format to work correctly on devices where 24-hour format is turned off
        fmt.locale = Locale(identifier:"en_US_POSIX")
        fmt.timeZone = TimeZone(secondsFromGMT:0)
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    deinit {
        closeDB()
    }
    
    /// Output the current SQLite database path
    override var description:String {
        return "SQLiteDB: \(path)"
    }
    
    // MARK:- Public Methods
    /// Open the database specified by the `DB_NAME` variable and assigns the internal DB references. If a database is currently open, the method first closes the current database and gets a new DB references to the current database pointed to by `DB_NAME`
    ///
    /// - Parameter copyFile: Whether to copy the file named in `DB_NAME` from resources or to create a new empty database file. Defaults to `true`
    /// - Returns: Returns a boolean value indicating if the database was successfully opened or not.
    func openDB(copyFile:Bool = true) -> Bool {
        if db != nil {
            closeDB()
        }
        // Set up for file operations
        let fm = FileManager.default
        // Get path to DB in Documents directory
        var docDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        // If macOS, add app name to path since otherwise, DB could possibly interfere with another app using SQLiteDB
        #if os(OSX)
            let info = Bundle.main.infoDictionary!
            let appName = info["CFBundleName"] as! String
            docDir = (docDir as NSString).appendingPathComponent(appName)
            // Create folder if it does not exist
            if !fm.fileExists(atPath:docDir) {
                do {
                    try fm.createDirectory(atPath:docDir, withIntermediateDirectories:true, attributes:nil)
                } catch {
                    assert(false, "SQLiteDB: Error creating DB directory: \(docDir) on macOS")
                    return false
                }
            }
        #endif
        let path = (docDir as NSString).appendingPathComponent(DB_NAME)
        // Check if DB is there in Documents directory
        if !(fm.fileExists(atPath:path)) && copyFile {
            // The database does not exist, so copy it
            guard let rp = Bundle.main.resourcePath else { return false }
            let from = (rp as NSString).appendingPathComponent(DB_NAME)
            do {
                try fm.copyItem(atPath:from, toPath:path)
            } catch let error {
                assert(false, "SQLiteDB: Failed to copy writable version of DB! Error - \(error.localizedDescription)")
                return false
            }
        }
        // Open the DB
        let cpath = path.cString(using:String.Encoding.utf8)
        let error = sqlite3_open(cpath!, &db)
        if error != SQLITE_OK {
            // Open failed, close DB and fail
            NSLog("SQLiteDB - failed to open DB!")
            sqlite3_close(db)
            return false
        }
        NSLog("SQLiteDB opened!")
        return true
    }
    
    /// Returns an ISO-8601 date string for a given date.
    ///
    /// - Parameter date: The date to format in to an ISO-8601 string
    /// - Returns: A string with the date in ISO-8601 format.
    func dbDate(date:Date) -> String {
        return fmt.string(from:date)
    }
    
    /// Execute SQL (non-query) command with (optional) parameters and return result code
    ///
    /// - Parameters:
    ///   - sql: The SQL statement to be executed
    ///   - parameters: An array of optional parameters in case the SQL statement includes bound parameters - indicated by `?`
    /// - Returns: The ID for the last inserted row (if it was an INSERT command and the ID is an integer column) or a result code indicating the status of the command execution. A non-zero result indicates success and a 0 indicates failure.
    func execute(sql:String, parameters:[Any]? = nil)->Int {
        assert(db != nil, "Database has not been opened! Use the openDB() method before any DB queries.")
        var result = 0
        queue.sync {
            if let stmt = self.prepare(sql:sql, params:parameters) {
                result = self.execute(stmt:stmt, sql:sql)
            }
        }
        return result
    }
    
    /// Run an SQL query with (parameters) parameters and returns an array of dictionaries where the keys are the column names
    ///
    /// - Parameters:
    ///   - sql: The SQL query to be executed
    ///   - parameters: An array of optional parameters in case the SQL statement includes bound parameters - indicated by `?`
    /// - Returns: An empty array if the query resulted in no rows. Otherwise, an array of dictionaries where each dictioanry key is a column name and the value is the column value.
    func query(sql:String, parameters:[Any]? = nil)->[[String:Any]] {
        assert(db != nil, "Database has not been opened! Use the openDB() method before any DB queries.")
        var rows = [[String:Any]]()
        queue.sync {
            if let stmt = self.prepare(sql:sql, params:parameters) {
                rows = self.query(stmt:stmt, sql:sql)
            }
        }
        return rows
    }
    
    /// Get the current internal DB version
    ///
    /// - Returns: An interger indicating the current internal DB version as set by the developer via code. If a DB version was not set, this defaults to 0.
    func getDBVersion() -> Int {
        assert(db != nil, "Database has not been opened! Use the openDB() method before any DB queries.")
        var version = 0
        let arr = query(sql:"PRAGMA user_version")
        if arr.count == 1 {
            version = arr[0]["user_version"] as! Int
        }
        return version
    }
    
    /// Set the current DB version, a user-defined version number for the database. This value can be useful in managing data migrations so that you can add new columns to your tables or massage your existing data to suit a new situation.
    ///
    /// - Parameter version: An integer value indicating the new DB version.
    func set(version:Int) {
        assert(db != nil, "Database has not been opened! Use the openDB() method before any DB queries.")
        _ = execute(sql:"PRAGMA user_version=\(version)")
    }
    
    // MARK:- Private Methods
    /// Close the currently open SQLite database. Before closing the DB, the framework automatically takes care of optimizing the DB at frequent intervals by running the following commands:
    /// 1. **VACUUM** - Repack the DB to take advantage of deleted data
    /// 2. **ANALYZE** - Gather information about the tables and indices so that the query optimizer can use the information to make queries work better.
    private func closeDB() {
        if db != nil {
            // Get launch count value
            let ud = UserDefaults.standard
            var launchCount = ud.integer(forKey:"LaunchCount")
            launchCount -= 1
            NSLog("SQLiteDB - Launch count \(launchCount)")
            var clean = false
            if launchCount < 0 {
                clean = true
                launchCount = 500
            }
            ud.set(launchCount, forKey:"LaunchCount")
            ud.synchronize()
            // Do we clean DB?
            if !clean {
                sqlite3_close(db)
                return
            }
            // Clean DB
            NSLog("SQLiteDB - Optimize DB")
            let sql = "VACUUM; ANALYZE"
            if CInt(execute(sql:sql)) != SQLITE_OK {
                NSLog("SQLiteDB - Error cleaning DB")
            }
            sqlite3_close(db)
            self.db = nil
        }
    }
    
    /// Private method to prepare an SQL statement before executing it.
    ///
    /// - Parameters:
    ///   - sql: The SQL query or command to be prepared.
    ///   - params: An array of optional parameters in case the SQL statement includes bound parameters - indicated by `?`
    /// - Returns: A pointer to a finalized SQLite statement that can be used to execute the query later
    private func prepare(sql:String, params:[Any]?) -> OpaquePointer? {
        var stmt:OpaquePointer? = nil
        let cSql = sql.cString(using: String.Encoding.utf8)
        // Prepare
        let result = sqlite3_prepare_v2(self.db, cSql!, -1, &stmt, nil)
        if result != SQLITE_OK {
            sqlite3_finalize(stmt)
            if let error = String(validatingUTF8:sqlite3_errmsg(self.db)) {
                let msg = "SQLiteDB - failed to prepare SQL: \(sql), Error: \(error)"
                NSLog(msg)
            }
            return nil
        }
        // Bind parameters, if any
        if params != nil {
            // Validate parameters
            let cntParams = sqlite3_bind_parameter_count(stmt)
            let cnt = params!.count
            if cntParams != CInt(cnt) {
                let msg = "SQLiteDB - failed to bind parameters, counts did not match. SQL: \(sql), Parameters: \(params!)"
                NSLog(msg)
                return nil
            }
            var flag:CInt = 0
            // Text & BLOB values passed to a C-API do not work correctly if they are not marked as transient.
            for ndx in 1...cnt {
                //                NSLog("Binding: \(params![ndx-1]) at Index: \(ndx)")
                // Check for data types
                if let txt = params![ndx-1] as? String {
                    flag = sqlite3_bind_text(stmt, CInt(ndx), txt, -1, SQLITE_TRANSIENT)
                } else if let data = params![ndx-1] as? NSData {
                    flag = sqlite3_bind_blob(stmt, CInt(ndx), data.bytes, CInt(data.length), SQLITE_TRANSIENT)
                } else if let date = params![ndx-1] as? Date {
                    let txt = fmt.string(from:date)
                    flag = sqlite3_bind_text(stmt, CInt(ndx), txt, -1, SQLITE_TRANSIENT)
                } else if let val = params![ndx-1] as? Bool {
                    let num = val ? 1 : 0
                    flag = sqlite3_bind_int(stmt, CInt(ndx), CInt(num))
                } else if let val = params![ndx-1] as? Double {
                    flag = sqlite3_bind_double(stmt, CInt(ndx), CDouble(val))
                } else if let val = params![ndx-1] as? Int {
                    flag = sqlite3_bind_int(stmt, CInt(ndx), CInt(val))
                } else {
                    flag = sqlite3_bind_null(stmt, CInt(ndx))
                }
                // Check for errors
                if flag != SQLITE_OK {
                    sqlite3_finalize(stmt)
                    if let error = String(validatingUTF8:sqlite3_errmsg(self.db)) {
                        let msg = "SQLiteDB - failed to bind for SQL: \(sql), Parameters: \(params!), Index: \(ndx) Error: \(error)"
                        NSLog(msg)
                    }
                    return nil
                }
            }
        }
        return stmt
    }
    
    /// Private method which handles the actual execution of an SQL statement which had been prepared previously.
    ///
    /// - Parameters:
    ///   - stmt: The previously prepared SQLite statement
    ///   - sql: The SQL command to be excecuted
    /// - Returns: The ID for the last inserted row (if it was an INSERT command and the ID is an integer column) or a result code indicating the status of the command execution. A non-zero result indicates success and a 0 indicates failure.
    private func execute(stmt:OpaquePointer, sql:String)->Int {
        // Step
        let res = sqlite3_step(stmt)
        if res != SQLITE_OK && res != SQLITE_DONE {
            sqlite3_finalize(stmt)
            if let error = String(validatingUTF8:sqlite3_errmsg(self.db)) {
                let msg = "SQLiteDB - failed to execute SQL: \(sql), Error: \(error)"
                NSLog(msg)
            }
            return 0
        }
        // Is this an insert
        let upp = sql.uppercased()
        var result = 0
        if upp.hasPrefix("INSERT ") {
            // Known limitations: http://www.sqlite.org/c3ref/last_insert_rowid.html
            let rid = sqlite3_last_insert_rowid(self.db)
            result = Int(rid)
        } else if upp.hasPrefix("DELETE") || upp.hasPrefix("UPDATE") {
            var cnt = sqlite3_changes(self.db)
            if cnt == 0 {
                cnt += 1
            }
            result = Int(cnt)
        } else {
            result = 1
        }
        // Finalize
        sqlite3_finalize(stmt)
        return result
    }
    
    /// Private method which handles the actual execution of an SQL query which had been prepared previously.
    ///
    /// - Parameters:
    ///   - stmt: The previously prepared SQLite statement
    ///   - sql: The SQL query to be run
    /// - Returns: An empty array if the query resulted in no rows. Otherwise, an array of dictionaries where each dictioanry key is a column name and the value is the column value.
    private func query(stmt:OpaquePointer, sql:String)->[[String:Any]] {
        var rows = [[String:Any]]()
        var fetchColumnInfo = true
        var columnCount:CInt = 0
        var columnNames = [String]()
        var columnTypes = [CInt]()
        var result = sqlite3_step(stmt)
        while result == SQLITE_ROW {
            // Should we get column info?
            if fetchColumnInfo {
                columnCount = sqlite3_column_count(stmt)
                for index in 0..<columnCount {
                    // Get column name
                    let name = sqlite3_column_name(stmt, index)
                    columnNames.append(String(validatingUTF8:name!)!)
                    // Get column type
                    columnTypes.append(self.getColumnType(index:index, stmt:stmt))
                }
                fetchColumnInfo = false
            }
            // Get row data for each column
            var row = [String:Any]()
            for index in 0..<columnCount {
                let key = columnNames[Int(index)]
                let type = columnTypes[Int(index)]
                if let val = getColumnValue(index:index, type:type, stmt:stmt) {
                    //                        NSLog("Column type:\(type) with value:\(val)")
                    row[key] = val
                }
            }
            rows.append(row)
            // Next row
            result = sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        return rows
    }
    
    /// Private method that returns the declared SQLite data type for a specific column in a pre-prepared SQLite statement.
    ///
    /// - Parameters:
    ///   - index: The 0-based index of the column
    ///   - stmt: The previously prepared SQLite statement
    /// - Returns: A CInt value indicating the SQLite data type
    private func getColumnType(index:CInt, stmt:OpaquePointer)->CInt {
        var type:CInt = 0
        // Column types - http://www.sqlite.org/datatype3.html (section 2.2 table column 1)
        let blobTypes = ["BINARY", "BLOB", "VARBINARY"]
        let charTypes = ["CHAR", "CHARACTER", "CLOB", "NATIONAL VARYING CHARACTER", "NATIVE CHARACTER", "NCHAR", "NVARCHAR", "TEXT", "VARCHAR", "VARIANT", "VARYING CHARACTER"]
        let dateTypes = ["DATE", "DATETIME", "TIME", "TIMESTAMP"]
        let intTypes  = ["BIGINT", "BIT", "BOOL", "BOOLEAN", "INT", "INT2", "INT8", "INTEGER", "MEDIUMINT", "SMALLINT", "TINYINT"]
        let nullTypes = ["NULL"]
        let realTypes = ["DECIMAL", "DOUBLE", "DOUBLE PRECISION", "FLOAT", "NUMERIC", "REAL"]
        // Determine type of column - http://www.sqlite.org/c3ref/c_blob.html
        let buf = sqlite3_column_decltype(stmt, index)
        //        NSLog("SQLiteDB - Got column type: \(buf)")
        if buf != nil {
            var tmp = String(validatingUTF8:buf!)!.uppercased()
            // Remove bracketed section
            if let pos = tmp.range(of:"(") {
                tmp = String(tmp[..<pos.lowerBound])
            }
            // Remove unsigned?
            // Remove spaces
            // Is the data type in any of the pre-set values?
            //            NSLog("SQLiteDB - Cleaned up column type: \(tmp)")
            if intTypes.contains(tmp) {
                return SQLITE_INTEGER
            }
            if realTypes.contains(tmp) {
                return SQLITE_FLOAT
            }
            if charTypes.contains(tmp) {
                return SQLITE_TEXT
            }
            if blobTypes.contains(tmp) {
                return SQLITE_BLOB
            }
            if nullTypes.contains(tmp) {
                return SQLITE_NULL
            }
            if dateTypes.contains(tmp) {
                return SQLITE_DATE
            }
            return SQLITE_TEXT
        } else {
            // For expressions and sub-queries
            type = sqlite3_column_type(stmt, index)
        }
        return type
    }
    
    // Get column value
    /// Private method to return the column value for a specified SQLite column.
    ///
    /// - Parameters:
    ///   - index: The 0-based index of the column
    ///   - type: The declared SQLite data type for the column
    ///   - stmt: The previously prepared SQLite statement
    /// - Returns: A value for the column if the data is of a recognized SQLite data type, or nil if the value was NULL
    private func getColumnValue(index:CInt, type:CInt, stmt:OpaquePointer)->Any? {
        // Integer
        if type == SQLITE_INTEGER {
            let val = sqlite3_column_int(stmt, index)
            return Int(val)
        }
        // Float
        if type == SQLITE_FLOAT {
            let val = sqlite3_column_double(stmt, index)
            return Double(val)
        }
        // Text - handled by default handler at end
        // Blob
        if type == SQLITE_BLOB {
            let data = sqlite3_column_blob(stmt, index)
            let size = sqlite3_column_bytes(stmt, index)
            let val = NSData(bytes:data, length:Int(size))
            return val
        }
        // Null
        if type == SQLITE_NULL {
            return nil
        }
        // Date
        if type == SQLITE_DATE {
            // Is this a text date
            if let ptr = UnsafeRawPointer.init(sqlite3_column_text(stmt, index)) {
                let uptr = ptr.bindMemory(to:CChar.self, capacity:0)
                let txt = String(validatingUTF8:uptr)!
                let set = CharacterSet(charactersIn:"-:")
                if txt.rangeOfCharacter(from:set) != nil {
                    // Convert to time
                    var time:tm = tm(tm_sec: 0, tm_min: 0, tm_hour: 0, tm_mday: 0, tm_mon: 0, tm_year: 0, tm_wday: 0, tm_yday: 0, tm_isdst: 0, tm_gmtoff: 0, tm_zone:nil)
                    strptime(txt, "%Y-%m-%d %H:%M:%S", &time)
                    time.tm_isdst = -1
                    let diff = TimeZone.current.secondsFromGMT()
                    let t = mktime(&time) + diff
                    let ti = TimeInterval(t)
                    let val = Date(timeIntervalSince1970:ti)
                    return val
                }
            }
            // If not a text date, then it's a time interval
            let val = sqlite3_column_double(stmt, index)
            let dt = Date(timeIntervalSince1970: val)
            return dt
        }
        // If nothing works, return a string representation
        if let ptr = UnsafeRawPointer.init(sqlite3_column_text(stmt, index)) {
            let uptr = ptr.bindMemory(to:CChar.self, capacity:0)
            let txt = String(validatingUTF8:uptr)
            return txt
        }
        return nil
    }
}
