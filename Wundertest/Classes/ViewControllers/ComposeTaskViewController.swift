//
//  ComposeTaskViewController.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

protocol ComposeTaskViewControllerDelegate: class {
    func compose(task: Task)
    func cancel()
}

class ComposeTaskViewController: BaseViewController, ComposeTaskViewDelegate {
    
    weak var delegate: ComposeTaskViewControllerDelegate?
    
    private var composeTaskView: ComposeTaskView?
    
    private var hasLoadedConstraints = false
    
    // MARK: - Initialisation
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        self.delegate = nil
    }
    
    // MARK: - Accessors

    // MARK: - Implementation of ComposeTaskViewDelegate Protocols
    
    func compose(task: Task) {
        self.delegate?.compose(task: task)
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
    }
    
    func cancel() {
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
        self.delegate?.cancel()
    }
    
    // MARK: - Subviews
    
    private func setupComposeTaskView() {
        self.composeTaskView = ComposeTaskView()
        self.composeTaskView?.delegate = self
    }

    override func setupSubviews() {
        super.setupSubviews()

        self.setupComposeTaskView()
        self.composeTaskView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.composeTaskView!)
    }
    
    override func updateViewConstraints() {
        if (!self.hasLoadedConstraints) {
            let views = ["compose": self.composeTaskView!]

            let metrics = ["WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": GENERAL_ITEM_HEIGHT,
                           "SMALL_SPACING": SMALL_SPACING]
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[compose]|", options: .directionMask, metrics: metrics, views: views))

            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[compose]|", options: .directionMask, metrics: metrics, views: views))

            self.hasLoadedConstraints = true
        }
        super.updateViewConstraints()
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let baseNavigationController = APP_DELEGATE.window?.rootViewController as? BaseNavigationController
        baseNavigationController?.supportedOrientations = .portrait
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let baseNavigationController = APP_DELEGATE.window?.rootViewController as? BaseNavigationController
        baseNavigationController?.supportedOrientations = .allButUpsideDown

    }
}
