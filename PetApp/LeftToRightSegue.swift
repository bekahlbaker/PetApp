//
//  LeftToRightSegue.swift
//  PetApp
//
//  Created by Rebekah Baker on 1/19/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//  www.stackoverflow.com/a/31411862
//

import UIKit
import QuartzCore

class LeftToRightSegue: UIStoryboardSegue {
    override func perform() {
        let src: UIViewController = self.source
        let dst: UIViewController = self.destination
        let transition: CATransition = CATransition()
        let timeFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.35
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        src.navigationController!.view.layer.add(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
    }
}
