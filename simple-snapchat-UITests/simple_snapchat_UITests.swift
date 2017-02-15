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
    
    
    func testLoginAndRegister() {
        
        let app = XCUIApplication()
        
        //Test Login
        
        checkWhetherLogin()
        
        app.buttons["Login"].tap()
        
        //Test with blank form
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button)["Login"].tap()
        
        XCTAssert(XCUIApplication().alerts["Invalid Form"].exists)
        app.alerts["Invalid Form"].buttons["OK"].tap()
        
        //Test with a wrong combination of email and password
        var emailAddressTextField = app.textFields["Email address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("simulator@anz.com")
        
        
        var passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("55555555")
        var loginButton = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button)["Login"]
        loginButton.tap()
        
        sleep(3)
        
        XCTAssert(XCUIApplication().alerts["Wrong Password"].exists)
        XCUIApplication().alerts["Wrong Password"].buttons["OK"].tap()

        
        //Test with the a successful login
        passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.clearAndEnterText(text: "12341234")
        
        loginButton = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button)["Login"]
        loginButton.tap()
        
        sleep(3)
        
        XCTAssertEqual(loginButton.exists, false)
        
        checkWhetherLogin()
        
        //Test register
        
        //Test with the email which already exist
        var nameTextField = XCUIApplication().textFields["Name"]
        nameTextField.tap()
        nameTextField.typeText("iphone")
        
        emailAddressTextField = XCUIApplication().textFields["Email address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("iphone@anz.com")
        
        
        passwordSecureTextField = XCUIApplication().secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("12341234")
        
        XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button)["Register"].tap()
        
        sleep(2)
        XCTAssert(XCUIApplication().alerts["Email Already Registered"].exists)
        XCUIApplication().alerts["Email Already Registered"].buttons["OK"].tap()
        
        //Test with the email with wrong format
        nameTextField = XCUIApplication().textFields["Name"]
        nameTextField.tap()
        nameTextField.clearAndEnterText(text: "Test1")
        
        emailAddressTextField = XCUIApplication().textFields["Email address"]
        emailAddressTextField.tap()
        emailAddressTextField.clearAndEnterText(text: "test1@anz")
        
        
        passwordSecureTextField = XCUIApplication().secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.clearAndEnterText(text: "12341234")
        
        XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button) ["Register"].tap()
        
        sleep(2)
        XCTAssert(XCUIApplication().alerts["Invalid Email"].exists)
        XCUIApplication().alerts["Invalid Email"].buttons["OK"].tap()
        
        //Test with the a successful registration
//        nameTextField = XCUIApplication().textFields["Name"]
//        nameTextField.tap()
//        nameTextField.clearAndEnterText(text: "Test1")
        
        emailAddressTextField = XCUIApplication().textFields["Email address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText(".com")
        
        
//        passwordSecureTextField = XCUIApplication().secureTextFields["Password"]
//        passwordSecureTextField.tap()
//        passwordSecureTextField.clearAndEnterText(text: "12341234")
        
        let registerButton = XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button) ["Register"]
        registerButton.tap()
        
        sleep(6)
        
        XCTAssertEqual(registerButton.exists, false)
        
    }
    
    func checkWhetherLogin() {
        if (!XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button) ["Register"].exists) {
            let scrollViewsQuery = XCUIApplication().scrollViews.otherElements.scrollViews
            scrollViewsQuery.otherElements.containing(.button, identifier:"Flash off").children(matching: .other).element.swipeDown()
            scrollViewsQuery.otherElements.buttons["logout"].tap()
        }
    }
    
}

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) -> Void {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        self.tap()
        
        let deleteString = stringValue.characters.map { _ in XCUIKeyboardKeyDelete }.joined(separator: "")
        
        self.typeText(deleteString)
        self.typeText(text)
    }
}


