//
//  PhotoPresentAnimator.swift
//  PhotoTool
//
//  Created by  YH_Jiang L_Zhang ZMX_Wang on 2017/12/16.
//  Copyright © 2017 year  YH_Jiang L_Zhang ZMX_Wang. All rights reserved.
//

import UIKit
import Foundation

class YHJPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    /// Custom pop-up animation
    ///
    /// - Parameters:
    ///   - timeStamp: photoId
    ///   - isThumbnail: is thumbnail
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let presentView = transitionContext.view(forKey: .to)
        transitionContext.containerView.addSubview(presentView!)
        
        presentView?.backgroundColor = UIColor.black
        
        UIView.animate(withDuration: 0.2, animations: {
            presentView?.alpha = 1
        }, completion: { finished in
            transitionContext.completeTransition(true)
        })
    }
}

class YHJDismissAnimator: NSObject,  UIViewControllerAnimatedTransitioning{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    ///  Custom dismiss animation
    ///
    /// - Parameters:
    ///   - timeStamp: photoId
    ///   - isThumbnail: is thumbnail
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: .from)
        
        UIView.animate(withDuration: 0.2, animations: {
            fromView!.alpha = 0
        }, completion: { finished in
            transitionContext.completeTransition(true)
        })
    }
}
