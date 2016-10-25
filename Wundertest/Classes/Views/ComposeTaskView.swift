//
//  ComposeTaskView.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

protocol ComposeTaskViewDelegate: class {
    func compose(task: Task)
    func cancel()
}

class ComposeTaskView: UIView, UITextViewDelegate, DatePickerViewDelegate {
    
    weak var delegate: ComposeTaskViewDelegate?
    
    private var blurBackgroundView: UIVisualEffectView?
    private var baseView: UIView?
    private var blurBaseView: UIVisualEffectView?
    private var titleLabel: UILabel?
    private var countdownLabel: UILabel?
    private var textView: UITextView?
    private var blurTextView: UIVisualEffectView?
    private var dateButton: UIButton?
    private var timeButton: UIButton?
    private var buttonsStackView: UIStackView?
    private var cancelButton: UIButton?
    private var saveButton: UIButton?
    private var blurSaveButton: UIVisualEffectView?
    private var datePickerView: DatePickerView?
    
    private var blurTextViewWidthConstraint: NSLayoutConstraint?
    private var blurTextViewHeightConstraint: NSLayoutConstraint?
    
    private var dueDate = Date()

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
        self.textView?.resignFirstResponder()
        self.delegate = nil
    }
    
    // MARK: - Accessors
    
    // MARK: - Implementation of UITextViewDelegate protocols
    
    func textViewDidChange(_ textView: UITextView) {
        self.blurTextViewWidthConstraint?.constant = textView.bounds.width
        self.blurTextViewHeightConstraint?.constant = textView.bounds.height + 2 * textView.contentSize.height
        
        let count = textView.text.characters.count
        let countdownString = String(format: "%d / %d", count, MAXIMUM_TEXT_COUNT)
        let attributes = ((count <= MAXIMUM_TEXT_COUNT) ? FONT_ATTR_SMALL_BLACK : FONT_ATTR_SMALL_RED)
        textView.textColor = ((count <= MAXIMUM_TEXT_COUNT) ? FONT_COLOUR_BLACK : FONT_COLOUR_RED)
        self.countdownLabel?.attributedText = NSAttributedString(string: countdownString, attributes: attributes)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return (text != "\n")
    }
    
    // MARK: - Implementation of DatePickerViewDelegate Protocols
    
    func changed() {
        
    }
    
    func done(date: Date) {
        self.dueDate = date
    }
    
    func cancel() {
        
    }
    
    // MARK: - Events
    
    func tapAction() {
        self.textView?.resignFirstResponder()
    }
    
    func dateButtonAction() {
        self.textView?.resignFirstResponder()
        
        let datePickerView = DatePickerView()
        datePickerView.delegate = self
        datePickerView.datePicker?.datePickerMode = .date
        datePickerView.titleLabel?.attributedText = NSAttributedString(string: NSLocalizedString("date.title", comment: ""), attributes: FONT_ATTR_MEDIUM_BLACK)
        
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(datePickerView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[date]|", options: .directionMask, metrics: nil, views: ["date": datePickerView]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[date]|", options: .directionMask, metrics: nil, views: ["date": datePickerView]))
    }
    
    func timeButtonAction() {
        self.textView?.resignFirstResponder()
        
        let datePickerView = DatePickerView()
        datePickerView.delegate = self
        datePickerView.datePicker?.datePickerMode = .dateAndTime
        datePickerView.titleLabel?.attributedText = NSAttributedString(string: NSLocalizedString("time.title", comment: ""), attributes: FONT_ATTR_MEDIUM_BLACK)
        
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(datePickerView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[date]|", options: .directionMask, metrics: nil, views: ["date": datePickerView]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[date]|", options: .directionMask, metrics: nil, views: ["date": datePickerView]))
    }
    
    func cancelButtonAction() {
        self.dismiss { [unowned self] (completed) in
            self.delegate?.cancel()
        }
    }
    
    func saveButtonAction() {
        let count = self.textView?.text.characters.count ?? 0
        guard (count > 0 && count <= MAXIMUM_TEXT_COUNT) else { return }
        
        self.dismiss { [unowned self] (completed) in
            if let title = self.textView?.text {
                let task = Task()
                task.title = title
                self.delegate?.compose(task: task)
            }
        }
    }

    // MARK: - Public Methods
    
    func updateTextView(withText text: String?) {
        self.textView?.text = text
        let count = text?.characters.count ?? 0
        let countdownString = String(format: "%d / %d", count, MAXIMUM_TEXT_COUNT)
        self.countdownLabel?.attributedText = NSAttributedString(string: countdownString, attributes: FONT_ATTR_SMALL_BLACK)
    }
    
    // MARK: - Private Methods
    
    private func dismiss(callback: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            self.baseView?.transform = CGAffineTransform(translationX: 0.0, y: UIScreen.main.bounds.height)
        }) { (completed) in
            callback(completed)
        }
    }
    
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.setupSubviews()
        
        let tap = UITapGestureRecognizer(target: self, action: .tapAction)
        self.addGestureRecognizer(tap)
        
        self.baseView?.transform = CGAffineTransform(translationX: 0.0, y: -UIScreen.main.bounds.height)
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            self.baseView?.transform = .identity
        }) { [unowned self] (isCompleted) in
            self.textView?.becomeFirstResponder()
        }
    }
    
    // MARK: - Subviews
    
    private func setupBlurBackgroundView() {
        self.blurBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    }
    
    private func setupBaseView() {
        self.baseView = UIView()
        self.baseView?.layer.cornerRadius = CORNER_RADIUS
        self.baseView?.layer.masksToBounds = true
    }
    
    private func setupBlurBaseView() {
        self.blurBaseView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    }
    
    private func setupTitleLabel() {
        self.titleLabel = UILabel()
        self.titleLabel?.attributedText = NSAttributedString(string: NSLocalizedString("newTask.title", comment: ""), attributes: FONT_ATTR_LARGE_BLACK)
    }
    
    private func setupCountdownLabel() {
        self.countdownLabel = UILabel()
        self.countdownLabel?.attributedText = NSAttributedString(string: String(format: "0 / %d", MAXIMUM_TEXT_COUNT), attributes: FONT_ATTR_SMALL_BLACK)
    }
    
    private func setupTextView() {
        self.textView = UITextView()
        self.textView?.delegate = self
        self.textView?.returnKeyType = .done
        self.textView?.backgroundColor = .clear
        self.textView?.textColor = FONT_COLOUR_BLACK
        self.textView?.font = FONT_MEDIUM
        self.textView?.tintColor = TINT_COLOUR
        self.textView?.layer.borderColor = TINT_COLOUR.cgColor
        self.textView?.layer.borderWidth = 1.0
        self.textView?.layer.cornerRadius = CORNER_RADIUS
    }
    
    private func setupBlurTextView() {
        self.blurTextView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        self.blurTextView?.isUserInteractionEnabled = false
    }
    
    private func setupDateButton() {
        self.dateButton = UIButton(type: .system)
        self.dateButton?.addTarget(self, action: .dateButtonAction, for: .touchUpInside)
        self.dateButton?.layer.borderColor = TINT_COLOUR.cgColor
        self.dateButton?.layer.borderWidth = 1.0
        self.dateButton?.layer.cornerRadius = CORNER_RADIUS
        self.dateButton?.backgroundColor = .red
    }
    
    private func setupTimeButton() {
        self.timeButton = UIButton(type: .system)
        self.timeButton?.addTarget(self, action: .timeButtonAction, for: .touchUpInside)
        self.timeButton?.layer.borderColor = TINT_COLOUR.cgColor
        self.timeButton?.layer.borderWidth = 1.0
        self.timeButton?.layer.cornerRadius = CORNER_RADIUS
        self.timeButton?.backgroundColor = .blue
    }
    
    private func setupButtonsStackView() {
        self.buttonsStackView = UIStackView()
        self.buttonsStackView?.axis = .horizontal
        self.buttonsStackView?.alignment = .center
        self.buttonsStackView?.distribution = .fillEqually
        self.buttonsStackView?.spacing = GENERAL_SPACING
    }
    
    private func setupCancelButton() {
        self.cancelButton = UIButton(type: .system)
        self.cancelButton?.addTarget(self, action: .cancelButtonAction, for: .touchUpInside)
        self.cancelButton?.setAttributedTitle(NSAttributedString(string: NSLocalizedString("cancel.title", comment: ""), attributes: FONT_ATTR_LARGE_BLACK), for: .normal)
        self.cancelButton?.layer.borderColor = TINT_COLOUR.cgColor
        self.cancelButton?.layer.borderWidth = 1.0
        self.cancelButton?.layer.cornerRadius = CORNER_RADIUS
    }
    
    private func setupSaveButton() {
        self.saveButton = UIButton(type: .system)
        self.saveButton?.addTarget(self, action: .saveButtonAction, for: .touchUpInside)
        self.saveButton?.setAttributedTitle(NSAttributedString(string: NSLocalizedString("save.title", comment: ""), attributes: FONT_ATTR_LARGE_BLACK_BOLD), for: .normal)
        self.saveButton?.layer.borderColor = TINT_COLOUR.cgColor
        self.saveButton?.layer.borderWidth = 1.0
        self.saveButton?.layer.cornerRadius = CORNER_RADIUS
        self.saveButton?.layer.masksToBounds = true
    }
    
    private func setupBlurSaveButton() {
        self.blurSaveButton = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        self.blurSaveButton?.isUserInteractionEnabled = false
    }
    
    private func setupSubviews() {
        self.setupBlurBackgroundView()
        self.blurBackgroundView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.blurBackgroundView!)
        
        self.setupBaseView()
        self.baseView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.baseView!)
        
        self.setupBlurBaseView()
        self.blurBaseView?.translatesAutoresizingMaskIntoConstraints = false
        self.baseView?.addSubview(self.blurBaseView!)
        
        self.setupTitleLabel()
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.baseView?.addSubview(self.titleLabel!)
        
        self.setupCountdownLabel()
        self.countdownLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.baseView?.addSubview(self.countdownLabel!)
        
        self.setupTextView()
        self.textView?.translatesAutoresizingMaskIntoConstraints = false
        self.baseView?.addSubview(self.textView!)
        
        self.setupBlurTextView()
        self.blurTextView?.translatesAutoresizingMaskIntoConstraints = false
        self.textView?.insertSubview(self.blurTextView!, belowSubview: (self.textView?.textInputView)!)
        
        self.setupDateButton()
        self.dateButton?.translatesAutoresizingMaskIntoConstraints = false
        self.baseView?.addSubview(self.dateButton!)
        
        self.setupTimeButton()
        self.timeButton?.translatesAutoresizingMaskIntoConstraints = false
        self.baseView?.addSubview(self.timeButton!)
        
        self.setupButtonsStackView()
        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false
        self.baseView?.addSubview(self.buttonsStackView!)
        
        self.setupCancelButton()
        self.cancelButton?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.addArrangedSubview(self.cancelButton!)
        
        self.setupSaveButton()
        self.saveButton?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.addArrangedSubview(self.saveButton!)
        
        self.setupBlurSaveButton()
        self.blurSaveButton?.translatesAutoresizingMaskIntoConstraints = false
        self.saveButton?.insertSubview(self.blurSaveButton!, belowSubview: (self.saveButton?.titleLabel)!)
    }
    
    override func updateConstraints() {
        if (!self.hasLoadedConstraints) {
            let views = ["blurBackground": self.blurBackgroundView!,
                         "base": self.baseView!,
                         "blurBase": self.blurBaseView!,
                         "title": self.titleLabel!,
                         "countdown": self.countdownLabel!,
                         "text": self.textView!,
                         "blurText": self.blurTextView!,
                         "date": self.dateButton!,
                         "time": self.timeButton!,
                         "buttons": self.buttonsStackView!,
                         "cancel": self.cancelButton!,
                         "save": self.saveButton!,
                         "blurSave": self.blurSaveButton!]
            
            let metrics = ["SPACING": GENERAL_SPACING,
                           "LARGE_SPACING": LARGE_SPACING,
                           "HEIGHT": GENERAL_ITEM_HEIGHT,
                           "WIDTH": COMPOSE_TASK_VIEW_WIDTH,
                           "TEXT_VIEW_HEIGHT": TEXT_VIEW_HEIGHT]
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[blurBackground]|", options: .directionMask, metrics: nil, views: views))

            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[base(WIDTH)]", options: .directionMask, metrics: metrics, views: views))

            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[blurBackground]|", options: .directionMask, metrics: nil, views: views))
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(LARGE_SPACING)-[base]", options: .directionMask, metrics: metrics, views: views))
            
            self.addConstraint(NSLayoutConstraint(item: self.baseView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            
            self.baseView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[blurBase]|", options: .directionMask, metrics: metrics, views: views))
            
            self.baseView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[title]-(>=SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.baseView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[countdown]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.baseView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[text]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.baseView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[date]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.baseView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[time]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.baseView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[buttons]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.baseView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[blurBase]|", options: .directionMask, metrics: nil, views: views))
            
            self.baseView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(SPACING)-[title]-(SPACING)-[text(TEXT_VIEW_HEIGHT)]-(SPACING)-[date(HEIGHT)]-(SPACING)-[time(HEIGHT)]-[buttons(HEIGHT)]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.baseView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[countdown]", options: .directionMask, metrics: metrics, views: views))
            
            self.baseView!.addConstraint(NSLayoutConstraint(item: self.countdownLabel!, attribute: .bottom, relatedBy: .equal, toItem: self.titleLabel!, attribute: .bottom, multiplier: 1.0, constant: 0.0))
            
            self.blurTextViewWidthConstraint = NSLayoutConstraint(item: self.blurTextView!, attribute: .width, relatedBy: .equal, toItem: self.textView!, attribute: .width, multiplier: 1.0, constant: 0.0)
            
            self.blurTextViewHeightConstraint = NSLayoutConstraint(item: self.blurTextView!, attribute: .height, relatedBy: .equal, toItem: self.textView!, attribute: .height, multiplier: 1.0, constant: 0.0)
            
            self.textView!.addConstraint(self.blurTextViewWidthConstraint!)
            
            self.textView!.addConstraint(self.blurTextViewHeightConstraint!)
            
            self.textView!.addConstraint(NSLayoutConstraint(item: self.blurTextView!, attribute: .centerX, relatedBy: .equal, toItem: self.textView!, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            
            self.textView!.addConstraint(NSLayoutConstraint(item: self.blurTextView!, attribute: .centerY, relatedBy: .equal, toItem: self.textView!, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            
            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cancel]|", options: .directionMask, metrics: nil, views: views))
            
            self.buttonsStackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[save]|", options: .directionMask, metrics: nil, views: views))
            
            self.saveButton!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[blurSave]|", options: .directionMask, metrics: nil, views: views))
            
            self.saveButton!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[blurSave]|", options: .directionMask, metrics: nil, views: views))
            
            self.hasLoadedConstraints = true
        }
        super.updateConstraints()
    }
}

private extension Selector {
    static let tapAction = #selector(ComposeTaskView.tapAction)
    static let dateButtonAction = #selector(ComposeTaskView.dateButtonAction)
    static let timeButtonAction = #selector(ComposeTaskView.timeButtonAction)
    static let cancelButtonAction = #selector(ComposeTaskView.cancelButtonAction)
    static let saveButtonAction = #selector(ComposeTaskView.saveButtonAction)
}
