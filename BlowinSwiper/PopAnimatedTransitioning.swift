//
//  PopAnimatedTransitioning.swift
//  BlowinSwiper
//
//  Created by Takuma Horiuchi on 2018/02/06.
//  Copyright © 2018年 Takuma Horiuchi. All rights reserved.
//

import UIKit

public final class PopAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    private struct Const {
        static let toViewTransitionRatio: CGFloat = 0.3
        static let titleViewTransitionRatio: CGFloat = 0.52
        static let normalTransitionDuration = 0.3
        static let interactivePopTransitionDuration = 0.5
    }

    private var isInteractivePop = false

    public init(isInteractivePop: Bool) {
        super.init()
        self.isInteractivePop = isInteractivePop
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isInteractivePop ? Const.interactivePopTransitionDuration : Const.normalTransitionDuration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        let containerView = transitionContext.containerView
        let toViewWidth = toViewController.view.bounds.width
        let fromVCTitleView = fromViewController.navigationItem.titleView

        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        toViewController.view.frame.origin.x = -toViewWidth * Const.toViewTransitionRatio

        /// When hidesBottomBarWhenPushed = true
        /// and ToolBar to TabBar, adjust origin.
        var isAnimatedToTabBar = false
        if let toTabBar = toViewController.tabBarController?.tabBar {
            isAnimatedToTabBar = toTabBar.frame.origin.x < CGFloat(0) ? true : false
            if isAnimatedToTabBar {
                toTabBar.frame.origin.x = -toViewWidth * Const.toViewTransitionRatio
                containerView.insertSubview(toTabBar, belowSubview: fromViewController.view)
            }
        }

        let shadowView = makeShadowView(frame: fromViewController.view.frame)
        containerView.insertSubview(shadowView, belowSubview: fromViewController.view)

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: isInteractivePop ? .curveLinear : .curveEaseOut,
                       animations: {
            toViewController.view.frame.origin.x = 0
            isAnimatedToTabBar ? toViewController.tabBarController?.tabBar.frame.origin.x = 0 : nil

            shadowView.frame.origin.x = toViewWidth
            shadowView.alpha = 0

            fromViewController.view.frame.origin.x = toViewWidth
            fromVCTitleView?.frame.origin.x = toViewWidth * Const.titleViewTransitionRatio
        }) { _ in
            shadowView.removeFromSuperview()
            /// When hidesBottomBarWhenPushed = true
            /// Because containerView on tabBar
            if let tabBarController = toViewController.tabBarController {
                isAnimatedToTabBar ? tabBarController.view.addSubview(tabBarController.tabBar) : nil
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    private func makeShadowView(frame: CGRect) -> UIView {
        let view = UIView(frame: frame)
        view.layer.backgroundColor = UIColor.black.cgColor
        view.layer.shadowOffset.width = -3
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 8
        return view
    }
}
