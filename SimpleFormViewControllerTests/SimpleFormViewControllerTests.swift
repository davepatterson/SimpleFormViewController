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
    }

    override func tearDown() {
        super.tearDown()
    }

    // Single text field should represent each registered value
    func testRegisteringTextFields() {
        let form = ASimpleForm()
        form.registerTextField(fieldTitle: .firstName)
        form.registerTextField(fieldTitle: .lastName)
        form.registerTextField(fieldTitle: .phoneNumber)
        form.registerTextField(fieldTitle: .zipCode)

        do {
            for i in 0..<form.numberOfFields() {
                let view = try form.viewAtIndex(i)
                assert(view is FormTextField)
                if i == 2 {
                    // input type should be phone pad
                    assert((view as! FormTextField).keyboardType == .phonePad)
                } else if i == 3 {
                    // input type should be number pad
                    assert((view as! FormTextField).keyboardType == .numberPad)
                }
            }
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    // When date field is registered an accompanying label should be added to represent date.
    // Date picker should be initially hidden
    func testRegisteringDateField() {
        let form = ASimpleForm()
        form.registerDateField(fieldTitle: .dob)

        do {
            let view0 = try form.viewAtIndex(0)
            assert(view0 is FormLabel)

            let view1 = try form.viewAtIndex(1)
            assert(view1 is FormDatePicker)
            assert((view1 as! FormDatePicker).isHidden == true)

        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    // Making sure fields allow interaction by default
    func testFieldInteractionInitiallyEnabled() {
        let form = ASimpleForm()
        form.registerTextField(fieldTitle: .firstName)
        form.registerTextField(fieldTitle: .lastName)
        form.registerDateField(fieldTitle: .dob)

        do {
            for i in 0..<form.numberOfFields() {
                let view = try form.viewAtIndex(i)
                assert(view.isUserInteractionEnabled == true)
            }
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    // Making sure fields do not allow interaction
    func testFieldInteractionDisabledEditableToggled() {
        let form = ASimpleForm()
        form.registerTextField(fieldTitle: .firstName)
        form.registerTextField(fieldTitle: .lastName)
        form.registerDateField(fieldTitle: .dob)

        // Edit is initally enabled so disable it
        form.toggleEditable()
        do {
            for i in 0..<form.numberOfFields() {
                let view = try form.viewAtIndex(i)
                assert(view.isUserInteractionEnabled == false)
            }
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    // Footer View (table) should be set when view is applied to footer
    func testSettingFooterView() {
        let form = ASimpleForm()
        form.registerTextField(fieldTitle: .firstName)

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        button.setTitle("A Button", for: .normal)
        form.setFooterView(button)

        assert(form.tableView.tableFooterView == button)
    }

    // Making sure field is populated with default value
    func testRegisteringFieldWithDefaultValue() {
        let form = ASimpleForm()
        form.registerTextField(fieldTitle: .firstName, defaultValue: "Blu")

        do {
            let view = try form.viewAtIndex(0)
            assert((view as! FormTextField).text == "Blu")
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    // Quick test of phone number mask
    func testPhoneNumberMask() {
        let number1 = "7731234567"
        let maskedNumber = format(phoneNumber: number1)
        assert(maskedNumber == "(773) 123-4567")
    }

}
