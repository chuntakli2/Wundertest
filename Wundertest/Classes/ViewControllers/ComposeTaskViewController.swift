//
//  ComposeTaskViewController.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

protocol ComposeTaskViewControllerDelegate: class {
    func composed()
    func saved()
    func cancel()
}

class ComposeTaskViewController: BaseViewController, ComposeTaskViewDelegate {
    
    weak var delegate: ComposeTaskViewControllerDelegate?
    
    private var composeTaskView: ComposeTaskView?
    
    var task: Task?
    
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
        TaskManager.sharedInstance.create(task: task, realm: RealmManager.sharedInstance.realm)
        self.delegate?.composed()
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
    }
    
    func cancel() {
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
        self.delegate?.cancel()
    }
    
    // MARK: - Events
    
    func saveAction() {
        self.composeTaskView?.deactivateKeyboard()
        
        let id = (self.task?.id)!
        let title = self.composeTaskView?.title ?? (self.task?.title)!
        TaskManager.sharedInstance.update(taskId: id, title: title, dueDate: self.composeTaskView?.dueDate, reminder: self.composeTaskView?.reminder, realm: RealmManager.sharedInstance.realm)
        let _ = self.navigationController?.popViewController(animated: true)
        self.delegate?.saved()        
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.composeTaskView?.task = self.task
        self.composeTaskView?.show(animated: (self.task == nil))
        
        self.title = NSLocalizedString("edit.title", comment: "")
        let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: .saveAction)
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
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
        
        self.composeTaskView?.deactivateKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.composeTaskView?.activateKeyboard()
    }
}

private extension Selector {
    static let saveAction = #selector(ComposeTaskViewController.saveAction)
}
