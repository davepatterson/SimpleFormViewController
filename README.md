SimpleFormViewController
========================

`SimpleFormViewController` is meant to simplify creating basic forms that are used to submit data.

![image_1](https://user-images.githubusercontent.com/8164764/44277574-c6020e00-a210-11e8-933b-e35cdd7e6bca.jpeg)
 &nbsp;&nbsp; ![image_2](https://user-images.githubusercontent.com/8164764/44277584-cbf7ef00-a210-11e8-9775-ca541843f5e4.jpeg) &nbsp;&nbsp;

## Installation

### [CocoaPods](https://cocoapods.org/) (recommended)

```ruby
# Podfile
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
swift_version = '4.0'
use_frameworks!

pod 'SimpleFormViewController', :git => 'https://github.com/davepatterson/SimpleFormViewController', :branch => 'master'
```

Install into your project:

```bash
$ pod install
```

## Core Concept
Register a form field (either TextField or DateField) of a certain type (firstName, lastName, dob, phoneNumber, zipCode)

## Usage

Add framework using `import SimpleFormViewController` in your `.swift` files.

Make your UIViewController a subclass of `SimpleFormViewController`.

``` swift
class MyViewController: SimpleFormViewController, SimpleFormViewControllerDelegate {}
```

Register form fields in `ViewDidLoad`.

```swift
registerTextField(fieldTitle: .firstName)
registerTextField(fieldTitle: .lastName)
registerDateField(fieldTitle: .dob)
registerTextField(fieldTitle: .phoneNumber)
registerTextField(fieldTitle: .zipCode)
```

## Handling when form data is submitted

```swift
// Set delegate of form
delegate = self
```

Implement delegate method that returns form data.

```swift
func handleFormValues(_ fieldsDict: [String : String]) {
	// Do whatever with form data that is fieldsdDict
}
```

When `SimpleFormViewController` subclass is embeded in `UINavigationController` you are able to set right button and title.

In `viewDidLoad`.

```swift
let submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(yourSubmitMethod))
setRightButtonItem(submitButton)
setTitle("Add Contact")
```

Be sure to call `submitFormData()` in `yourSubmitMethod` as it will trigger delegate method that returns fields values.


