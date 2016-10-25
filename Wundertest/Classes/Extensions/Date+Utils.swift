//
//  Date+Utils.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import Foundation

extension Date {
    
    // MARK: - Public Methods
    
    public static func getCurrentTimestampInMilliseconds() -> Int {
        return Int(Date().timeIntervalSince1970 * 1000)
    }
}
