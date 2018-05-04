//
//  ColorSelectionViewController.swift
//  Routines
//
//  Created by Tiago Mergulhão on 03/05/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

class ColorSelectionViewController : UIViewController {

    @IBOutlet var colorButtons : Array<UIButton>!
    @IBOutlet var cardView : UIView!

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        cardView.layer.cornerRadius = cardView.frame.height / 2

        for button in colorButtons {

            button.layer.cornerRadius = button.frame.height / 2
        }
    }
}
