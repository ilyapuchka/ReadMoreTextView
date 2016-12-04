//
//  ReadMoreTextView.swift
//  ReadMoreTextView
//
//  Created by Ilya Puchka on 06.04.15.
//  Copyright (c) 2015 - 2016 Ilya Puchka. All rights reserved.
//

import UIKit

/**
 UITextView subclass that adds "read more"/"read less" capabilities.
 Disables scrolling and editing, so do not set these properties to true.
 */
@IBDesignable
public class ReadMoreTextView: UITextView {
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        #if swift(>=3.0)
            readMoreTextPadding = .zero
            readLessTextPadding = .zero
        #else
            readMoreTextPadding = UIEdgeInsetsZero
            readLessTextPadding = UIEdgeInsetsZero
        #endif
        super.init(frame: frame, textContainer: textContainer)
        setupDefaults()
    }
    
    public convenience init(frame: CGRect) {
        self.init(frame: frame, textContainer: nil)
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero, textContainer: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        #if swift(>=3.0)
            readMoreTextPadding = .zero
            readLessTextPadding = .zero
        #else
            readMoreTextPadding = UIEdgeInsetsZero
            readLessTextPadding = UIEdgeInsetsZero
        #endif
        super.init(coder: aDecoder)
        setupDefaults()
    }
    
    func setupDefaults() {
        let defaultReadMoreText = NSLocalizedString("ReadMoreTextView.readMore", value: "more", comment: "")
        let attributedReadMoreText = NSMutableAttributedString(string: "... ")

        #if swift(>=3.0)
            readMoreTextPadding = .zero
            readLessTextPadding = .zero
            isScrollEnabled = false
            isEditable = false
            
            let attributedDefaultReadMoreText = NSAttributedString(string: defaultReadMoreText, attributes: [
                NSForegroundColorAttributeName: UIColor.lightGray,
                NSFontAttributeName: font ?? UIFont.systemFont(ofSize: 14)
            ])
            attributedReadMoreText.append(attributedDefaultReadMoreText)
        #else
            readMoreTextPadding = UIEdgeInsetsZero
            readLessTextPadding = UIEdgeInsetsZero
            scrollEnabled = false
            editable = false
            
            let attributedDefaultReadMoreText = NSAttributedString(string: defaultReadMoreText, attributes: [
                NSForegroundColorAttributeName: UIColor.lightGrayColor(),
                NSFontAttributeName: font ?? UIFont.systemFontOfSize(14)
            ])
            attributedReadMoreText.appendAttributedString(attributedDefaultReadMoreText)
        #endif
        self.attributedReadMoreText = attributedReadMoreText
    }
    
    /**Block to be invoked when text view changes its content size.*/
    public var onSizeChange: (ReadMoreTextView)->() = { _ in }
    
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
            guard shouldTrim != oldValue else { return }
            
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
    public var readMoreTextPadding: UIEdgeInsets
    
    /**
     A padding around "read less" text to adjust touchable area.
     If text is not trimmed and `readLessText` or `attributedReadLessText` is set touching in this area
     will change `shouldTream` to `true` and cause trimming. That will cause text view to change it's content size.
     Use `onSizeChange` to adjust layout on that event.
     */
    public var readLessTextPadding: UIEdgeInsets
    
    public override var text: String! {
        didSet {
            _originalText = text
            _originalAttributedText = nil
            setNeedsLayout()
        }
    }
    
    public override var attributedText: NSAttributedString! {
        didSet {
            _originalAttributedText = attributedText
            _originalText = nil
            setNeedsLayout()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        needsTrim() ? showLessText() : showMoreText()
    }
    
    #if swift(>=3.0)
    public override var intrinsicContentSize : CGSize {
        textContainer.size = CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
        var intrinsicContentSize = layoutManager.boundingRect(forGlyphRange: layoutManager.glyphRange(for: textContainer), in: textContainer).size
        intrinsicContentSize.width = UIViewNoIntrinsicMetric
        intrinsicContentSize.height += (textContainerInset.top + textContainerInset.bottom)
        intrinsicContentSize.height = ceil(intrinsicContentSize.height)
        return intrinsicContentSize
    }
    #else
    public override func intrinsicContentSize() -> CGSize {
        textContainer.size = CGSize(width: bounds.size.width, height: CGFloat.max)
        var intrinsicContentSize = layoutManager.boundingRectForGlyphRange(layoutManager.glyphRangeForTextContainer(textContainer), inTextContainer: textContainer).size
        intrinsicContentSize.width = UIViewNoIntrinsicMetric
        intrinsicContentSize.height += (textContainerInset.top + textContainerInset.bottom)
        intrinsicContentSize.height = ceil(intrinsicContentSize.height)
        return intrinsicContentSize
    }
    #endif
    
    private var intrinsicContentHeight: CGFloat {
        #if swift(>=3.0)
            return intrinsicContentSize.height
        #else
            return intrinsicContentSize().height
        #endif
    }
    
    #if swift(>=3.0)
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let charIndex = hitTestPointIsInGliphRectAtCharIndex(point: point) else {
            return super.hitTest(point, with: event)
        }

        if textStorage.attribute(NSLinkAttributeName, at: charIndex, effectiveRange: nil) != nil {
            return super.hitTest(point, with: event)
        } else if pointIsInReadMoreOrReadLessTextRange(point: point) != nil {
            return self
        } else {
            return nil
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer { super.touchesEnded(touches, with: event) }
        guard let point = touches.first?.location(in: self) else { return }
        shouldTrim = pointIsInReadMoreOrReadLessTextRange(point: point) ?? shouldTrim
    }
    #else
    
    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        guard let charIndex = hitTestPointIsInGliphRectAtCharIndex(point: point) else {
            return super.hitTest(point, withEvent: event)
        }
    
        if textStorage.attribute(NSLinkAttributeName, atIndex: charIndex, effectiveRange: nil) != nil {
            return super.hitTest(point, withEvent: event)
        } else if pointIsInReadMoreOrReadLessTextRange(point: point) != nil {
            return self
        } else {
            return nil
        }
    }

    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        defer { super.touchesEnded(touches, withEvent: event) }
        guard let point = touches.first?.locationInView(self) else { return }
        shouldTrim = pointIsInReadMoreOrReadLessTextRange(point: point) ?? shouldTrim
    }
    
    #endif
    
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
        #if swift(>=3.0)
            if let _readMoreText = _readMoreText, text.hasSuffix(_readMoreText) { return }
        #else
            if let _readMoreText = _readMoreText where text.hasSuffix(_readMoreText) { return }
        #endif
        
        let oldHeight = intrinsicContentHeight
        defer {
            invalidateIntrinsicContentSize()
            if intrinsicContentHeight != oldHeight {
                onSizeChange(self)
            }
        }

        shouldTrim = true
        textContainer.maximumNumberOfLines = maximumNumberOfLines
        
        #if swift(>=3.0)
            layoutManager.invalidateLayout(forCharacterRange: layoutManager.characterRangeThatFits(textContainer: textContainer), actualCharacterRange: nil)
            textContainer.size = CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
        #else
            layoutManager.invalidateLayoutForCharacterRange(layoutManager.characterRangeThatFits(textContainer: textContainer), actualCharacterRange: nil)
            textContainer.size = CGSize(width: bounds.size.width, height: CGFloat.max)
        #endif
        
        let range = rangeToReplaceWithReadMoreText()
        guard range.location != NSNotFound else { return }
        
        #if swift(>=3.0)
            if let text = readMoreText {
                textStorage.replaceCharacters(in: range, with: text)
            } else if let text = attributedReadMoreText {
                textStorage.replaceCharacters(in: range, with: text)
            }
        #else
            if let text = readMoreText {
                textStorage.replaceCharactersInRange(range, withString: text)
            } else if let text = attributedReadMoreText {
                textStorage.replaceCharactersInRange(range, withAttributedString: text)
            }
        #endif
    }
    
    private func showMoreText() {
        #if swift(>=3.0)
            if let _readLessText = _readLessText, text.hasSuffix(_readLessText) { return }
        #else
            if let _readLessText = _readLessText where text.hasSuffix(_readLessText) { return }
        #endif

        let oldHeight = intrinsicContentHeight
        defer {
            invalidateIntrinsicContentSize()
            if intrinsicContentHeight != oldHeight {
                onSizeChange(self)
            }
        }

        shouldTrim = false
        textContainer.maximumNumberOfLines = 0
        
        let range = NSRange(location: 0, length: text.length)
        
        if var originalText = _originalText {
            #if swift(>=3.0)
                if let readLessText = readLessText {
                    originalText.append(readLessText)
                    textStorage.replaceCharacters(in: range, with: originalText)
                } else if let attributedReadLessText = attributedReadLessText?.mutableCopy() as? NSMutableAttributedString {
                    let originalTextAttributes = textStorage.attributes(at: 0, effectiveRange: nil)
                    let originalAttributedText = NSMutableAttributedString(string: originalText, attributes: originalTextAttributes)
                    originalAttributedText.append(attributedReadLessText)
                    textStorage.replaceCharacters(in: range, with: originalAttributedText)
                } else {
                    textStorage.replaceCharacters(in: range, with: originalText)
                }
            #else
                if let readLessText = readLessText {
                    originalText.appendContentsOf(readLessText)
                    textStorage.replaceCharactersInRange(range, withString: originalText)
                } else if let attributedReadLessText = attributedReadLessText?.mutableCopy() as? NSMutableAttributedString {
                    let originalTextAttributes = textStorage.attributesAtIndex(0, effectiveRange: nil)
                    let originalAttributedText = NSMutableAttributedString(string: originalText, attributes: originalTextAttributes)
                    originalAttributedText.appendAttributedString(attributedReadLessText)
                    textStorage.replaceCharactersInRange(range, withAttributedString: originalAttributedText)
                } else {
                    textStorage.replaceCharactersInRange(range, withString: originalText)
                }
            #endif
        } else if let originalAttributedText = _originalAttributedText.mutableCopy() as? NSMutableAttributedString {
            #if swift(>=3.0)
                if let attributedReadLessText = attributedReadLessText {
                    originalAttributedText.append(attributedReadLessText)
                } else if let readLessText = readLessText {
                    let attributes = originalAttributedText.attributes(at: originalAttributedText.string.length - 1, effectiveRange: nil)
                    let attributedReadLessText = NSAttributedString(string: readLessText, attributes: attributes)
                    originalAttributedText.append(attributedReadLessText)
                }
                textStorage.replaceCharacters(in: NSMakeRange(0, text.length), with: originalAttributedText)
            #else
                if let attributedReadLessText = attributedReadLessText {
                    originalAttributedText.appendAttributedString(attributedReadLessText)
                } else if let readLessText = readLessText {
                    let attributes = originalAttributedText.attributesAtIndex(originalAttributedText.string.length - 1, effectiveRange: nil)
                    let attributedReadLessText = NSAttributedString(string: readLessText, attributes: attributes)
                    originalAttributedText.appendAttributedString(attributedReadLessText)
                }
                textStorage.replaceCharactersInRange(range, withAttributedString: originalAttributedText)
            #endif
        }
    }
    
    private func rangeToReplaceWithReadMoreText() -> NSRange {
        let rangeThatFitsContainer = layoutManager.characterRangeThatFits(textContainer: textContainer)
        if NSMaxRange(rangeThatFitsContainer) == _originalTextLength {
            return NSMakeRange(NSNotFound, 0)
        }
        else {
            let lastCharacterIndex = characterIndexBeforeTrim(range: rangeThatFitsContainer)
            if lastCharacterIndex > 0 {
                return NSMakeRange(lastCharacterIndex, textStorage.length - lastCharacterIndex)
            }
            else {
                return NSMakeRange(NSNotFound, 0)
            }
        }
    }
    
    private func characterIndexBeforeTrim(range rangeThatFits: NSRange) -> Int {
        if let text = attributedReadMoreText {
            let readMoreBoundingRect = attributedReadMoreText(text: text, boundingRectThatFits: textContainer.size)
            let lastCharacterRect = layoutManager.boundingRectForCharacterRange(range: NSMakeRange(NSMaxRange(rangeThatFits)-1, 1), inTextContainer: textContainer)
            var point = lastCharacterRect.origin
            point.x = textContainer.size.width - ceil(readMoreBoundingRect.size.width)
            #if swift(>=3.0)
                let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer, fractionOfDistanceThroughGlyph: nil)
                let characterIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
            #else
                let glyphIndex = layoutManager.glyphIndexForPoint(point, inTextContainer: textContainer, fractionOfDistanceThroughGlyph: nil)
                let characterIndex = layoutManager.characterIndexForGlyphAtIndex(glyphIndex)
            #endif
            return characterIndex - 1
        } else {
            return NSMaxRange(rangeThatFits) - _readMoreText!.length
        }
    }
    
    private func attributedReadMoreText(text aText: NSAttributedString, boundingRectThatFits size: CGSize) -> CGRect {
        let textContainer = NSTextContainer(size: size)
        let textStorage = NSTextStorage(attributedString: aText)
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        let readMoreBoundingRect = layoutManager.boundingRectForCharacterRange(range: NSMakeRange(0, text.length), inTextContainer: textContainer)
        return readMoreBoundingRect
    }
    
    private func readMoreTextRange() -> NSRange {
        var readMoreTextRange = rangeToReplaceWithReadMoreText()
        if readMoreTextRange.location != NSNotFound {
            readMoreTextRange.length = _readMoreText!.length + 1
        }
        return readMoreTextRange
    }
    
    private func readLessTextRange() -> NSRange {
        return NSRange(location: _originalTextLength, length: _readLessText!.length + 1)
    }

    private func pointIsInReadMoreOrReadLessTextRange(point aPoint: CGPoint) -> Bool? {
        if needsTrim() && pointIsInTextRange(point: aPoint, range: readMoreTextRange(), padding: readMoreTextPadding) {
            return false
        } else if _readLessText != nil && pointIsInTextRange(point: aPoint, range: readLessTextRange(), padding: readLessTextPadding) {
            return true
        }
        return nil
    }

    private func pointIsInTextRange(point aPoint: CGPoint, range: NSRange, padding: UIEdgeInsets) -> Bool {
        var boundingRect = layoutManager.boundingRectForCharacterRange(range: range, inTextContainer: textContainer)
        boundingRect = boundingRect.offsetBy(dx: textContainerInset.left, dy: textContainerInset.top)
        boundingRect = boundingRect.insetBy(dx: -(padding.left + padding.right), dy: -(padding.top + padding.bottom))
        return boundingRect.contains(aPoint)
    }
    
    private func hitTestPointIsInGliphRectAtCharIndex(point aPoint: CGPoint) -> Int? {
        let point = CGPoint(x: aPoint.x, y: aPoint.y - textContainerInset.top)
        #if swift(>=3.0)
            let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
            let glyphRect = layoutManager.boundingRect(forGlyphRange: NSMakeRange(glyphIndex, 1), in: textContainer)
            if glyphRect.contains(point) {
                return layoutManager.characterIndexForGlyph(at: glyphIndex)
            } else {
                return nil
            }
        #else
            let glyphIndex = layoutManager.glyphIndexForPoint(point, inTextContainer: textContainer)
            let glyphRect = layoutManager.boundingRectForGlyphRange(NSMakeRange(glyphIndex, 1), inTextContainer: textContainer)
            if CGRectContainsPoint(glyphRect, point) {
                return layoutManager.characterIndexForGlyphAtIndex(glyphIndex)
            }
            else {
                return nil
            }
        #endif
    }
}

extension String {
    var length: Int {
        return characters.count
    }
}

extension NSLayoutManager {
    
    func characterRangeThatFits(textContainer container: NSTextContainer) -> NSRange {
        #if swift(>=3.0)
            var rangeThatFits = self.glyphRange(for: container)
            rangeThatFits = self.characterRange(forGlyphRange: rangeThatFits, actualGlyphRange: nil)
        #else
            var rangeThatFits = self.glyphRangeForTextContainer(container)
            rangeThatFits = self.characterRangeForGlyphRange(rangeThatFits, actualGlyphRange: nil)
        #endif
        return rangeThatFits
    }
    
    func boundingRectForCharacterRange(range aRange: NSRange, inTextContainer container: NSTextContainer) -> CGRect {
        #if swift(>=3.0)
            let glyphRange = self.glyphRange(forCharacterRange: aRange, actualCharacterRange: nil)
            let boundingRect = self.boundingRect(forGlyphRange: glyphRange, in: container)
        #else
            let glyphRange = self.glyphRangeForCharacterRange(aRange, actualCharacterRange: nil)
            let boundingRect = self.boundingRectForGlyphRange(glyphRange, inTextContainer: container)
        #endif
        return boundingRect
    }
    
}


