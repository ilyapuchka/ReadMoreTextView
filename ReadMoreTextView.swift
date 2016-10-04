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
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        isScrollEnabled = false
        isEditable = false
    }
    
    convenience init(frame: CGRect) {
        self.init(frame: frame, textContainer: nil)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero, textContainer: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isScrollEnabled = false
        isEditable = false
    }
    
    convenience init(maximumNumberOfLines: Int, trimText: NSString?, shouldTrim: Bool) {
        self.init()
        self.maximumNumberOfLines = maximumNumberOfLines
        self.trimText = trimText
        self.shouldTrim = shouldTrim
    }
    
    convenience init(maximumNumberOfLines: Int, attributedTrimText: NSAttributedString?, shouldTrim: Bool) {
        self.init()
        self.maximumNumberOfLines = maximumNumberOfLines
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
    
    var trimTextRangePadding: UIEdgeInsets = UIEdgeInsets.zero
    var appendTrimTextPrefix: Bool = true
    var trimTextPrefix: String = "..."
    
    fileprivate var originalText: String!
    
    override var text: String! {
        didSet {
            originalText = text
            originalAttributedText = nil
            if needsTrim() { updateText() }
        }
    }
    
    fileprivate var originalAttributedText: NSAttributedString!
    
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
        textContainer.size = CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
        
        let range = rangeToReplaceWithTrimText()
        if range.location != NSNotFound {
            let prefix = appendTrimTextPrefix ? trimTextPrefix : ""
            
            if let text = trimText?.mutableCopy() as? NSMutableString {
                text.insert("\(prefix) ", at: 0)
                textStorage.replaceCharacters(in: range, with: text as String)
            }
            else if let text = attributedTrimText?.mutableCopy() as? NSMutableAttributedString {
                text.insert(NSAttributedString(string: "\(prefix) "), at: 0)
                textStorage.replaceCharacters(in: range, with: text)
            }
        }
        invalidateIntrinsicContentSize()
    }
    
    func resetText() {
        textContainer.maximumNumberOfLines = 0
        if originalText != nil {
            textStorage.replaceCharacters(in: NSMakeRange(0, countElements(text!)), with: originalText)
        }
        else if originalAttributedText != nil {
            textStorage.replaceCharacters(in: NSMakeRange(0, countElements(text!)), with: originalAttributedText)
        }
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize : CGSize {
        textContainer.size = CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
        var intrinsicContentSize = layoutManager.boundingRect(forGlyphRange: layoutManager.glyphRange(for: textContainer), in: textContainer).size
        intrinsicContentSize.width = UIViewNoIntrinsicMetric
        intrinsicContentSize.height += (textContainerInset.top + textContainerInset.bottom)
        return intrinsicContentSize
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if needsTrim() && pointInTrimTextRange(point) {
            shouldTrim = false
            maximumNumberOfLines = 0
        }
        
        return super.hitTest(point, with: event)
    }
    
    //MARK: Private methods
    
    fileprivate var _trimText: NSString? {
        get {
            return trimText ?? attributedTrimText?.string as NSString?
        }
    }
    
    fileprivate var _trimTextPrefixLength: Int {
        get {
            return appendTrimTextPrefix ? countElements(trimTextPrefix) + 1 : 1
        }
    }
    
    fileprivate var _originalTextLength: Int {
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
    
    fileprivate func rangeToReplaceWithTrimText() -> NSRange {
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
    
    fileprivate func trimTextRange() -> NSRange {
        var trimTextRange = rangeToReplaceWithTrimText()
        if trimTextRange.location != NSNotFound {
            trimTextRange.length = _trimTextPrefixLength + _trimText!.length
        }
        return trimTextRange
    }
    
    fileprivate func pointInTrimTextRange(_ point: CGPoint) -> Bool {
        let offset = CGPoint(x: textContainerInset.left, y: textContainerInset.top)
        var boundingRect = layoutManager.boundingRectForCharacterRange(trimTextRange(), inTextContainer: textContainer, textContainerOffset: offset)
        boundingRect = boundingRect.offsetBy(dx: textContainerInset.left, dy: textContainerInset.top)
        boundingRect = boundingRect.insetBy(dx: -(trimTextRangePadding.left + trimTextRangePadding.right), dy: -(trimTextRangePadding.top + trimTextRangePadding.bottom))
        return boundingRect.contains(point)
    }
    
    func countElements(_ text: String) -> Int {
        return text.characters.count
    }
}

//MARK: NSLayoutManager extension

extension NSLayoutManager {
    
    func characterRangeThatFits(_ textContainer: NSTextContainer) -> NSRange {
        var rangeThatFits = self.glyphRange(for: textContainer)
        rangeThatFits = self.characterRange(forGlyphRange: rangeThatFits, actualGlyphRange: nil)
        return rangeThatFits
    }
    
    func boundingRectForCharacterRange(_ range: NSRange, inTextContainer textContainer: NSTextContainer, textContainerOffset: CGPoint) -> CGRect {
        let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        let boundingRect = self.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        return boundingRect
    }
    
}


