//
//  LBMarkdownStreamViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/9/1.
//

import Foundation
import MarkdownKit

import UIKit
import Down   // Markdown 渲染库（CocoaPods / SwiftPM 安装）



// MARK: - Cell
class LBMarkdownStreamViewCell: UITableViewCell {
    // 替换 WKWebView 为 UITextView
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = .label
        tv.backgroundColor = .systemBackground
        tv.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        tv.isEditable = false
        return tv
    }()

    // 渲染逻辑改为 Markdown → NSAttributedString
    func renderMarkdown(_ attributeText: NSAttributedString?) {
        guard let attributeText = attributeText else { return }
        // MarkdownKit 支持直接转为 NSAttributedString
        textView.attributedText = attributeText
        
        let size = textView.sizeThatFits(.init(width: contentView.bounds.size.width, height: 0))
        debugPrint("LBLog size is \(size)")
        textView.snp.updateConstraints { make in
            make.height.equalTo(size.height)
        }
        // 自动滚动到底部
        let bottomRange = NSRange(location: attributeText.length - 1, length: 1)
        textView.scrollRangeToVisible(bottomRange)
    }
    
    let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(0)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(text: String) {
        // 异步渲染 Markdown
        Task {
            let down = Down(markdownString: text)
            let attributed = try? down.toAttributedString()
            await MainActor.run {
                self.label.attributedText = attributed
            }
        }
    }
}

// MARK: - ViewController
class LBMarkdownStreamViewController: UITableViewController {
    
    // 2. 核心变量
    private let markdownParser = MarkdownParser() // Markdown 解析器
    private var accumulatedMarkdown = "" // 累计已接收的 Markdown 内容
    private var attributeText: NSAttributedString?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(LBMarkdownStreamViewCell.self, forCellReuseIdentifier: "LBMarkdownStreamViewCell")
        tableView.estimatedRowHeight = UITableView.automaticDimension
        // 模拟流式输出
        Task {
            let tokens = sampleTokens()
            for token in tokens {
                try? await Task.sleep(nanoseconds: 20_000_000) // 模拟服务端 50ms 1个token
                appendText(token)
            }
        }
    }
    
    

    private func appendText(_ text: String) {
        self.accumulatedMarkdown += text
        self.attributeText = markdownParser.parse(self.accumulatedMarkdown)
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? LBMarkdownStreamViewCell {
            cell.renderMarkdown(self.attributeText)
        }
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LBMarkdownStreamViewCell", for: indexPath) as! LBMarkdownStreamViewCell
        cell.renderMarkdown(self.attributeText)
        debugPrint("LBLog cell is \(self.attributeText)")
        return cell
    }
}


