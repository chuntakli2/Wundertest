//
//  TaskCell.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

protocol TaskCellDelegate: class {
    
}

class TaskCell: UITableViewCell {
    
    weak var delegate: TaskCellDelegate?
    var indexPath = IndexPath()
    
    var titleLabel: UILabel?
    
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
    
    private func setupTitleLabel() {
        self.titleLabel = UILabel()
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.textAlignment = .center
    }
    
    private func setupSubviews() {
        self.setupTitleLabel()
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.titleLabel!)
    }
    
    override func updateConstraints() {
        if (!self.hasLoadedConstraints) {
            let views = ["title": self.titleLabel!]
            
            let metrics = ["SPACING": GENERAL_SPACING]
            
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(SPACING)-[title]-(SPACING)-|", options: .directionMask, metrics: metrics, views: views))
            
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[title]|", options: .directionMask, metrics: metrics, views: views))
            
            self.hasLoadedConstraints = true
        }
        super.updateConstraints()
    }
    
    override class var requiresConstraintBasedLayout : Bool {
        return true
    }
}

private extension Selector {
    
}
