//
//  ViewController.swift
//  OverlayViewController
//
//  Created by Andrey Gordeev on 4/17/17.
//  Copyright © 2017 Andrey Gordeev (andrew8712@gmail.com). All rights reserved.
//

import UIKit

class ViewController: UIViewController, OverlayHost {
    @IBAction func showOverlayButtonPressed() {
        showOverlay(type: MessageViewController.self, fromStoryboardWithName: "Main")
    }
}
