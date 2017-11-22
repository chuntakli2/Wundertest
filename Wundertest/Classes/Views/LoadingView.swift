//
//  LoadingView.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    private var dotsStackView = UIStackView()
    private var dotOne = UIImageView()
    private var dotTwo = UIImageView()
    private var dotThree = UIImageView()
    
    private var isAnimating = false
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
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Events
    
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        if (self.isAnimating) {
            self.startAnimation()
        }
        self.isAnimating = false
    }
    
    @objc func applicationWillResignActive(_ notification: Notification) {
        if (self.alpha == 1.0) {
            self.isAnimating = true
            self.stopAnimation()
        }
    }
    
    // MARK: - Public Methods
    
    func startAnimation() {
        self.alpha = 1.0
        self.dotOne.layer.removeAllAnimations()
        self.dotTwo.layer.removeAllAnimations()
        self.dotThree.layer.removeAllAnimations()
        
        self.dotOne.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.dotTwo.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.dotThree.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        UIView.animate(withDuration: (2.0 * ANIMATION_DURATION), delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.dotOne.transform = CGAffineTransform.identity
            }, completion: nil)
        
        UIView.animate(withDuration: (2.0 * ANIMATION_DURATION), delay: 0.2, options: [.repeat, .autoreverse], animations: {
            self.dotTwo.transform = CGAffineTransform.identity
            }, completion: nil)
        
        UIView.animate(withDuration: (2.0 * ANIMATION_DURATION), delay: 0.4, options: [.repeat, .autoreverse], animations: {
            self.dotThree.transform = CGAffineTransform.identity
            }, completion: nil)
    }
    
    func stopAnimation() {
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            }, completion: { (finished) in
                self.dotOne.layer.removeAllAnimations()
                self.dotTwo.layer.removeAllAnimations()
                self.dotThree.layer.removeAllAnimations()
                self.alpha = 0.0
        })
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.setupSubviews()
        
        NotificationCenter.default.addObserver(self, selector: .applicationDidBecomeActive, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: .applicationWillResignActive, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    // MARK: - Subviews
    
    private func setupDotsStackView() {
        self.dotsStackView.axis = .horizontal
        self.dotsStackView.alignment = .center
        self.dotsStackView.distribution = .equalCentering
        self.dotsStackView.spacing = LOADING_RADIUS
    }
    
    private func setupDotOne() {
        self.dotOne.backgroundColor = TINT_COLOUR
        self.dotOne.layer.cornerRadius = LOADING_RADIUS
    }
    
    private func setupDotTwo() {
        self.dotTwo.backgroundColor = TINT_COLOUR
        self.dotTwo.layer.cornerRadius = LOADING_RADIUS
    }
    
    private func setupDotThree() {
        self.dotThree.backgroundColor = TINT_COLOUR
        self.dotThree.layer.cornerRadius = LOADING_RADIUS
    }
    
    private func setupSubviews() {
        self.setupDotsStackView()
        self.dotsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.dotsStackView)
        
        self.setupDotOne()
        self.dotOne.translatesAutoresizingMaskIntoConstraints = false
        self.dotsStackView.addArrangedSubview(self.dotOne)
        
        self.setupDotTwo()
        self.dotTwo.translatesAutoresizingMaskIntoConstraints = false
        self.dotsStackView.addArrangedSubview(self.dotTwo)
        
        self.setupDotThree()
        self.dotThree.translatesAutoresizingMaskIntoConstraints = false
        self.dotsStackView.addArrangedSubview(self.dotThree)
    }
    
    override func updateConstraints() {
        if (!self.hasLoadedConstraints) {
            let views: [String : Any] = ["stack": self.dotsStackView,
                                         "dotOne": self.dotOne,
                                         "dotTwo": self.dotTwo,
                                         "dotThree": self.dotThree]
            
            let metrics = ["DIAMETER": LOADING_DIAMETER]
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[stack]", options: .directionMask, metrics: nil, views: views))
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[stack]", options: .directionMask, metrics: nil, views: views))
            
            self.addConstraint(NSLayoutConstraint(item: self.dotsStackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            
            self.addConstraint(NSLayoutConstraint(item: self.dotsStackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            
            self.dotsStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dotOne(DIAMETER)]", options: .directionMask, metrics: metrics, views: views))
            
            self.dotsStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dotTwo(DIAMETER)]", options: .directionMask, metrics: metrics, views: views))
            
            self.dotsStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dotThree(DIAMETER)]", options: .directionMask, metrics: metrics, views: views))
            
            self.dotsStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dotOne(DIAMETER)]|", options: .directionMask, metrics: metrics, views: views))
            
            self.dotsStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dotTwo(DIAMETER)]|", options: .directionMask, metrics: metrics, views: views))
            
            self.dotsStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dotThree(DIAMETER)]|", options: .directionMask, metrics: metrics, views: views))
            
            self.hasLoadedConstraints = true
        }
        super.updateConstraints()
    }
    
    override class var requiresConstraintBasedLayout : Bool {
        return true
    }
}

private extension Selector {
    static let applicationDidBecomeActive = #selector(LoadingView.applicationDidBecomeActive)
    static let applicationWillResignActive = #selector(LoadingView.applicationWillResignActive)
}
