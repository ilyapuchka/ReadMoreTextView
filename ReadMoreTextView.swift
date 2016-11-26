//
//  ReadMoreTextView.swift
//  ReadMoreTextView
//
//  Created by Ilya Puchka on 06.04.15.
//  Copyright (c) 2015 Ilya Puchka. All rights reserved.
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
    
    convenience init(maximumNumberOfLines: Int, readMoreText: String?, readLessText: String? = nil, shouldTrim: Bool) {
        self.init()
        self.maximumNumberOfLines = maximumNumberOfLines
        self.readMoreText = readMoreText
        self.readLessText = readLessText
        self.shouldTrim = shouldTrim
    }
    
    convenience init(maximumNumberOfLines: Int, attributedReadMoreText: NSAttributedString?, attributedReadLessText: NSAttributedString? = nil, shouldTrim: Bool) {
        self.init()
        self.maximumNumberOfLines = maximumNumberOfLines
        self.attributedReadMoreText = attributedReadMoreText
        self.attributedReadLessText = attributedReadLessText
        self.shouldTrim = shouldTrim
    }
    
    var onSizeChage: (ReadMoreTextView)->() = { _ in }
    
    @IBInspectable
    var maximumNumberOfLines: Int = 0 {
        didSet {
            originalMaximumNumberOfLines = maximumNumberOfLines
            setNeedsLayout()
        }
    }
    
    fileprivate var originalMaximumNumberOfLines: Int = 0
    
    @IBInspectable
    var readMoreText: String? {
        didSet { setNeedsLayout() }
    }
    
    var attributedReadMoreText: NSAttributedString? {
        didSet { setNeedsLayout() }
    }

    @IBInspectable
    var readLessText: String? {
        didSet { setNeedsLayout() }
    }
    
    var attributedReadLessText: NSAttributedString? {
        didSet { setNeedsLayout() }
    }

    @IBInspectable
    var shouldTrim: Bool = false {
        didSet {
            if shouldTrim {
                maximumNumberOfLines = originalMaximumNumberOfLines
            } else {
                let _maximumNumberOfLines = maximumNumberOfLines
                maximumNumberOfLines = 0
                originalMaximumNumberOfLines = _maximumNumberOfLines
            }
            setNeedsLayout()
        }
    }
    
    var readMoreTextRangePadding: UIEdgeInsets = UIEdgeInsets.zero
    
    var appendReadMoreTextPrefix: Bool = true {
        didSet { setNeedsLayout() }
    }
    var readMoreTextPrefix: String = "..." {
        didSet { setNeedsLayout() }
    }

    var readLessTextRangePadding: UIEdgeInsets = UIEdgeInsets.zero
    
    var appendReadLessTextPrefix: Bool = true {
        didSet { setNeedsLayout() }
    }
    var readLessTextPrefix: String = "" {
        didSet { setNeedsLayout() }
    }

    fileprivate var originalText: String!
    
    override var text: String! {
        didSet {
            originalText = text
            originalAttributedText = nil
            if needsTrim() { showLessText() }
        }
    }
    
    fileprivate var originalAttributedText: NSAttributedString!
    
    override var attributedText: NSAttributedString! {
        didSet {
            originalAttributedText = attributedText
            originalText = nil
            if needsTrim() { showLessText() }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        needsTrim() ? showLessText() : showMoreText()
    }
    
    func needsTrim() -> Bool {
        return shouldTrim && _readMoreText != nil
    }

    func showLessText() {
        textContainer.maximumNumberOfLines = maximumNumberOfLines
        layoutManager.invalidateLayout(forCharacterRange: layoutManager.characterRangeThatFits(textContainer), actualCharacterRange: nil)
        textContainer.size = CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
        
        let range = rangeToReplaceWithReadMoreText()
        if range.location != NSNotFound {
            let prefix = appendReadMoreTextPrefix ? readMoreTextPrefix : ""
            
            if var text = readMoreText {
                text = "\(prefix) \(text)"
                textStorage.replaceCharacters(in: range, with: text as String)
            }
            else if let text = attributedReadMoreText?.mutableCopy() as? NSMutableAttributedString {
                text.insert(NSAttributedString(string: "\(prefix) "), at: 0)
                textStorage.replaceCharacters(in: range, with: text)
            }
        }
        invalidateIntrinsicContentSize()
        onSizeChage(self)
    }
    
    func showMoreText() {
        textContainer.maximumNumberOfLines = 0
        let prefix = appendReadLessTextPrefix ? readLessTextPrefix : ""
        if var originalText = originalText {
            if var readLessText = readLessText {
                readLessText = "\(prefix) \(readLessText)"
                originalText.append(readLessText)
                textStorage.replaceCharacters(in: NSRange(location: 0, length: text.length), with: originalText)
            } else if let attributedReadLessText = attributedReadLessText?.mutableCopy() as? NSMutableAttributedString {
                let originalTextAttributes = textStorage.attributes(at: 0, effectiveRange: nil)
                let originalAttributedText = NSMutableAttributedString(string: originalText, attributes: originalTextAttributes)
                attributedReadLessText.insert(NSAttributedString(string: "\(prefix) "), at: 0)
                originalAttributedText.append(attributedReadLessText)
                textStorage.replaceCharacters(in: NSRange(location: 0, length: text.length), with: originalAttributedText)
            } else {
                textStorage.replaceCharacters(in: NSRange(location: 0, length: text.length), with: originalText)
            }
        }
        else if let originalAttributedText = originalAttributedText.mutableCopy() as? NSMutableAttributedString {
            if let attributedReadLessText = attributedReadLessText?.mutableCopy() as? NSMutableAttributedString {
                attributedReadLessText.insert(NSAttributedString(string: "\(prefix) "), at: 0)
                originalAttributedText.append(attributedReadLessText)
            } else if var readLessText = readLessText {
                readLessText = "\(prefix) \(readLessText)"
                let attributes = originalAttributedText.attributes(at: originalAttributedText.string.length - 1, effectiveRange: nil)
                let attributedReadLessText = NSAttributedString(string: readLessText, attributes: attributes)
                originalAttributedText.append(attributedReadLessText)
            }
            textStorage.replaceCharacters(in: NSMakeRange(0, text.length), with: originalAttributedText)
        }
        invalidateIntrinsicContentSize()
        onSizeChage(self)
    }
    
    override var intrinsicContentSize : CGSize {
        textContainer.size = CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
        var intrinsicContentSize = layoutManager.boundingRect(forGlyphRange: layoutManager.glyphRange(for: textContainer), in: textContainer).size
        intrinsicContentSize.width = UIViewNoIntrinsicMetric
        intrinsicContentSize.height += (textContainerInset.top + textContainerInset.bottom)
        return intrinsicContentSize
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }

        if needsTrim() && pointIsInReadMoreTextRange(point) {
            shouldTrim = false
        } else if _readLessText != nil && pointIsInReadLessTextRange(point) {
            shouldTrim = true
        }
    }
    
    //MARK: Private methods
    
    fileprivate var _readMoreText: String? {
        get {
            return readMoreText ?? attributedReadMoreText?.string
        }
    }
    
    fileprivate var _readMoreTextPrefixLength: Int {
        get {
            return appendReadMoreTextPrefix ? readMoreTextPrefix.length + 1 : 1
        }
    }
    
    fileprivate var _readLessText: String? {
        get {
            return readLessText ?? attributedReadLessText?.string
        }
    }

    fileprivate var _readLessTextPrefixLength: Int {
        get {
            return appendReadLessTextPrefix ? readLessTextPrefix.length + 1 : 1
        }
    }

    fileprivate var _originalTextLength: Int {
        get {
            return originalText?.length ?? originalAttributedText?.length ?? 0
        }
    }
    
    fileprivate func rangeToReplaceWithReadMoreText() -> NSRange {
        let emptyRange = NSMakeRange(NSNotFound, 0)
        
        var rangeToReplace = layoutManager.characterRangeThatFits(textContainer)
        if NSMaxRange(rangeToReplace) == _originalTextLength {
            rangeToReplace = emptyRange
        }
        else {
            rangeToReplace.location = NSMaxRange(rangeToReplace) - _readMoreText!.length - _readMoreTextPrefixLength
            if rangeToReplace.location < 0 {
                rangeToReplace = emptyRange
            }
            else {
                rangeToReplace.length = textStorage.length - rangeToReplace.location
            }
        }
        return rangeToReplace
    }
    
    fileprivate func readMoreTextRange() -> NSRange {
        var readMoreTextRange = rangeToReplaceWithReadMoreText()
        if readMoreTextRange.location != NSNotFound {
            readMoreTextRange.length = _readMoreTextPrefixLength + _readMoreText!.length
        }
        return readMoreTextRange
    }

    fileprivate func pointIsInReadMoreTextRange(_ point: CGPoint) -> Bool {
        let offset = CGPoint(x: textContainerInset.left, y: textContainerInset.top)
        var boundingRect = layoutManager.boundingRectForCharacterRange(readMoreTextRange(), inTextContainer: textContainer, textContainerOffset: offset)
        boundingRect = boundingRect.offsetBy(dx: textContainerInset.left, dy: textContainerInset.top)
        boundingRect = boundingRect.insetBy(dx: -(readMoreTextRangePadding.left + readMoreTextRangePadding.right), dy: -(readMoreTextRangePadding.top + readMoreTextRangePadding.bottom))
        return boundingRect.contains(point)
    }

    fileprivate func readLessTextRange() -> NSRange {
        return NSRange(location: _originalTextLength, length: _readLessTextPrefixLength + _readLessText!.length)
    }

    fileprivate func pointIsInReadLessTextRange(_ point: CGPoint) -> Bool {
        let offset = CGPoint(x: textContainerInset.left, y: textContainerInset.top)
        var boundingRect = layoutManager.boundingRectForCharacterRange(readLessTextRange(), inTextContainer: textContainer, textContainerOffset: offset)
        boundingRect = boundingRect.offsetBy(dx: textContainerInset.left, dy: textContainerInset.top)
        boundingRect = boundingRect.insetBy(dx: -(readLessTextRangePadding.left + readLessTextRangePadding.right), dy: -(readLessTextRangePadding.top + readLessTextRangePadding.bottom))
        return boundingRect.contains(point)
    }

}

extension String {
    var length: Int {
        return characters.count
    }
}

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


