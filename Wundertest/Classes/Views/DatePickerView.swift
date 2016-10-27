//
//  DatePickerView.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

protocol DatePickerViewDelegate: class {
    func changed(date: Date)
    func done(date: Date)
    func cancel(date: Date)
}

class DatePickerView: UIView {
    
    weak var delegate: DatePickerViewDelegate?

    private var toolBar: UIToolbar?
    private var titleLabel: UILabel?
    private var datePicker: UIDatePicker?
    
    var title: String = "" {
        didSet {
            self.titleLabel?.attributedText = NSAttributedString(string: self.title, attributes: FONT_ATTR_MEDIUM_BLACK)
        }
    }
    var date: Date = Date() {
        didSet {
            self.datePicker?.date = date
        }
    }
    var mode: UIDatePickerMode = .date {
        didSet {
            self.datePicker?.datePickerMode = self.mode
        }
    }
    
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
        self.delegate = nil
    }
    
    // MARK: - Events
    
    func dateChanged() {
        self.delegate?.changed(date: (self.datePicker?.date)!)
    }
    
    func doneAction() {
        self.delegate?.done(date: (self.datePicker?.date)!)
        self.dismiss()
    }
    
    func cancelAction() {
        self.delegate?.cancel(date: self.date)
        self.dismiss()
    }
    
    // MARK: - Public Methods
    
    func show() {
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            self.alpha = 1.0
        })
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        self.backgroundColor = .white
        self.translatesAutoresizingMaskIntoConstraints = true
        self.setupSubviews()
    }
    
    private func dismiss() {
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            self.alpha = 0.0
        })
    }

    // MARK: - Subviews
    
    private func setupToolBar() {
        self.toolBar = UIToolbar()
        self.toolBar?.barStyle = .default
        
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: .doneAction)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: .cancelAction)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.toolBar?.setItems([cancelItem, space, doneItem], animated: false)
    }
    
    private func setupTitleLabel() {
        self.titleLabel = UILabel()
        self.titleLabel?.numberOfLines = 1
    }
    
    private func setupDatePicker() {
        self.datePicker = UIDatePicker()
        self.datePicker?.minimumDate = Date()
        self.datePicker?.addTarget(self, action: .dateChanged, for: .valueChanged)
    }

    private func setupSubviews() {
        self.setupToolBar()
        self.toolBar?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.toolBar!)
        
        self.setupTitleLabel()
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.titleLabel!)
        
        self.setupDatePicker()
        self.datePicker?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.datePicker!)
    }
    
    override func updateConstraints() {
        if (!self.hasLoadedConstraints) {
            let views: [String: Any] = ["tool": self.toolBar!,
                                        "title": self.titleLabel!,
                                        "date": self.datePicker!]
            
            let metrics = ["HEIGHT": GENERAL_ITEM_HEIGHT]
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[tool]|", options: .directionMask, metrics: nil, views: views))

            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[title]", options: .directionMask, metrics: nil, views: views))

            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[date]|", options: .directionMask, metrics: nil, views: views))

            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tool(HEIGHT)][date]|", options: .directionMask, metrics: metrics, views: views))
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[title]", options: .directionMask, metrics: nil, views: views))
            
            self.addConstraint(NSLayoutConstraint(item: self.titleLabel!, attribute: .centerX, relatedBy: .equal, toItem: self.toolBar!, attribute: .centerX, multiplier: 1.0, constant: 0.0))

            self.addConstraint(NSLayoutConstraint(item: self.titleLabel!, attribute: .centerY, relatedBy: .equal, toItem: self.toolBar!, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            
            self.hasLoadedConstraints = true
        }
        super.updateConstraints()
    }
    
    override class var requiresConstraintBasedLayout : Bool {
        return true
    }
}

private extension Selector {
    static let dateChanged = #selector(DatePickerView.dateChanged)
    static let doneAction = #selector(DatePickerView.doneAction)
    static let cancelAction = #selector(DatePickerView.cancelAction)
}
