#CHANGELOG

##3.0.1

- Swift 4.2 support
- use `utf16` symbols count to place more & less buttons correctly in the HTML page.

##3.0.0

- Swift 4 support

##2.0.0

- dropped Swift 2.3 support
- improved logic around size change callback

##1.2.1

- fixed regression causing infinite layout loop

##1.2.0

- fixed loosing data detector info when updating text
- moved helper methods to public UITextView extension to easily add custom handling for toucher in arbitrary text ranges

##1.1.0

- added `setNeedsUpdateTrim` method to force update trimming

### Fixed

- fixed typo in `onSizeChange` method name
- fixed setting attributed text on iOS 8
- fixed `hitTest`

##1.0.0

- added "read less" text capability
- added callback when content size changes
- added Swift 2.3 compatibility
- removed some unneeded methods and cleaned up code in general


##0.0.1

Initial release
