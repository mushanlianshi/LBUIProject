//
//  LBSwiftUITextView.swift
//  XLMSwiftUIProject
//
//  Created by liu bin on 2025/3/17.
//

import Foundation
import SwiftUI

public struct LBSwiftUITextView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var placeholderColor: UIColor = .gray
    var textColor: UIColor = .black
    var fontSize: CGFloat = 14

    public class Coordinator: NSObject, UITextViewDelegate {
        public var parent: LBSwiftUITextView

        public init(_ parent: LBSwiftUITextView) {
            self.parent = parent
        }

        public func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        public func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = parent.textColor
            }
        }

        public func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = parent.placeholderColor
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.text = text.isEmpty ? placeholder : text
        textView.textColor = text.isEmpty ? placeholderColor : textColor
        textView.backgroundColor = .clear
        return textView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        if text.isEmpty {
            uiView.text = placeholder
            uiView.textColor = placeholderColor
        } else {
            uiView.text = text
            uiView.textColor = textColor
        }
    }
}
