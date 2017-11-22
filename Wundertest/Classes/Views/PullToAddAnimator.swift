//
//  PullToAddAnimator.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import PullToRefresh

class PullToAddAnimator: RefreshViewAnimator {
    
    private let pullToAddView: PullToAddView
    
    init(pullToAddView: PullToAddView) {
        self.pullToAddView = pullToAddView
    }
    
    func animate(_ state: State) {
        switch state {
        case .initial:
            self.pullToAddView.addView.transform = .identity
            self.pullToAddView.addView.alpha = 0.0
            
        case .releasing(let progress):
            self.pullToAddView.addView.transform = CGAffineTransform(scaleX: progress, y: progress)
            self.pullToAddView.addView.alpha = ((progress < 1.0) ? progress : 1.0)
            
        case .loading:
            break
            
        case .finished:
            break
        }
    }
}
