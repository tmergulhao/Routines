//
//  ColorSelectionViewController.swift
//  Routines
//
//  Created by Tiago Mergulhão on 03/05/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

protocol ColorSelectionDelegate : class {

    func colorSelection(didSelect color : UIColor)
}

extension EditExercisesTableViewController : ColorSelectionDelegate {

    func colorSelection(didSelect color : UIColor) {

        self.color = color
        colorButton.backgroundColor = color
        let image = color == .clear ? #imageLiteral(resourceName: "Clear") : nil
        colorButton.setImage(image, for: .normal)
    }
}

class ColorSelectionViewController : UIViewController {

    weak var delegate : ColorSelectionDelegate?

    @IBAction func didTap(_ button : UIButton) {

        delegate?.colorSelection(didSelect: button.backgroundColor ?? .clear)
        self.dismiss(animated: true)
    }

    @IBOutlet var colorButtons : Array<UIButton>!
    @IBOutlet var cardView : UIView!

    override func viewWillLayoutSubviews() {

        super.viewWillLayoutSubviews()

        cardView.layer.cornerRadius = cardView.frame.height / 2

        for button in colorButtons {

            button.layer.cornerRadius = button.frame.height / 2
        }
    }
}
