//
//  PhotoPresentAnimator.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2017/12/16.
//  Copyright © 2017年 YingHui Jiang. All rights reserved.
//

import UIKit
import Foundation

class YHJPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    /// 自定义弹出动画
    ///
    /// - Parameters:
    ///   - timeStamp: photoId
    ///   - isThumbnail: 是否是缩略图
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
    
    /// 自定义dismiss动画
    ///
    /// - Parameters:
    ///   - timeStamp: photoId
    ///   - isThumbnail: 是否是缩略图
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: .from)
        
        UIView.animate(withDuration: 0.2, animations: {
            fromView!.alpha = 0
        }, completion: { finished in
            transitionContext.completeTransition(true)
        })
    }
}
