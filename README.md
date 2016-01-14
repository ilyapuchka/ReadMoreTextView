[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

# ReadMoreTextView

UITextView subclass with "Read more" behavior.

##Usage

	let textView = ReadMoreTextView()

	textView.text = "Lorem ipsum dolor ..."

	textView.shouldTrim = true
	textView.maximumNumberOfLines = 3
	textView.trimText = "Read more"


##Installation

Available in [Cocoa Pods](https://github.com/CocoaPods/CocoaPods):

	pod 'ReadMoreTextView'

##License

ReadMoreTextView is available under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
