//
//  webviewintegrationUITests.swift
//  webviewintegrationUITests
//
//  Created by robert.t.wan on 15/1/2021.
//  Copyright © 2021 Robert Wan. All rights reserved.
//

import XCTest

class webviewintegrationUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        try insertOneLine()
        try insertTwoLines()
        try insertOneLineAndClearAll()
    }
    
    func insertOneLine() throws {
        let app = XCUIApplication()
        app.launch()

        let textField = app.textFields["textField"]
        textField.tap()
        textField.typeText("Hello")
        
        let button = app.buttons["addButton"]
        button.tap()
        
        let webView = app.webViews.webViews.webViews
        
        XCTAssertTrue(webView.staticTexts["Hello"].exists)
    }
    
    func insertTwoLines() throws {
        let app = XCUIApplication()
        app.launch()

        let textField1 = app.textFields["textField"]
        textField1.tap()
        textField1.typeText("Hello")
        
        let button = app.buttons["addButton"]
        button.tap()
        
        let textField2 = app.textFields["textField"]
        textField2.tap()
        textField2.typeText("World")
        
        button.tap()
        
        let webView = app.webViews.webViews.webViews
     
        XCTAssertTrue(webView.staticTexts["Hello"].exists)
        XCTAssertTrue(webView.staticTexts["World"].exists)
    }
    
    func insertOneLineAndClearAll() throws {
        let app = XCUIApplication()
        app.launch()

        let textField1 = app.textFields["textField"]
        textField1.tap()
        textField1.typeText("Hello World")
        
        let button = app.buttons["addButton"]
        button.tap()
        
        let webView = app.webViews.webViews.webViews
        
        XCTAssertTrue(webView.staticTexts["Hello World"].exists)
        
        webView.buttons["Clear All"].tap()
        
        XCTAssertFalse(webView.staticTexts["Hello World"].exists)
    }
    
    func log(webView: XCUIElementQuery) -> String {
        var string = ""
        let elements = webView.staticTexts.allElementsBoundByIndex
        for i in 0 ..< elements.count {
            if (i == 0) {
                string += "\(elements[i].label)"
            } else {
                string += "\n\(elements[i].label)"
            }
        }
        return string
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
