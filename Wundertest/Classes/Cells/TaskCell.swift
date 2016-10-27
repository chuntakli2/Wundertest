//
//  TaskCell.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

protocol TaskCellDelegate: class {
    func completed(indexPath: IndexPath)
}

class TaskCell: UITableViewCell {
    
    weak var delegate: TaskCellDelegate?
    var indexPath = IndexPath()
    
    private var checkBoxButton: UIButton?
    var checkBoxImageView: UIImageView?
    var titleLabel: UILabel?
    var dueDateLabel: UILabel?
    
    private var hasLoadedConstraints = false
    
    // MARK: - Initialisation
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
    
    func checkBoxButtonAction() {
        self.delegate?.completed(indexPath: self.indexPath)
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.translatesAutoresizingMaskIntoConstraints = true
        self.contentView.translatesAutoresizingMaskIntoConstraints = true
        self.setupSubviews()
        self.updateConstraints()
    }
    
    // MARK: - Subviews

    private func setupCheckBoxButton() {
        self.checkBoxButton = UIButton(type: .system)
        self.checkBoxButton?.addTarget(self, action: .checkBoxButtonAction, for: .touchUpInside)
    }

    private func setupCheckBoxImageView() {
        self.checkBoxImageView = UIImageView(image: UIImage(named: "tick_white"))
        self.checkBoxImageView?.tintColor = TINT_COLOUR
        self.checkBoxImageView?.layer.borderColor = TINT_COLOUR.cgColor
        self.checkBoxImageView?.layer.borderWidth = 1.0
        self.checkBoxImageView?.layer.cornerRadius = 0.0
    }
    
    private func setupTitleLabel() {
        self.titleLabel = UILabel()
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.textAlignment = .left
    }
    
    private func setupDueDateLabel() {
        self.dueDateLabel = UILabel()
        self.dueDateLabel?.numberOfLines = 1
        self.dueDateLabel?.textAlignment = .left
    }
    
    private func setupSubviews() {
        self.setupCheckBoxButton()
        self.checkBoxButton?.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.checkBoxButton!)
        
        self.setupCheckBoxImageView()
        self.checkBoxImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.checkBoxButton?.addSubview(self.checkBoxImageView!)
        
        self.setupTitleLabel()
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.titleLabel!)
        
        self.setupDueDateLabel()
        self.dueDateLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.dueDateLabel!)
    }
    
    override func updateConstraints() {
        if (!self.hasLoadedConstraints) {
            let views: [String: Any] = ["button": self.checkBoxButton!,
                                        "image": self.checkBoxImageView!,
                                        "title": self.titleLabel!,
                                        "date": self.dueDateLabel!]
            
            let metrics = ["SPACING": GENERAL_SPACING,
                           "SMALL_SPACING": SMALL_SPACING,
                           "WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": GENERAL_ITEM_HEIGHT,
                           "SMALL_WIDTH": SMALL_ITEM_WIDTH,
                           "SMALL_HEIGHT": SMALL_ITEM_HEIGHT]
            
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[button(WIDTH)]-(SPACING)-[title]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[button(WIDTH)]-(SPACING)-[date]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[button]|", options: .directionMask, metrics: nil, views: views))

            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(SMALL_SPACING)-[title][date]-(SMALL_SPACING)-|", options: .directionMask, metrics: metrics, views: views))

            self.contentView.addConstraint(NSLayoutConstraint(item: self.checkBoxButton!, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            
            self.checkBoxButton!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[image(SMALL_WIDTH)]", options: .directionMask, metrics: metrics, views: views))
            
            self.checkBoxButton!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[image(SMALL_HEIGHT)]", options: .directionMask, metrics: metrics, views: views))
            
            self.checkBoxButton!.addConstraint(NSLayoutConstraint(item: self.checkBoxImageView!, attribute: .centerX, relatedBy: .equal, toItem: self.checkBoxButton!, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            
            self.checkBoxButton!.addConstraint(NSLayoutConstraint(item: self.checkBoxImageView!, attribute: .centerY, relatedBy: .equal, toItem: self.checkBoxButton!, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            
            self.hasLoadedConstraints = true
        }
        super.updateConstraints()
    }
    
    override class var requiresConstraintBasedLayout : Bool {
        return true
    }
}

private extension Selector {
    static let checkBoxButtonAction = #selector(TaskCell.checkBoxButtonAction)
}
