//
//  SimpleFormViewController.swift
//  ContactsApp
//
//  Created by David Patterson on 8/6/18.
//  Copyright © 2018 David Patterson. All rights reserved.
//

import UIKit

/**
 `Constants` represents unchanging values used by `SimpleFormViewController`
 */
fileprivate enum Constants {
    static let defaultRowHeight = CGFloat(40)
    static let defaultDatePickerRowHeight = CGFloat(157)
    static let defaultRowWidth = CGFloat(UIScreen.main.bounds.size.width)
    static let defaultTextInset = CGFloat(15)
    static let FormCellIdentifier = "FormCell"
}

public protocol SimpleFormViewControllerDelegate: class {
    func handleFormValues(_ fieldsDict: [String: String])
}

/**
 `DateFieldTitle` represents available selection of dateField titles a field can have.
 */
public enum DateFieldTitle: String {
    /// - dob: date of birth field
    case dob = "Date of Birth"
}

/**
 `TextFieldTitle` represents available selection of textField titles a field can have.
 */
public enum TextFieldTitle: String {
    /// - first name: first name field
    case firstName = "First Name"
    /// - last name: last name field
    case lastName = "Last Name"
    /// - zip code: zip code field
    case zipCode = "Zip Code"
    /// - phone number: phone number field
    case phoneNumber = "Phone Number"
}

/**
 `FormField` protocol defines what class needs to be displayable in Form
 */
public protocol FormField: class {
    var row: Int { get set }
    var rowHeight: Double { get set }
    var hasAccessoryRow: Bool { get set }
    var accessoryRowShowing: Bool { get set }
    var shouldDisplay: Bool { get set }
}

/**
 `FormTextField` is a subclass of UITextField that conforms to `FormField` protocol.
 */
internal class FormTextField: UITextField, FormField {
    var row: Int = 0
    var rowHeight: Double = 157.0
    var hasAccessoryRow: Bool = false
    var accessoryRowShowing: Bool = false
    var shouldDisplay: Bool = true
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: Constants.defaultTextInset, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: Constants.defaultTextInset, dy: 0)
    }
}

/**
 `FormLabel` is a subclass of UILabel that conforms to `FormField` protocol.
 */
internal class FormLabel: UILabel, FormField {
    var row: Int = 0
    var rowHeight: Double = 40.0
    var hasAccessoryRow: Bool = false
    var accessoryRowShowing: Bool = false
    var shouldDisplay: Bool = true
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 10, left: Constants.defaultTextInset, bottom: 10, right: 10))
        super.drawText(in: insets)
    }
}

/**
 `FormDatePicker` is a subclass of UIDatePicker that conforms to `FormField` protocol.
 */
internal class FormDatePicker: UIDatePicker, FormField {
    var row: Int = 0
    var rowHeight: Double = 40.0
    var hasAccessoryRow: Bool = false
    var accessoryRowShowing: Bool = false
    var shouldDisplay: Bool = true
}

func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
    guard !phoneNumber.isEmpty else { return "" }
    guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
    let r = NSString(string: phoneNumber).range(of: phoneNumber)
    var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")
    
    if number.count > 10 {
        let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
        number = String(number[number.startIndex..<tenthDigitIndex])
    }
    
    if shouldRemoveLastDigit {
        let end = number.index(number.startIndex, offsetBy: number.count-1)
        number = String(number[number.startIndex..<end])
    }
    
    if number.count < 7 {
        let end = number.index(number.startIndex, offsetBy: number.count)
        let range = number.startIndex..<end
        number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)
        
    } else {
        let end = number.index(number.startIndex, offsetBy: number.count)
        let range = number.startIndex..<end
        number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
    }
    
    return number
}

// MARK: - UITextField Delegate
extension SimpleFormViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.keyboardType == .phonePad {
            var fullString = textField.text ?? ""
            fullString.append(string)
            if range.length == 1 {
                textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
            } else {
                textField.text = format(phoneNumber: fullString)
            }
        }
        return false
    }
}

// MARK: - Table view data source
extension SimpleFormViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfFields()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FormCell(style: .default, reuseIdentifier: Constants.FormCellIdentifier)
        let dict = fields[indexPath.row]
        let field = dict![Array(dict!.keys)[0]]
        
        cell.selectionStyle = .none
        cell.setCell(field!)
        return cell
    }
    
}

// MARK: - Table view delegate
extension SimpleFormViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let dict = fields[indexPath.row]
        let field = dict![Array(dict!.keys)[0]] as! FormField
        
        if field is FormTextField {
            if field.shouldDisplay {
                return 40.0
            }
        } else if field is FormDatePicker {
            if field.shouldDisplay {
                return 157.0
            }
        } else if field is FormLabel {
            if field.shouldDisplay {
                return 40.0
            }
        }
        
        return 0.0
    }
}

/**
 `SimpleFormViewController` is controller used to display Form.
 */
open class SimpleFormViewController: UIViewController {
    // UITableView used to display fields
    internal var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: .plain)
    // Nested Dictionary (for maintaining order of fields) with inner Dictionary that expects
    // key to be field name and value to be field (subclass of UIView)
    internal var fields: [Int: [String: UIView]] = [:]
    // Delegate that is expected to handle form data
    public weak var delegate: SimpleFormViewControllerDelegate? = nil
    internal var allowEdits: Bool = true
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSimpleFormViewController()
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Method that allows user to disable/enable editing of fields.
     - parameter editable: `Bool` that determines if fields can be edited.
     */
    public func toggleEditable() {
        allowEdits = allowEdits ? false : true
        for i in 0..<numberOfFields() {
            fields[i]![fields[i]!.keys.first!]?.isUserInteractionEnabled = allowEdits
        }
        tableView.reloadData()
        // Make first field first responder to let user know editing is in progress
        if allowEdits {
            fields[0]![fields[0]!.keys.first!]?.becomeFirstResponder()
        }
    }
    
    /**
     Returns number of fields in form.
     */
    public func numberOfFields() -> Int {
        return Array(fields.keys).count
    }
    
    /**
     Configures view controller.
     */
    private func configureSimpleFormViewController() {
        // TableView setup
        tableView.register(FormCell.self, forCellReuseIdentifier: Constants.FormCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
    }
    
    /**
     Public method used to register text field to `SimpleFormViewController`.
     - parameter fieldTitle: `TextFieldTitle` of field being registered.
     */
    public func registerTextField(fieldTitle: TextFieldTitle, defaultValue: String = "") {
        switch fieldTitle {
        default:
            // Adds field of FormTextField type to fields nested dictionary
            let field = FormTextField(frame: CGRect(x: 0, y: 0, width: Constants.defaultRowWidth, height: Constants.defaultRowHeight))
            field.text = defaultValue
            if fieldTitle.rawValue == TextFieldTitle.zipCode.rawValue {
                // Force numberPad when zip code field
                field.keyboardType = .numberPad
            } else if fieldTitle.rawValue == TextFieldTitle.phoneNumber.rawValue {
                // Force phonePad when phone number field
                field.keyboardType = .phonePad
                field.delegate = self
            }
            field.placeholder = fieldTitle.rawValue
            field.row = fields.keys.count
            fields[fields.keys.count] = [fieldTitle.rawValue: field]
        }
    }
    
    /**
     Public method used to register text field to `SimpleFormViewController`.
     - parameter fieldTitle: `DateFieldTitle` of field being registered.
     */
    public func registerDateField(fieldTitle: DateFieldTitle, defaultValue: String = "") {
        switch fieldTitle {
        case .dob:
            // Adds label used to display date and datefield (date picker)
            let label = FormLabel(frame: CGRect(x: 0, y: 0, width: Constants.defaultRowWidth, height: Constants.defaultRowHeight))
            label.text = defaultValue.isEmpty ? fieldTitle.rawValue : prettyDate(dateFromString(defaultValue))
            // Used to hide/show datepicker
            let tap = UITapGestureRecognizer(target: self, action: #selector(presentDateLabelAccessoryField(tap:)))
            label.addGestureRecognizer(tap)
            label.isUserInteractionEnabled = true
            label.row = fields.keys.count
            label.hasAccessoryRow = true
            fields[label.row] = [fieldTitle.rawValue: label]
            
            let datePicker = FormDatePicker(frame: CGRect(x: 0, y: 0, width: Constants.defaultRowWidth, height: Constants.defaultDatePickerRowHeight))
            datePicker.addTarget(self, action: #selector(updateDateLabel), for: .valueChanged)
            datePicker.isHidden = true
            datePicker.shouldDisplay = false
            datePicker.datePickerMode = .date
            datePicker.row = fields.keys.count
            fields[fields.keys.count] = [fieldTitle.rawValue: datePicker]
        }
    }
    
    /**
     Public method used to set the title of `SimpleFormViewController`
     - parameter titleString: `String` of title text.
     */
    public func setTitle(_ titleString: String) {
        guard navigationController != nil else {
            fatalError("You must embed SimpleFormViewController in UINavigationController to set its title.")
        }
        
        // Set title
        navigationItem.title = titleString
    }
    
    /**
     Public method used to set the left button item of `SimpleFormViewController`
     - parameter barButtonItem: Instance to be set to right button.
     */
    public func setLeftButtonItem(_ barButtonItem: UIBarButtonItem) {
        guard navigationController != nil else {
            fatalError("You must embed SimpleFormViewController in UINavigationController to set its title.")
        }
        
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    /**
     Public method used to set the right button item of `SimpleFormViewController`
     - parameter barButtonItem: Instance to be set to right button.
     */
    public func setRightButtonItem(_ barButtonItem: UIBarButtonItem) {
        guard navigationController != nil else {
            fatalError("You must embed SimpleFormViewController in UINavigationController to set its title.")
        }
        
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    public func setFooterView(_ view: UIView) {
        tableView.tableFooterView = view
    }
    
    /**
     Private method used to convert UIDate to pretty date.
     - parameter date: `Date` that will be converted to human friendly string.
     - returns: `String` that is easy on human eyes.
     */
    private func prettyDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: date)
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "MM/dd/yyyy"
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)
        
        return myStringafd
    }
    
    /**
     Used to covert saved date string to `Date` object.
     - parameter string: `String` that will be converted to `Date` object.
     - returns: `Date`
     */
    private func dateFromString(_ string: String) -> Date {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
        
        return dateFormatter.date(from: string)!
    }
    
    /**
     Private method used to update label associated with date picker.
     - parameter datePicker: `FormDatePicker` that is used to toggle date.
     */
    @objc private func updateDateLabel(_ datePicker: FormDatePicker) {
        let labelText = prettyDate(datePicker.date)
        let dict = fields[datePicker.row - 1]
        let prevField = dict![Array(dict!.keys)[0]] as! FormLabel
        prevField.text = labelText
    }
    /**
     Private method used to present accessory of Label when label field is touched
     - parameter tap: UITapGestureRecognizer that is used to intercept touches of label.
     */
    @objc private func presentDateLabelAccessoryField(tap: UITapGestureRecognizer) {
        // Labels might have accessory row
        if let field = tap.view as? FormLabel, field.hasAccessoryRow {
            tableView.beginUpdates()
            let dict = fields[field.row + 1]
            let field = dict![Array(dict!.keys)[0]] as! FormField
            field.shouldDisplay = field.shouldDisplay ? false : true
            (field as! UIView).isHidden = (field as! UIView).isHidden ? false : true
            tableView.reloadRows(at:[IndexPath(row: field.row, section: 0)], with: .automatic)
            tableView.endUpdates()
            
        }
    }
    
    /**
     Method used to submit form data. Sends submitted data to `SwiftFormViewController`.
     */
    public func submitFormData() {
        // Pass dictionary of type (fieldName: fieldValue) (String: String)
        var dict = [String: String]()
        
        for i in 0..<numberOfFields() {
            if let textField = fields[i]![fields[i]!.keys.first!] as? FormTextField {
                dict[fields[i]!.keys.first!] = textField.text!
            } else if let dateField = fields[i]![fields[i]!.keys.first!] as? FormDatePicker {
                let stringDate = "\(dateField.date)"
                dict[fields[i]!.keys.first!] = stringDate
            }
        }
        
        delegate?.handleFormValues(dict)
    }
}
