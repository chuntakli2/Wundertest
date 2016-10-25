//
//  BaseNavigationController.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    var statusBarStyle: UIStatusBarStyle = .lightContent {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    var hideStatusBar = false {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    var supportedOrientations: UIInterfaceOrientationMask = .allButUpsideDown
    
    // MARK: - Public Methods
    
    override var prefersStatusBarHidden : Bool {
        return self.hideStatusBar
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.statusBarStyle
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return self.supportedOrientations
    }
}

