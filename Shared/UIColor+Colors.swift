//
//  UIColor+Colors.swift
//  Routines
//
//  Created by Tiago Mergulhão on 26/05/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import WatchKit
#endif

extension UIColor {

    static var teal : UIColor { return UIColor(named: "teal")! }
    static var red : UIColor { return UIColor(named: "red")! }
    static var blue : UIColor { return UIColor(named: "blue")! }
}
