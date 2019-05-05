//
//  EmptyStateViewControllerDelegate.swift
//  Routines
//
//  Created by Tiago Mergulhão on 07/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

@objc
protocol EmptyStateViewControllerDelegate : class {

    var emptyStateViewController : UIViewController? { get set }

    @objc optional func emptyStateControllerDidReceivePrimaryAction (sender : Any?)

    @objc optional func emptyStateControllerDidReceiveSecondaryAction (sender : Any?)

    @objc optional func configure(emptyState viewController : EmptyStateViewController, withIdentifier identifier : String)
}

extension EmptyStateViewControllerDelegate where Self : UIViewController {

    func removeEmptyState () {

        if emptyStateViewController != nil {

            emptyStateViewController!.willMove(toParent: nil)
            emptyStateViewController!.removeFromParent()
            emptyStateViewController!.view.removeFromSuperview()
        }
    }

    private func layoutContraints(fromContainer container : UIView, toContained contained : UIView) {

        contained.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            contained.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -50.0),
            contained.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            contained.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.7),
            contained.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.7),
        ]

        container.addSubview(contained)

        NSLayoutConstraint.activate(constraints)
    }

    func setEmptyState (identifier : String, intoContainer containerView : UIView) {

        removeEmptyState()

        if let tableView = view as? UITableView {
            tableView.separatorStyle = .none
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)

        guard let view = viewController.view else { return }

        if let responder = viewController as? EmptyStateViewController {

            responder.delegate = self
            responder.identifier = identifier
        }

        layoutContraints(fromContainer: containerView, toContained: view)

        addChild(viewController)

        emptyStateViewController = viewController

        viewController.didMove(toParent: self)

        view.layer.opacity = 0.0

        UIView.animate(withDuration: 0.2) {
            view.layer.opacity = 1.0
        }
    }
}
