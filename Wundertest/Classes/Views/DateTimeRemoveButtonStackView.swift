//
//  DateTimeRemoveButtonStackView.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

protocol DateTimeRemoveButtonStackViewDelegate: class {
    func dateTimeButtonPressed(type: DateTimeType)
    func removeButtonPressed(type: DateTimeType)
}

class DateTimeRemoveButtonStackView: UIStackView {
    
    weak var delegate: DateTimeRemoveButtonStackViewDelegate?
    var dateTimeType: DateTimeType = .date
    
    var dateTimeButton: UIButton?
    var removeButton: UIButton?
    
    fileprivate var hasLoadedConstraints = false
    
    // MARK: - Initialisation
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    deinit {
        self.delegate = nil
    }
    
    // MARK: - Events
    
    func dateTimeButtonAction() {
        self.delegate?.dateTimeButtonPressed(type: self.dateTimeType)
    }
    
    func removeButtonAction() {
        self.delegate?.removeButtonPressed(type: self.dateTimeType)
    }
    
    // MARK: - Public Methods
    
    func showRemoveButton() {
        self.removeButton?.isHidden = false
    }
    
    func hideRemoveButton() {
        self.removeButton?.isHidden = true
    }
    
    // MARK: - Private Methods
    
    fileprivate func setup() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.axis = .horizontal
        self.alignment = .leading
        self.spacing = SMALL_SPACING
        
        self.setupSubviews()
    }
    
    // MARK: - Subviews
    
    private func setupDateTimeButton() {
        self.dateTimeButton = UIButton(type: .system)
        self.dateTimeButton?.addTarget(self, action: .dateTimeButtonAction, for: .touchUpInside)
        self.dateTimeButton?.contentHorizontalAlignment = .left
        self.dateTimeButton?.titleEdgeInsets = UIEdgeInsetsMake(0.0, GENERAL_SPACING, 0.0, GENERAL_SPACING)
    }
    
    private func setupRemoveButton() {
        self.removeButton = UIButton(type: .system)
        self.removeButton?.setImage(UIImage(named: "close_white"), for: .normal)
        self.removeButton?.addTarget(self, action: .removeButtonAction, for: .touchUpInside)
        self.removeButton?.tintColor = .red
        self.removeButton?.isHidden = true
    }
    
    private func setupSubviews() {
        self.setupDateTimeButton()
        self.dateTimeButton?.translatesAutoresizingMaskIntoConstraints = false
        self.addArrangedSubview(self.dateTimeButton!)
        
        self.setupRemoveButton()
        self.removeButton?.translatesAutoresizingMaskIntoConstraints = false
        self.addArrangedSubview(self.removeButton!)
    }
    
    override func updateConstraints() {
        if (!self.hasLoadedConstraints) {
            let views = ["dateTime": self.dateTimeButton!,
                         "remove": self.removeButton!]
            
            let metrics = ["WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": GENERAL_ITEM_HEIGHT]
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[dateTime]", options: .directionMask, metrics: metrics, views: views))
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[remove(WIDTH)]|", options: .directionMask, metrics: metrics, views: views))
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dateTime]|", options: .directionMask, metrics: metrics, views: views))
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[remove(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))
            
            self.hasLoadedConstraints = true
        }
        super.updateConstraints()
    }
    
    override class var requiresConstraintBasedLayout : Bool {
        return true
    }
}

private extension Selector {
    static let dateTimeButtonAction = #selector(DateTimeRemoveButtonStackView.dateTimeButtonAction)
    static let removeButtonAction = #selector(DateTimeRemoveButtonStackView.removeButtonAction)
}
