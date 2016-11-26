[![Version](https://img.shields.io/cocoapods/v/ReadMoreTextView.svg?style=flat)](http://cocoapods.org/pods/ReadMoreTextView)
[![License](https://img.shields.io/cocoapods/l/ReadMoreTextView.svg?style=flat)](http://cocoapods.org/pods/ReadMoreTextView)
[![Platform](https://img.shields.io/cocoapods/p/ReadMoreTextView.svg?style=flat)](http://cocoapods.org/pods/ReadMoreTextView)
[![Swift Version](https://img.shields.io/badge/Swift-2.3--3.0-F16D39.svg?style=flat)](https://developer.apple.com/swift)

# ReadMoreTextView

UITextView subclass with "read more"/"read less" capabilities.

![](screenshot.png)

##Usage

	let textView = ReadMoreTextView()

	textView.text = "Lorem ipsum dolor ..."

	textView.shouldTrim = true
	textView.maximumNumberOfLines = 4
	textView.readMoreText = "... Read more"
	textView.readLessText = " Read less"


##Installation

Available in [Cocoa Pods](https://github.com/CocoaPods/CocoaPods):

	pod 'ReadMoreTextView'

##License

ReadMoreTextView is available under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
