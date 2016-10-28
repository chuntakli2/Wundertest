//
//  BaseViewController.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    fileprivate var loadingView: LoadingView?
    
    var statusBarStyle: UIStatusBarStyle = .lightContent {
        didSet {
            let baseNavigationController = APP_DELEGATE.window?.rootViewController as? BaseNavigationController
            baseNavigationController?.statusBarStyle = self.statusBarStyle
        }
    }
    var hideStatusBar = false {
        didSet {
            let baseNavigationController = APP_DELEGATE.window?.rootViewController as? BaseNavigationController
            baseNavigationController?.hideStatusBar = self.hideStatusBar
        }
    }
    
    fileprivate var hasLoadedConstraints = false
    
    // MARK: - Initialisation
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    deinit {
        
    }
    
    // MARK: - Accessors
    
    // MARK: - Public Methods
    
    func setup() {
        
    }
    
    func showLoadingView() {
        self.loadingView?.startAnimation()
        self.view.bringSubview(toFront: self.loadingView!)
    }
    
    func hideLoadingView() {
        self.loadingView?.stopAnimation()
        self.view.sendSubview(toBack: self.loadingView!)
    }
    
    // MARK: - Subviews
    
    fileprivate func setupLoadingView() {
        self.loadingView = LoadingView()
        self.loadingView?.alpha = 0.0
    }
    
    func setupSubviews() {
        self.setupLoadingView()
        self.loadingView!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.loadingView!)
    }
    
    override var prefersStatusBarHidden : Bool {
        return self.hideStatusBar
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.statusBarStyle
    }
    
    override func updateViewConstraints() {
        if (!self.hasLoadedConstraints) {
            let views = ["loading": self.loadingView!]
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[loading]", options: .directionMask, metrics: nil, views: views))
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[loading]", options: .directionMask, metrics: nil, views: views))
            
            self.view.addConstraint(NSLayoutConstraint(item: self.loadingView!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            
            self.view.addConstraint(NSLayoutConstraint(item: self.loadingView!, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            
            self.hasLoadedConstraints = true
        }
        super.updateViewConstraints()
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .white
        self.view.tintColor = TINT_COLOUR
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        self.setupSubviews()
        self.updateViewConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
