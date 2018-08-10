//
//  SimpleFormViewControllerTests.swift
//  SimpleFormViewControllerTests
//
//  Created by David Patterson on 8/9/18.
//  Copyright © 2018 David Patterson. All rights reserved.
//

import XCTest
@testable import SimpleFormViewController

class ASimpleForm: SimpleFormViewController {}

class SimpleFormViewControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFieldAddFields() {
        let form = ASimpleForm()
        form.registerTextField(fieldTitle: .firstName)
        form.registerTextField(fieldTitle: .lastName)
        
        assert(form.fields.keys.count == 2, "There should be two fields")
    }
    
    func testSetTitleWhenNoNavigationControllerFails() {
        let form = ASimpleForm()
        form.setTitle("A title")
        
    }
    
    
    
}
