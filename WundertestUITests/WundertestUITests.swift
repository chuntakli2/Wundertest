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
    
    func testCreateTask() {
        let toolbar = self.app.toolbars.element(boundBy: 0)
        let toolbarButtons = toolbar.buttons
        for index in 0...(toolbarButtons.count - 1) {
            let button = toolbarButtons.element(boundBy: index)
            if (button.label == "Add") {
                button.tap()
                break
            }
        }
        
        let textView = self.app.textViews.element(boundBy: 0)
        textView.typeText("UI Testing")
        let buttons = self.app.buttons
        for index in 0...(buttons.count - 1) {
            let button = buttons.element(boundBy: index)
            if (button.label == "Save") {
                button.tap()
                break
            }
        }
        let tableView = self.app.tables.element(boundBy: 0)
        let count = tableView.cells.count
        XCTAssertGreaterThan(count, 0, "Should contain some tasks")
        let staticTexts = tableView.staticTexts
        var isFound = false
        for index in 0...(staticTexts.count - 1) {
            let staticText = staticTexts.element(boundBy: index)
            if (staticText.label == "UI Testing") {
                isFound = true
                break
            }
        }
        XCTAssertTrue(isFound, "Found new created task")
    }
}
