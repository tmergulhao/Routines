//
//  FloatingActionButton.swift
//  Routines
//
//  Created by Tiago Mergulhão on 28/05/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

class FloatingActionButton : UIButton {

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {

        let position = touch.location(in: self)

        if bounds.contains(position) {

            pushDown()
        }

        return super.beginTracking(touch, with: event)
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {

        let position = touch.location(in: self)
        if !bounds.contains(position) {

            popBack()
        }

        return super.continueTracking(touch, with: event)
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {

        popBack()

        super.endTracking(touch, with: event)
    }

    func pushDown () {

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .curveEaseOut,
            animations: {
                self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
    }

    func popBack () {
        UIView.animate(
            withDuration: 0.4,
            delay: 0.3,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .curveEaseOut,
            animations: {
                self.transform = .identity
        }, completion: nil)
    }

    override func didMoveToSuperview() {

        translatesAutoresizingMaskIntoConstraints = false
    }
}
