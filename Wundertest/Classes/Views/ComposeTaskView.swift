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

class ComposeTaskView: UIView, UITextViewDelegate, DateTimeRemoveButtonStackViewDelegate, DatePickerViewDelegate {
    
    weak var delegate: ComposeTaskViewDelegate?
    
    private var blurBackgroundView: UIVisualEffectView?
    private var baseView: UIView?
    private var blurBaseView: UIVisualEffectView?
    private var stackView: UIStackView?
    private var titleLabel: UILabel?
    private var textView: UITextView?
    private var blurTextView: UIVisualEffectView?
    private var dateButton: DateTimeRemoveButtonStackView?
    private var timeButton: DateTimeRemoveButtonStackView?
    private var buttonsStackView: UIStackView?
    private var cancelButton: UIButton?
    private var saveButton: UIButton?
    private var blurSaveButton: UIVisualEffectView?
    
    private var blurTextViewWidthConstraint: NSLayoutConstraint?
    private var blurTextViewHeightConstraint: NSLayoutConstraint?

    var task: Task? {
        didSet {
            if let task = self.task {
                self.title = task.title
                self.textView?.text = task.title
                self.dueDate = task.dueDate
                self.reminder = task.reminder

                self.titleLabel?.isHidden = true
                self.buttonsStackView?.isHidden = true
            }
        }
    }

    var title: String?
    var dueDate: Date? {
        didSet {
            if let date = self.dueDate {
                let calendar = Calendar.current
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                let day = calendar.component(.day, from: date)
                
                var attributes: [String: Any] = FONT_ATTR_MEDIUM_DEFAULT_TINT
                attributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue
                let dateString = String(format: "%d-%d-%d", day, month, year)
                self.dateButton?.dateTimeButton?.setAttributedTitle(NSAttributedString(string: dateString, attributes: attributes), for: .normal)
                self.dateButton?.showRemoveButton()
            } else {
                var attributes: [String: Any] = FONT_ATTR_MEDIUM_DEFAULT_TINT
                attributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue
                self.dateButton?.dateTimeButton?.setAttributedTitle(NSAttributedString(string: NSLocalizedString("addDueDate.title", comment: ""), attributes: attributes), for: .normal)
                self.dateButton?.hideRemoveButton()
            }
        }
    }
    var reminder: Date? {
        didSet {
            if let date = self.reminder {
                let calendar = Calendar.current
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                let day = calendar.component(.day, from: date)
                let hour = calendar.component(.hour, from: date)
                let minute = calendar.component(.minute, from: date)
                
                var attributes: [String: Any] = FONT_ATTR_MEDIUM_DEFAULT_TINT
                attributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue
                let timeString = String(format: "%d-%d-%d %d : %d", day, month, year, hour, minute)
                self.timeButton?.dateTimeButton?.setAttributedTitle(NSAttributedString(string: timeString, attributes: attributes), for: .normal)
                self.timeButton?.showRemoveButton()
            } else {
                var attributes: [String: Any] = FONT_ATTR_MEDIUM_DEFAULT_TINT
                attributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue
                self.timeButton?.dateTimeButton?.setAttributedTitle(NSAttributedString(string: NSLocalizedString("addReminder.title", comment: ""), attributes: attributes), for: .normal)
                self.timeButton?.hideRemoveButton()
            }
        }
    }
    private var dateTimeType: DateTimeType = .date

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
    
    private lazy var datePickerView: DatePickerView = {
        let _datePickerView = DatePickerView()
        _datePickerView.delegate = self
        _datePickerView.alpha = 0.0
        _datePickerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(_datePickerView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[date]|", options: .directionMask, metrics: nil, views: ["date": _datePickerView]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[date]|", options: .directionMask, metrics: nil, views: ["date": _datePickerView]))
        return _datePickerView
    }()
    
    // MARK: - Implementation of DateTimeRemoveButtonStackViewDelegate Protocols
    
    func dateTimeButtonPressed(type: DateTimeType) {
        self.dateTimeType = type
        self.showDatePickerView(isDateMode: (type == .date))
    }
    
    func removeButtonPressed(type: DateTimeType) {
        if (type == .date) {
            self.dueDate = nil
        } else {
            self.reminder = nil
        }
    }
    
    // MARK: - Implementation of UITextViewDelegate Protocols

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return (text != "\n")
    }

    func textViewDidChange(_ textView: UITextView) {
        self.blurTextViewWidthConstraint?.constant = textView.bounds.width
        self.blurTextViewHeightConstraint?.constant = textView.bounds.height + 2.0 * textView.contentSize.height
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.title = textView.text
    }
    
    // MARK: - Implementation of DatePickerViewDelegate Protocols
    
    func changed(date: Date) {
        self.updateDueDateOrReminder(date: date)
    }
    
    func done(date: Date) {
        self.updateDueDateOrReminder(date: date)
    }
    
    func cancel(date: Date?) {
        self.updateDueDateOrReminder(date: date)
    }
    
    // MARK: - Events
    
    func tapAction() {
        self.textView?.resignFirstResponder()
    }
    
    func cancelButtonAction() {
        self.dismiss { [unowned self] (completed) in
            self.delegate?.cancel()
        }
    }
    
    func saveButtonAction() {
        let count = self.textView?.text.characters.count ?? 0
        guard (count > 0) else { return }
        
        self.dismiss { [unowned self] (completed) in
            if let title = self.textView?.text {
                let task = Task()
                task.title = title
                task.dueDate = self.dueDate
                task.reminder = self.reminder
                self.delegate?.compose(task: task)
            }
        }
    }

    // MARK: - Public Methods
    
    func show(animated: Bool) {
        if (animated) {
            self.baseView?.transform = CGAffineTransform(translationX: 0.0, y: -UIScreen.main.bounds.height)
            UIView.animate(withDuration: ANIMATION_DURATION, animations: {
                self.baseView?.transform = .identity
            })
        }
    }
    
    func activateKeyboard() {
        self.textView?.becomeFirstResponder()
    }
    
    func deactivateKeyboard() {
        self.textView?.resignFirstResponder()
    }
    
    // MARK: - Private Methods
    
    private func showDatePickerView(isDateMode: Bool) {
        self.textView?.resignFirstResponder()
        
        self.datePickerView.title = (isDateMode ? NSLocalizedString("dueDate.title", comment: "") : NSLocalizedString("reminder.title", comment: ""))
        self.datePickerView.date = self.dueDate
        self.datePickerView.mode = (isDateMode ? .date : .dateAndTime)
        self.datePickerView.show()
    }
    
    private func updateDueDateOrReminder(date: Date?) {
        if (self.dateTimeType == .date) {
            self.dueDate = date
        } else {
            self.reminder = date
        }
    }
    
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
    
    private func setupStackView() {
        self.stackView = UIStackView()
        self.stackView?.axis = .vertical
        self.stackView?.spacing = GENERAL_SPACING
        self.stackView?.alignment = .center
    }
    
    private func setupTitleLabel() {
        self.titleLabel = UILabel()
        self.titleLabel?.attributedText = NSAttributedString(string: NSLocalizedString("newTask.title", comment: ""), attributes: FONT_ATTR_LARGE_BLACK)
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
        self.dateButton = DateTimeRemoveButtonStackView()
        self.dateButton?.delegate = self
        self.dateButton?.dateTimeType = .date
        self.dueDate = nil
    }
    
    private func setupTimeButton() {
        self.timeButton = DateTimeRemoveButtonStackView()
        self.timeButton?.delegate = self
        self.timeButton?.dateTimeType = .time
        self.reminder = nil
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
        
        self.setupStackView()
        self.stackView?.translatesAutoresizingMaskIntoConstraints = false
        self.baseView?.addSubview(self.stackView!)
        
        self.setupTitleLabel()
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.stackView?.addArrangedSubview(self.titleLabel!)
        
        self.setupTextView()
        self.textView?.translatesAutoresizingMaskIntoConstraints = false
        self.stackView?.addArrangedSubview(self.textView!)
        
        self.setupBlurTextView()
        self.blurTextView?.translatesAutoresizingMaskIntoConstraints = false
        self.textView?.insertSubview(self.blurTextView!, belowSubview: (self.textView?.textInputView)!)
        
        self.setupDateButton()
        self.dateButton?.translatesAutoresizingMaskIntoConstraints = false
        self.stackView?.addArrangedSubview(self.dateButton!)
        
        self.setupTimeButton()
        self.timeButton?.translatesAutoresizingMaskIntoConstraints = false
        self.stackView?.addArrangedSubview(self.timeButton!)
        
        self.setupButtonsStackView()
        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false
        self.stackView?.addArrangedSubview(self.buttonsStackView!)
        
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
                         "stack": self.stackView!,
                         "title": self.titleLabel!,
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
            
            self.baseView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[stack]|", options: .directionMask, metrics: metrics, views: views))

            self.stackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[title]-(>=SPACING)-|", options: .directionMask, metrics: metrics, views: views))
                        
            self.stackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[text]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.stackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[date]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.stackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[time]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.stackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[buttons]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.baseView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[blurBase]|", options: .directionMask, metrics: nil, views: views))

            self.baseView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(SPACING)-[stack]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.stackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[title]", options: .directionMask, metrics: metrics, views: views))

            self.stackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[text(TEXT_VIEW_HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.stackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[date(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.stackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[time(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

            self.stackView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[buttons(HEIGHT)]", options: .directionMask, metrics: metrics, views: views))

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
    static let cancelButtonAction = #selector(ComposeTaskView.cancelButtonAction)
    static let saveButtonAction = #selector(ComposeTaskView.saveButtonAction)
}
