//
//  ReadMoreTextView.swift
//  ReadMoreTextView
//
//  Created by Ilya Puchka on 06.04.15.
//  Copyright (c) 2015 Ilya Puchka. All rights reserved.
//

import UIKit

/**
 UITextView subclass that adds "read more"/"read less" capabilities.
 Disables scrolling and editing, so do not set these properties to true.
 */
@IBDesignable
public class ReadMoreTextView: UITextView {
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        isScrollEnabled = false
        isEditable = false
    }
    
    public convenience init(frame: CGRect) {
        self.init(frame: frame, textContainer: nil)
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero, textContainer: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isScrollEnabled = false
        isEditable = false
    }
    
    /**Block to be invoked when text view changes its content size.*/
    public var onSizeChage: (ReadMoreTextView)->() = { _ in }
    
    /**
     The maximum number of lines that the text view can display. If text does not fit that number it will be trimmed.
     Default is `0` which means that no text will be never trimmed.
     */
    @IBInspectable
    public var maximumNumberOfLines: Int = 0 {
        didSet {
            _originalMaximumNumberOfLines = maximumNumberOfLines
            setNeedsLayout()
        }
    }
    
    /**The text to trim the original text. Setting this property resets `attributedReadMoreText`.*/
    @IBInspectable
    public var readMoreText: String? {
        get {
            return _readMoreTextStorage
        }
        set {
            _readMoreTextStorage = newValue
            _attributedReadMoreTextStorage = nil
            setNeedsLayout()
        }
    }
    
    /**The attributed text to trim the original text. Setting this property resets `readMoreText`.*/
    public var attributedReadMoreText: NSAttributedString? {
        get {
            return _attributedReadMoreTextStorage
        }
        set {
            _attributedReadMoreTextStorage = newValue
            _readMoreTextStorage = nil
            setNeedsLayout()
        }
    }

    /**
     The text to append to the original text when not trimming.
     Setting this property resets `attributedReadLessText`.
     */
    @IBInspectable
    public var readLessText: String? {
        get {
            return _readLessTextStorage
        }
        set {
            _readLessTextStorage = newValue
            _attributedReadLessTextStorage = nil
            setNeedsLayout()
        }
    }
    
    /**
     The attributed text to append to the original text when not trimming.
     Setting this property resets `readLessText`.
     */
    public var attributedReadLessText: NSAttributedString? {
        get {
            return _attributedReadLessTextStorage
        }
        set {
            _attributedReadLessTextStorage = newValue
            _readLessTextStorage = nil
            setNeedsLayout()
        }
    }

    /**
     A Boolean that controls whether the text view should trim it's content to fit the `maximumNumberOfLines`.
     The default value is `false`.
     */
    @IBInspectable
    public var shouldTrim: Bool = false {
        didSet {
            if shouldTrim {
                maximumNumberOfLines = _originalMaximumNumberOfLines
            } else {
                let _maximumNumberOfLines = maximumNumberOfLines
                maximumNumberOfLines = 0
                _originalMaximumNumberOfLines = _maximumNumberOfLines
            }
            setNeedsLayout()
        }
    }
    
    /**
     A padding around "read more" text to adjust touchable area.
     If text is trimmed touching in this area will change `shouldTream` to `false` and remove trimming.
     That will cause text view to change it's content size. Use `onSizeChange` to adjust layout on that event.
     */
    public var readMoreTextRangePadding: UIEdgeInsets = UIEdgeInsets.zero
    
    /**
     A padding around "read less" text to adjust touchable area.
     If text is not trimmed and `readLessText` or `attributedReadLessText` is set touching in this area
     will change `shouldTream` to `true` and cause trimming. That will cause text view to change it's content size.
     Use `onSizeChange` to adjust layout on that event.
     */
    public var readLessTextRangePadding: UIEdgeInsets = UIEdgeInsets.zero
    
    public override var text: String! {
        didSet {
            _originalText = text
            _originalAttributedText = nil
            if needsTrim() { showLessText() }
        }
    }
    
    public override var attributedText: NSAttributedString! {
        didSet {
            _originalAttributedText = attributedText
            _originalText = nil
            if needsTrim() { showLessText() }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        needsTrim() ? showLessText() : showMoreText()
    }
    
    public override var intrinsicContentSize : CGSize {
        textContainer.size = CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
        var intrinsicContentSize = layoutManager.boundingRect(forGlyphRange: layoutManager.glyphRange(for: textContainer), in: textContainer).size
        intrinsicContentSize.width = UIViewNoIntrinsicMetric
        intrinsicContentSize.height += (textContainerInset.top + textContainerInset.bottom)
        return intrinsicContentSize
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }

        if needsTrim() && pointIsInReadMoreTextRange(point) {
            shouldTrim = false
        } else if _readLessText != nil && pointIsInReadLessTextRange(point) {
            shouldTrim = true
        }
    }
    
    //MARK: Private methods
    
    private var _readMoreTextStorage: String?
    private var _attributedReadMoreTextStorage: NSAttributedString?
    private var _readMoreText: String? {
        get {
            return _readMoreTextStorage ?? _attributedReadMoreTextStorage?.string
        }
    }

    private var _readLessTextStorage: String?
    private var _attributedReadLessTextStorage: NSAttributedString?
    private var _readLessText: String? {
        get {
            return _readLessTextStorage ?? _attributedReadLessTextStorage?.string
        }
    }

    private var _originalMaximumNumberOfLines: Int = 0
    private var _originalText: String!
    private var _originalAttributedText: NSAttributedString!
    private var _originalTextLength: Int {
        get {
            return _originalText?.length ?? _originalAttributedText?.length ?? 0
        }
    }
    
    private func needsTrim() -> Bool {
        return shouldTrim && _readMoreText != nil
    }
    
    private func showLessText() {
        textContainer.maximumNumberOfLines = maximumNumberOfLines
        layoutManager.invalidateLayout(forCharacterRange: layoutManager.characterRangeThatFits(textContainer), actualCharacterRange: nil)
        textContainer.size = CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
        
        let range = rangeToReplaceWithReadMoreText()
        if range.location != NSNotFound {
            if let text = readMoreText {
                textStorage.replaceCharacters(in: range, with: text)
            } else if let text = attributedReadMoreText {
                textStorage.replaceCharacters(in: range, with: text)
            }
        }
        invalidateIntrinsicContentSize()
        onSizeChage(self)
    }
    
    private func showMoreText() {
        textContainer.maximumNumberOfLines = 0
        if var originalText = _originalText {
            if let readLessText = readLessText {
                originalText.append(readLessText)
                textStorage.replaceCharacters(in: NSRange(location: 0, length: text.length), with: originalText)
            } else if let attributedReadLessText = attributedReadLessText?.mutableCopy() as? NSMutableAttributedString {
                let originalTextAttributes = textStorage.attributes(at: 0, effectiveRange: nil)
                let originalAttributedText = NSMutableAttributedString(string: originalText, attributes: originalTextAttributes)
                originalAttributedText.append(attributedReadLessText)
                textStorage.replaceCharacters(in: NSRange(location: 0, length: text.length), with: originalAttributedText)
            } else {
                textStorage.replaceCharacters(in: NSRange(location: 0, length: text.length), with: originalText)
            }
        }
        else if let originalAttributedText = _originalAttributedText.mutableCopy() as? NSMutableAttributedString {
            if let attributedReadLessText = attributedReadLessText {
                originalAttributedText.append(attributedReadLessText)
            } else if let readLessText = readLessText {
                let attributes = originalAttributedText.attributes(at: originalAttributedText.string.length - 1, effectiveRange: nil)
                let attributedReadLessText = NSAttributedString(string: readLessText, attributes: attributes)
                originalAttributedText.append(attributedReadLessText)
            }
            textStorage.replaceCharacters(in: NSMakeRange(0, text.length), with: originalAttributedText)
        }
        invalidateIntrinsicContentSize()
        onSizeChage(self)
    }
    
    private func rangeToReplaceWithReadMoreText() -> NSRange {
        let emptyRange = NSMakeRange(NSNotFound, 0)
        
        var rangeToReplace = layoutManager.characterRangeThatFits(textContainer)
        if NSMaxRange(rangeToReplace) == _originalTextLength {
            rangeToReplace = emptyRange
        }
        else {
            rangeToReplace.location = NSMaxRange(rangeToReplace) - _readMoreText!.length - 1
            if rangeToReplace.location < 0 {
                rangeToReplace = emptyRange
            }
            else {
                rangeToReplace.length = textStorage.length - rangeToReplace.location
            }
        }
        return rangeToReplace
    }
    
    private func readMoreTextRange() -> NSRange {
        var readMoreTextRange = rangeToReplaceWithReadMoreText()
        if readMoreTextRange.location != NSNotFound {
            readMoreTextRange.length = _readMoreText!.length + 1
        }
        return readMoreTextRange
    }

    private func pointIsInReadMoreTextRange(_ point: CGPoint) -> Bool {
        let offset = CGPoint(x: textContainerInset.left, y: textContainerInset.top)
        var boundingRect = layoutManager.boundingRectForCharacterRange(readMoreTextRange(), inTextContainer: textContainer, textContainerOffset: offset)
        boundingRect = boundingRect.offsetBy(dx: textContainerInset.left, dy: textContainerInset.top)
        boundingRect = boundingRect.insetBy(dx: -(readMoreTextRangePadding.left + readMoreTextRangePadding.right), dy: -(readMoreTextRangePadding.top + readMoreTextRangePadding.bottom))
        return boundingRect.contains(point)
    }

    private func readLessTextRange() -> NSRange {
        return NSRange(location: _originalTextLength, length: _readLessText!.length + 1)
    }

    private func pointIsInReadLessTextRange(_ point: CGPoint) -> Bool {
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


