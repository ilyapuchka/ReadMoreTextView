//
//  TextView.swift
//  
//
//  Created by Ilya Puchka on 04.04.15.
//
//

import UIKit

@IBDesignable
class ReadMoreTextView: UITextView {
    
    @IBInspectable
    var maximumNumberOfLines: Int = 0 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable
    var trimText: NSString? {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable
    var shouldTrim: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    var trimTextRangePadding: UIEdgeInsets = UIEdgeInsetsZero
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        scrollEnabled = false
        editable = false
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame, textContainer: nil)
    }
    
    override convenience init() {
        self.init(frame: CGRectZero, textContainer: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollEnabled = false
        editable = false
    }
    
    convenience init(maximumNumberOfLines: Int, trimText: String?, shouldTrim: Bool) {
        self.init()
        self.maximumNumberOfLines = maximumNumberOfLines
        self.trimText = trimText
        self.shouldTrim = shouldTrim
    }
    
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
        return shouldTrim && trimText != nil
    }
    
    func updateText() {
        textContainer.maximumNumberOfLines = maximumNumberOfLines
        textContainer.size = CGSizeMake(bounds.size.width, CGFloat.max)
        
        var range = rangeToReplaceWithTrimText()
        if range.location != NSNotFound {
            textStorage.replaceCharactersInRange(range, withString: "... ".stringByAppendingString(trimText!))
        }
        invalidateIntrinsicContentSize()
    }
    
    func resetText() {
        textContainer.maximumNumberOfLines = 0
        if originalText != nil {
            text = originalText
        }
        else if originalAttributedText != nil {
            attributedText = originalAttributedText
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
    
    private func rangeToReplaceWithTrimText() -> NSRange {
        let emptyRange = NSMakeRange(NSNotFound, 0)
        
        var rangeToReplace = layoutManager.characterRangeThatFits(textContainer)
        if NSMaxRange(rangeToReplace) == originalTextLength() {
            rangeToReplace = emptyRange
        }
        else {
            rangeToReplace.location = NSMaxRange(rangeToReplace) - trimText!.length - 4
            if rangeToReplace.location < 0 {
                rangeToReplace = emptyRange
            }
            else {
                rangeToReplace.length = textStorage.length - rangeToReplace.location
            }
        }
        return rangeToReplace
    }
    
    private func originalTextLength() -> Int {
        return originalText != nil ? countElements(originalText!) : originalAttributedText!.length
    }
    
    private func trimTextRange() -> NSRange {
        var trimTextRange = rangeToReplaceWithTrimText()
        if trimTextRange.location != NSNotFound {
            trimTextRange.length = 4 + trimText!.length
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


