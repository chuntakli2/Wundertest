//
//  TaskSectionHeaderView.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

protocol TaskSectionHeaderViewDelegate: class {
    func toggleClicked(section: Int)
}

class TaskSectionHeaderView: UITableViewHeaderFooterView {
    
    weak var delegate: TaskSectionHeaderViewDelegate?
    var section = 0
    
    var titleLabel: UILabel?
    var toggleButton: UIButton?
    
    private var isExpanded = false

    private var hasLoadedConstraints = false
    
    // MARK: - Initialisation
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
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
    
    func toggleButtonAction() {
        self.isExpanded = !self.isExpanded
        let headerTitle = (self.isExpanded ? "Hide Completed" : "Show Completed")
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            self.titleLabel?.attributedText = NSAttributedString(string: headerTitle, attributes: FONT_ATTR_MEDIUM_BLACK)
        })
        self.delegate?.toggleClicked(section: self.section)
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.contentView.translatesAutoresizingMaskIntoConstraints = true
        self.setupSubviews()
    }
    
    // MARK: - Subviews
    
    private func setupTitleLabel() {
        self.titleLabel = UILabel()
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.textAlignment = .center
    }
    
    private func setupToggleButton() {
        self.toggleButton = UIButton(type: .system)
        self.toggleButton?.addTarget(self, action: .toggleButtonAction, for: .touchUpInside)
    }
    
    private func setupSubviews() {
        self.setupTitleLabel()
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.titleLabel!)
        
        self.setupToggleButton()
        self.toggleButton?.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.toggleButton!)
    }
    
    override func updateConstraints() {
        if (!self.hasLoadedConstraints) {
            let views: [String: Any] = ["title": self.titleLabel!,
                                        "toggle": self.toggleButton!]
            
            let metrics = ["SPACING": GENERAL_SPACING,
                           "SMALL_SPACING": SMALL_SPACING,
                           "LARGE_SPACING": LARGE_SPACING,
                           "WIDTH": GENERAL_ITEM_WIDTH,
                           "HEIGHT": GENERAL_ITEM_HEIGHT]
            
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[title]|", options: .directionMask, metrics: metrics, views: views))
            
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[toggle]|", options: .directionMask, metrics: metrics, views: views))
            
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(SPACING)-[title]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[toggle]|", options: .directionMask, metrics: metrics, views: views))
            
            self.hasLoadedConstraints = true
        }
        super.updateConstraints()
    }
    
    override class var requiresConstraintBasedLayout : Bool {
        return true
    }
}

private extension Selector {
    static let toggleButtonAction = #selector(TaskSectionHeaderView.toggleButtonAction)
}
