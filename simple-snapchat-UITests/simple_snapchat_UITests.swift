//
//  simple_snapchat_UITests.swift
//  simple-snapchat-UITests
//
//  Created by Changchang on 12/2/17.
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

import XCTest

class simple_snapchat_UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testLogin() {
        
        
        let app = XCUIApplication()
        
        app.buttons["Login"].tap()
        
        let emailAddressTextField = app.textFields["Email address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("test1@gmail.com")
        
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("12341234")
        let loginButton = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button)["Login"]
        loginButton.tap()
        
        sleep(3)
        
        XCTAssertEqual(loginButton.exists, false)
        
    }
    
    func testRegister() {
        
        //Test with blank form
        let app = XCUIApplication()
        
        let scrollViewsQuery = app.scrollViews.otherElements.scrollViews
        scrollViewsQuery.otherElements.containing(.button, identifier:"Flash off").children(matching: .other).element.swipeDown()
        scrollViewsQuery.otherElements.buttons["logout"].tap()
        
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button)["Register"].tap()
        
        XCTAssert(XCUIApplication().alerts["Invalid Form"].exists)
        
        app.alerts["Invalid Form"].buttons["OK"].tap()
        
        //Test with the wrong email format
        let nameTextField = XCUIApplication().textFields["Name"]
        nameTextField.tap()
        nameTextField.typeText("John")
        
        let emailAddressTextField = XCUIApplication().textFields["Email address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("John")
        
        
        let passwordSecureTextField = XCUIApplication().secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("1234")
        
        XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button)["Register"].tap()
        
        XCTAssert(XCUIApplication().alerts["Invalid Email"].exists)
        XCUIApplication().alerts["Invalid Email"].buttons["OK"].tap()
        
    }
}
