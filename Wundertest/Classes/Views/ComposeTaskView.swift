//
//  ComposeTaskView.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

protocol ComposeTaskViewDelegate: class {
    func composed(task: Task)
}

class ComposeTaskView: UIView {
    
    weak var delegate: ComposeTaskViewDelegate?
    
    
}
