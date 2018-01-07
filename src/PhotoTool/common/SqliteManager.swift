//
//  SqliteManager.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2017/12/31.
//  Copyright © 2017年 YingHui Jiang. All rights reserved.
//

import Foundation

class SqliteManager: NSObject {
    private static let manager: SqliteManager = SqliteManager()
    //单例
    class func shareManager() -> SqliteManager{
        return manager
    }
    
    //数据库对象
    private var db: OpaquePointer? = nil
    func openDB() -> Bool{
        let path = NSHomeDirectory() + "/Documents/PhotoTool.sqlite"
        
        let cPath = path.cString(using: String.Encoding.utf8)
        if  sqlite3_open(cPath, &db) != SQLITE_OK{
            print("数据库打开失败")
            return false
        }
        return true
//        if creatTable(){
//            print("创建表成功")
//        } else {
//            print("创建表失败")
//        }
    }
    
    // 创建表
    func creatTable(name: String, params: String) -> Bool {
        //        CREATE TABLE customer (First_Name char(50), Last_Name char(50), Address char(50),
//        City char(50), Country char(25), Birth_Date date)
        let sql = "CREATE TABLE IF NOT EXISTS \(name)( \(params) ); \n"
        return execSQL(sql: sql)
    }
    
//    func getAllTable() -> Bool {
//        let sql = "SELECT name FROM sys.sysobjects WHERE TYPE='U'"
//        return execSQL(sql: sql)
//    }
    
    // 添加数据
    func insert(tableName: String, params: String, values: String) -> Bool {
//        INSERT INTO Store_Information (store_name, Sales, Date) VALUES ('Los Angeles', 900, 'Jan-10-1999')
        let sql = "INSERT INTO \(tableName) (\(params)) VALUES (\(values))"
        return execSQL(sql: sql)
    }
    
    // 修改数据
    func update(tableName: String, params: String, filter: String) -> Bool {
        let sql = "UPDATE \(tableName) Set (\(params)) WHERE (\(filter))"
        return execSQL(sql: sql)
    }
    
    // 删除数据
    func delete(tableName: String, filter: String) -> Bool {
        let sql = "DELETE FROM \(tableName) WHERE (\(filter))"
        return execSQL(sql: sql)
    }
    
    // 查询数据
    func select(tableName: String, filter: String?) -> Bool {
        var sql = "SELECT name FROM \(tableName)"
        if let filterT = filter {
            sql = sql + "WHERE" + "(\(filterT))"
        }
        return execSQL(sql: sql)
    }
    
    func execSQL(sql: String) -> Bool {
        // 0.将Swift字符串转换为C语言字符串
        let cSQL = sql.cString(using: String.Encoding.utf8)!
        
        // 在SQLite3中, 除了查询意外(创建/删除/新增/更新)都使用同一个函数
        /*
         1. 已经打开的数据库对象
         2. 需要执行的SQL语句, C语言字符串
         3. 执行SQL语句之后的回调, 一般传nil
         4. 是第三个参数的第一个参数, 一般传nil
         5. 错误信息, 一般传nil
         */
        if sqlite3_exec(db, cSQL, nil, nil, nil) != SQLITE_OK {
            print("数据库执行语句\(sql)错误")
            return false
        }
            return true
    }
}

class PhotoDBManager: NSObject {
    fileprivate let tableName = "Photo"
    static let share: PhotoDBManager = PhotoDBManager()
    fileprivate let sqliteMg = SqliteManager.shareManager()
    
    fileprivate lazy var params: String = {
        let pros = Tools.getPropertyList(model: PhotoModel())
        var str = ""
        for e in pros {
            str += "\(e),"
        }
        str.removeLast()
        return str
    }()
    
    func initDB() -> Bool {
        let sql = "id INTEGER PRIMARY KEY AUTOINCREMENT, \n" +
                  "name TEXT, \n" +
                  "defaultName TEXT, \n" +
                  "addr TEXT, \n" +
                  "pose TEXT \n"
        
        if sqliteMg.openDB() && sqliteMg.creatTable(name: tableName, params: sql) {
            return true
        }
        return false
    }
    
    func addImg(ary: [PhotoModel]) {
        let v = Tools.getValueList(model: PhotoModel())
        guard let str = changeValueToSqlStr(values: v) else { return }
        
        sqliteMg.insert(tableName: tableName, params: params, values: str)
    }
    
    fileprivate func changeValueToSqlStr(values: [Any?]) -> String? {
        var sqlStr = ""
        
        for v in values {
            if let str = v as? String {
                sqlStr += "'\(str)',"
            } else if let i = v as? Int {
                sqlStr += "\(i),"
            }
        }
        sqlStr.removeLast()
        return sqlStr
    }
    
    func selectAll() -> [PhotoModel]? {
        sqliteMg.select(tableName: tableName, filter: nil)
        return nil
    }
}
