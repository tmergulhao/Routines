//
//  EmptyStateViewController.swift
//  Routines
//
//  Created by Tiago Mergulhão on 06/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

class EmptyStateViewController : UIViewController {

    var delegate : EmptyStateViewControllerDelegate?

    @IBOutlet weak var primaryButton : UIButton!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var summaryLabel : UILabel!
    @IBOutlet weak var secondaryButton : UIButton!

    @IBAction func primary (sender : Any?) {
        delegate?.emptyStateControllerDidReceivePrimaryAction?(sender: sender)
    }
    @IBAction func secondary (sender : Any?) {
        delegate?.emptyStateControllerDidReceiveSecondaryAction?(sender: sender)
    }

    var identifier : String!

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        delegate?.configure?(emptyState: self, withIdentifier: identifier)
    }
}
