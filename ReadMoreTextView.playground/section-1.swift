//
//  TextView.playground
//
//
//  Created by Ilya Puchka on 04.04.15.
//
//

import UIKit
import XCPlayground

@IBDesignable
class ReadMoreTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        scrollEnabled = false
        editable = false
    }
    
    convenience init(frame: CGRect) {
        self.init(frame: frame, textContainer: nil)
    }
    
    convenience init() {
        self.init(frame: CGRectZero, textContainer: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollEnabled = false
        editable = false
    }
    
    convenience init(maximumNumberOfLines: Int, trimText: NSString?, shouldTrim: Bool) {
        self.init()
        self.maximumNumberOfLines = maximumNumberOfLines
        self.trimText = trimText
        self.shouldTrim = shouldTrim
    }
    
    convenience init(maximumNumberOfLines: Int, attributedTrimText: NSAttributedString?, shouldTrim: Bool) {
        self.init()
        self.maximumNumberOfLines =  maximumNumberOfLines
        self.attributedTrimText = attributedTrimText
        self.shouldTrim = shouldTrim
    }
    
    @IBInspectable
    var maximumNumberOfLines: Int = 0 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable
    var trimText: NSString? {
        didSet { setNeedsLayout() }
    }
    
    var attributedTrimText: NSAttributedString? {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable
    var shouldTrim: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    var trimTextRangePadding: UIEdgeInsets = UIEdgeInsetsZero
    var appendTrimTextPrefix: Bool = true
    var trimTextPrefix: String = "..."
    
    private var originalText: String!
    
    override var text: String! {
        didSet {
            originalText = text
            originalAttributedText = nil
            if needsTrim() { updateText() }
        }
    }
    
    private var originalAttributedText: NSAttributedString!
    
    override var attributedText: NSAttributedString! {
        didSet {
            originalAttributedText = attributedText
            originalText = nil
            if needsTrim() { updateText() }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        needsTrim() ? updateText() : resetText()
    }
    
    func needsTrim() -> Bool {
        return shouldTrim && _trimText != nil
    }
    
    func updateText() {
        textContainer.maximumNumberOfLines = maximumNumberOfLines
        textContainer.size = CGSizeMake(bounds.size.width, CGFloat.max)
        
        var range = rangeToReplaceWithTrimText()
        if range.location != NSNotFound {
            let prefix = appendTrimTextPrefix ? trimTextPrefix : ""
            
            if let text = trimText?.mutableCopy() as? NSMutableString {
                text.insertString("\(prefix) ", atIndex: 0)
                textStorage.replaceCharactersInRange(range, withString: text as String)
            }
            else if let text = attributedTrimText?.mutableCopy() as? NSMutableAttributedString {
                text.insertAttributedString(NSAttributedString(string: "\(prefix) "), atIndex: 0)
                textStorage.replaceCharactersInRange(range, withAttributedString: text)
            }
        }
        invalidateIntrinsicContentSize()
    }
    
    func resetText() {
        textContainer.maximumNumberOfLines = 0
        if originalText != nil {
            textStorage.replaceCharactersInRange(NSMakeRange(0, countElements(text!)), withString: originalText)
        }
        else if originalAttributedText != nil {
            textStorage.replaceCharactersInRange(NSMakeRange(0, countElements(text!)), withAttributedString: originalAttributedText)
        }
        invalidateIntrinsicContentSize()
    }
    
    override func intrinsicContentSize() -> CGSize {
        textContainer.size = CGSizeMake(bounds.size.width, CGFloat.max)
        var intrinsicContentSize = layoutManager.boundingRectForGlyphRange(layoutManager.glyphRangeForTextContainer(textContainer), inTextContainer: textContainer).size
        intrinsicContentSize.width = UIViewNoIntrinsicMetric
        intrinsicContentSize.height += (textContainerInset.top + textContainerInset.bottom)
        return intrinsicContentSize
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        if needsTrim() && pointInTrimTextRange(point) {
            shouldTrim = false
            maximumNumberOfLines = 0
        }
        
        return super.hitTest(point, withEvent: event)
    }
    
    //MARK: Private methods
    
    private var _trimText: NSString? {
        get {
            return trimText ?? attributedTrimText?.string
        }
    }
    
    private var _trimTextPrefixLength: Int {
        get {
            return appendTrimTextPrefix ? countElements(trimTextPrefix) + 1 : 1
        }
    }
    
    private var _originalTextLength: Int {
        get {
            if originalText != nil {
                return countElements(originalText!)
            }
            else  if originalAttributedText != nil {
                return originalAttributedText!.length
            }
            return 0
        }
    }
    
    private func rangeToReplaceWithTrimText() -> NSRange {
        let emptyRange = NSMakeRange(NSNotFound, 0)
        
        var rangeToReplace = layoutManager.characterRangeThatFits(textContainer)
        if NSMaxRange(rangeToReplace) == _originalTextLength {
            rangeToReplace = emptyRange
        }
        else {
            rangeToReplace.location = NSMaxRange(rangeToReplace) - _trimText!.length - _trimTextPrefixLength
            if rangeToReplace.location < 0 {
                rangeToReplace = emptyRange
            }
            else {
                rangeToReplace.length = textStorage.length - rangeToReplace.location
            }
        }
        return rangeToReplace
    }
    
    private func trimTextRange() -> NSRange {
        var trimTextRange = rangeToReplaceWithTrimText()
        if trimTextRange.location != NSNotFound {
            trimTextRange.length = _trimTextPrefixLength + _trimText!.length
        }
        return trimTextRange
    }
    
    private func pointInTrimTextRange(point: CGPoint) -> Bool {
        let offset = CGPointMake(textContainerInset.left, textContainerInset.top)
        var boundingRect = layoutManager.boundingRectForCharacterRange(trimTextRange(), inTextContainer: textContainer, textContainerOffset: offset)
        boundingRect = CGRectOffset(boundingRect, textContainerInset.left, textContainerInset.top)
        boundingRect = CGRectInset(boundingRect, -(trimTextRangePadding.left + trimTextRangePadding.right), -(trimTextRangePadding.top + trimTextRangePadding.bottom))
        return CGRectContainsPoint(boundingRect, point)
    }
    
    func countElements(text: String) -> Int {
        return text.characters.count
    }
}

//MARK: NSLayoutManager extension

extension NSLayoutManager {
    
    func characterRangeThatFits(textContainer: NSTextContainer) -> NSRange {
        var rangeThatFits = self.glyphRangeForTextContainer(textContainer)
        rangeThatFits = self.characterRangeForGlyphRange(rangeThatFits, actualGlyphRange: nil)
        return rangeThatFits
    }
    
    func boundingRectForCharacterRange(range: NSRange, inTextContainer textContainer: NSTextContainer, textContainerOffset: CGPoint) -> CGRect {
        let glyphRange = self.glyphRangeForCharacterRange(range, actualCharacterRange: nil)
        let boundingRect = self.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer)
        return boundingRect
    }
    
}


func createView(textView: UITextView) -> UIView {
    
    let view = UIView(frame: UIScreen.mainScreen().bounds)
    view.backgroundColor = UIColor.greenColor()

    textView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(textView)
    let metrics = ["padding": 20]
    
    view.addConstraints(NSLayoutConstraint
        .constraintsWithVisualFormat("V:|-padding-[textView]-(>=padding)-|",
            options: NSLayoutFormatOptions.AlignAllCenterX,
            metrics: metrics,
            views: ["textView": textView]))
    
    view.addConstraints(NSLayoutConstraint
        .constraintsWithVisualFormat("H:|-padding-[textView]-padding-|",
            options: NSLayoutFormatOptions.AlignAllCenterX,
            metrics: metrics,
            views: ["textView": textView]))
    
    return view
}

let trimText = NSAttributedString(string: "Read more", attributes: [NSForegroundColorAttributeName: UIColor.blueColor()])
let textView = ReadMoreTextView(maximumNumberOfLines: 3, attributedTrimText: trimText, shouldTrim: true)

textView.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."

XCPlaygroundPage.currentPage.liveView = createView(textView)

















