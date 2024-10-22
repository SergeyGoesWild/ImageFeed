//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Sergey Telnov on 19/10/2024.
//

import XCTest

class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        webView.swipeUp()
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        // Вставить пароль здесь
        passwordTextField.typeText(" ")
        webView.swipeUp()
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        // Вставить логин здесь
        loginTextField.typeText(" ")
        webView.buttons["Login"].tap()
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        webView.swipeUp()
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        passwordTextField.tap()
        // Вставить пароль здесь
        passwordTextField.typeText(" ")
        webView.swipeUp()
        let loginTextField = webView.descendants(matching: .textField).element
        loginTextField.tap()
        // Вставить логин здесь
        loginTextField.typeText(" ")
        webView.buttons["Login"].tap()
        
        sleep(4)
        
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["like button"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1)
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        webView.swipeUp()
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        passwordTextField.tap()
        // Вставить пароль здесь
        passwordTextField.typeText(" ")
        webView.swipeUp()
        let loginTextField = webView.descendants(matching: .textField).element
        loginTextField.tap()
        // Вставить логин здесь
        loginTextField.typeText(" ")
        webView.buttons["Login"].tap()
        
        sleep(4)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        XCTAssertTrue(app.staticTexts["@username"].exists)
        XCTAssertTrue(app.buttons["logout button"].exists)
    }
}
