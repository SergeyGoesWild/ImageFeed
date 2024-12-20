//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Sergey Telnov on 19/10/2024.
//

import XCTest

class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    // Вставить логин здесь
    private let login = " "
    // Вставить пароль здесь
    private let pass = " "
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        goThroughAuth()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        goThroughAuth()
        
        sleep(2)
        let tablesQuery = app.tables
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5), "CellToLike not found")
        let likeButton = cellToLike.buttons["like button"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5), "LikeButton not found")
        sleep(2)
       
        cellToLike.tap()
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        goThroughAuth()
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        XCTAssertTrue(app.staticTexts["@username"].exists)
        XCTAssertTrue(app.buttons["logout button"].exists)
    }
    
    func goThroughAuth() {
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        webView.swipeUp()
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5), "Password field not found")
        passwordTextField.tap()
        passwordTextField.typeText(pass)
        webView.swipeUp()
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5), "Login field not found")
        loginTextField.tap()
        loginTextField.typeText(login)
        webView.buttons["Login"].tap()
        sleep(4)
    }
}
