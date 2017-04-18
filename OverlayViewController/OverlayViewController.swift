//
//  OverlayViewController.swift
//  OverlayViewController
//
//  Created by Andrey Gordeev on 4/17/17.
//  Copyright © 2017 Andrey Gordeev (andrew8712@gmail.com). All rights reserved.
//

import UIKit

protocol OverlayHost {
    func showOverlay<T: OverlayViewController>(type: T.Type, fromStoryboardWithName storyboardName: String) -> T?
    func showOverlay<T: OverlayViewController>(identifier: String, fromStoryboardWithName storyboardName: String) -> T?
}

extension OverlayHost where Self: UIViewController {
    @discardableResult
    func showOverlay<T: OverlayViewController>(type: T.Type, fromStoryboardWithName storyboardName: String) -> T? {
        let identifier = String(describing: T.self)
        return showOverlay(identifier: identifier, fromStoryboardWithName: storyboardName)
    }

    @discardableResult
    func showOverlay<T: OverlayViewController>(identifier: String, fromStoryboardWithName storyboardName: String) -> T? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let overlay = storyboard.instantiateViewController(withIdentifier: identifier) as? T else { return nil }
        overlay.presentOverlay(from: self)
        return overlay
    }
}

protocol OverlayViewController: class {
    var overlaySize: CGSize? { get }
    func presentOverlay(from parentViewController: UIViewController)
    func dismissOverlay()
}

extension OverlayViewController where Self: UIViewController {
    var overlaySize: CGSize? {
        return nil
    }
    /// Just a random number. We use this to access blackOverlayView later after we've added it.
    private var blackOverlayViewTag: Int {
        return 392895
    }

    /// Presents the current view controller as an overlay on a given parent view controller.
    ///
    /// - Parameter parentViewController: The parent view controller.
    func presentOverlay(from parentViewController: UIViewController) {
        // Dim out background.
        let parentBounds = parentViewController.view.bounds
        let blackOverlayView = UIView()
        blackOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        blackOverlayView.frame = parentBounds
        blackOverlayView.alpha = 0.0
        blackOverlayView.isUserInteractionEnabled = true
        blackOverlayView.tag = blackOverlayViewTag
        parentViewController.view.addSubview(blackOverlayView)

        let containerView = UIView()
        if let overlaySize = overlaySize {
            // The user has provided the overlaySize.
            let x = (parentBounds.width - overlaySize.width) * 0.5
            let y = (parentBounds.height - overlaySize.height) * 0.5
            containerView.frame = CGRect(x: x, y: y, width: overlaySize.width, height: overlaySize.height)
        } else {
            // No overlaySize provided. By default we have small paddings at every edge.
            containerView.frame = parentBounds.insetBy(dx: parentBounds.width*0.05,
                                                       dy: parentBounds.height*0.05)
        }

        // Adding a shadow.
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowRadius = 10.0
        containerView.layer.shadowOpacity = 0.4
        containerView.layer.shadowOffset = CGSize.zero

        parentViewController.view.addSubview(containerView)

        // Round corners.
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = false

        // Adding to the parent view controller.
        parentViewController.addChildViewController(self)
        containerView.addSubview(self.view)
        // Fit into the container view.
        constraintViewEqual(view1: containerView, view2: self.view)
        self.didMove(toParentViewController: parentViewController)

        // Fade the overlay view in.
        containerView.alpha = 0.0
        containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.3) {
            containerView.alpha = 1.0
            containerView.transform = .identity
            blackOverlayView.alpha = 1.0
        }
    }

    /// Removes the current view controller from the parent view controller with animation.
    func dismissOverlay() {
        guard let containerView = view.superview else { return }
        let blackOverlayView = containerView.superview?.viewWithTag(blackOverlayViewTag)
        UIView.animate(withDuration: 0.3, animations: {
            blackOverlayView?.alpha = 0.0
            containerView.alpha = 0.0
            containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            self.removeFromParentViewController()
            containerView.removeFromSuperview()
            blackOverlayView?.removeFromSuperview()
        }
    }

    /// Sticks child view (view1) to the parent view (view2) using constraints.
    private func constraintViewEqual(view1: UIView, view2: UIView) {
        view2.translatesAutoresizingMaskIntoConstraints = false
        let constraint1 = NSLayoutConstraint(item: view1, attribute: .top, relatedBy: .equal, toItem: view2, attribute: .top, multiplier: 1.0, constant: 0.0)
        let constraint2 = NSLayoutConstraint(item: view1, attribute: .trailing, relatedBy: .equal, toItem: view2, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        let constraint3 = NSLayoutConstraint(item: view1, attribute: .bottom, relatedBy: .equal, toItem: view2, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let constraint4 = NSLayoutConstraint(item: view1, attribute: .leading, relatedBy: .equal, toItem: view2, attribute: .leading, multiplier: 1.0, constant: 0.0)
        view1.addConstraints([constraint1, constraint2, constraint3, constraint4])
    }
}
