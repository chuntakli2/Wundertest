//
//  WundertestUITests.swift
//  WundertestUITests
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import XCTest

class WundertestUITests: XCTestCase {
    
    var app = XCUIApplication()

    override func setUp() {
        super.setUp()
        
        self.continueAfterFailure = false;
        self.app.launchEnvironment = ["animations": "0"]
        self.app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        self.app.terminate()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
