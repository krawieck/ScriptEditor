//
//  EditorView.swift
//  ScriptEditor
//
//  Created by Filip Krawczyk on 01/05/2024.
//

import AppKit
import Foundation
import RegexBuilder
import SwiftIDEUtils
import SwiftOperators
import SwiftParser
import SwiftSyntax
import SwiftUI

extension ByteSourceRange {
    func toNSRange() -> NSRange {
        return NSRange(location: self.offset, length: self.length)
    }
}

let highlightedKeywordsAttributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.userFixedPitchFont(ofSize: 12)!,
    .foregroundColor: NSColor.systemCyan,
]
let regularTextAttributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.userFixedPitchFont(ofSize: 12)!,
    .foregroundColor: NSColor.textColor,
]

func highlightedSwiftKeywords(of text: NSMutableAttributedString) -> NSMutableAttributedString {
    let str = text.string
    let parsed = Parser.parse(source: str)
    let keywords = parsed.statements.classifications.filter { $0.kind == .keyword }.map {
        $0.range.toNSRange()
    }
    for range in keywords {
        text.setAttributes(highlightedKeywordsAttributes, range: range)
    }
    return text

}

func highlightSwiftKeywords(_ text: String, textStorage: NSTextStorage?) {
    guard let textStorage else { return }

    var attributedString = NSMutableAttributedString(
        string: text, attributes: regularTextAttributes)
    attributedString = highlightedSwiftKeywords(of: attributedString)
    textStorage.setAttributedString(attributedString)
}

/// adapted from: https://gist.github.com/unnamedd/6e8c3fbc806b8deb60fa65d6b9affab0
struct EditorTextView: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView(text: text)
        textView.delegate = context.coordinator

        return textView
    }

    func updateNSView(_ view: CustomTextView, context: Context) {
        highlightSwiftKeywords(text, textStorage: view.textView.textStorage)
    }
}

// MARK: - Coordinator
extension EditorTextView {

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: EditorTextView

        init(_ parent: EditorTextView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }

            let selection = textView.selectedRanges  // for some reason next line changes selectedRanges to the end of the line
            highlightSwiftKeywords(textView.string, textStorage: textView.textStorage)
            textView.selectedRanges = selection

        }
    }
}

// MARK: - CustomTextView

final class CustomTextView: NSView {
    weak var delegate: NSTextViewDelegate?

    var text: String {
        didSet {
            textView.string = text
        }
    }

    var textViewRef: NSTextView? {
        scrollView.documentView as? NSTextView
    }

    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        return scrollView
    }()

    lazy var textView: NSTextView = {
        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()

        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(
            width: contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )

        layoutManager.addTextContainer(textContainer)

        let textView = NSTextView(frame: .zero, textContainer: textContainer)

        textView.autoresizingMask = .width
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.delegate = self.delegate
        textView.drawsBackground = true
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 0, height: contentSize.height)
        textView.allowsUndo = true

        return textView
    }()

    init(text: String) {
        self.text = text

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override func viewWillDraw() {
        super.viewWillDraw()

        setupScrollViewConstraints()
        setupTextView()
    }

    func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])
    }

    func setupTextView() {
        scrollView.documentView = textView
    }
}

#Preview {
    EditorTextView(
        text: .constant(
            "let hello = \"world\"\nfunc check() { return \"on those who return home\" }"))
}
