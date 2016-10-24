//
//  PullToAddView.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

class PullToAddView: UIView {
    
    var addView: UIImageView?
    
    private var hasLoadedConstraints = false
    
    // MARK: - Initialisation
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    deinit {
        
    }
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.setupSubviews()
    }
    
    private func setupFrameInSuperview(_ newSuperview: UIView?) {
        if let superview = newSuperview {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: superview.bounds.width, height: self.frame.height)
        }
    }
    
    // MARK: - Subviews
    
    private func setupAddView() {
        self.addView = UIImageView(image: UIImage(named: "add_white"))
        self.addView?.tintColor = .white
    }
    
    private func setupSubviews() {
        self.setupAddView()
        self.addView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.addView!)
    }
    
    override func layoutSubviews() {
        self.setupFrameInSuperview(self.superview)
        
        super.layoutSubviews()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.setupFrameInSuperview(newSuperview)
    }
    
    override func updateConstraints() {
        if (!self.hasLoadedConstraints) {
            let views = ["add": self.addView!]
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[add]", options: .directionMask, metrics: nil, views: views))
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[add]", options: .directionMask, metrics: nil, views: views))
            
            self.addConstraint(NSLayoutConstraint(item: self.addView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            
            self.addConstraint(NSLayoutConstraint(item: self.addView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            
            self.hasLoadedConstraints = true
        }
        super.updateConstraints()
    }
    
    override class var requiresConstraintBasedLayout : Bool {
        return true
    }
}
