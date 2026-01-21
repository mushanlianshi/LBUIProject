import UIKit
import QMUIKit

final class LBChatViewController: UIViewController {
    private let tableView = UITableView()
    private var messages: [LBChatMessage] = []
    private let parser = LBMarkdownStreamingParser()
    private let baseFont = UIFont.systemFont(ofSize: 15)
    
    private var chunks: [String] = []
        private var timer: Timer?
        var onChunk: ((String) -> Void)?
    
    var lastCellHeight = 0.0
    
    lazy var textField: QMUITextField = {
       let textField = QMUITextField()
        textField.returnKeyType = .done
        textField.delegate = self
        textField.backgroundColor = UIColor.blt.ninenineBlackColor()
        textField.textColor = .black
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        tableView.register(LBChatCell.self, forCellReuseIdentifier: LBChatCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .interactive

        view.addSubview(tableView)
        view.addSubview(self.textField)
        self.textField.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-BLT_SCREEN_BOTTOM_SAFE_OFFSET())
            make.height.equalTo(45)
        }
        
        self.tableView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(textField.snp.top)
        }

        // demo: add a user question and an empty assistant message to be streamed
        messages.append(LBChatMessage(role: .user, markdown: "What is Swift?"))
        messages.append(LBChatMessage(role: .assistant, markdown: "")) // will stream into this

        tableView.reloadData()
        scrollToBottom(animated: false)

        simulateStreaming()
    }

    private func scrollToBottom(animated: Bool) {
        guard messages.count > 0 else { return }
        let ip = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: ip, at: .bottom, animated: animated)
    }

    // append a chunk to the last assistant message
    func appendChunkToLastMessage(_ chunk: String) {
        guard let last = messages.last else { return }

        last.markdown.append(chunk)

//        let attChunk = parser.attributedFromMarkdownChunk(chunk, baseFont: baseFont)

        // append to model
        last.attributed.beginEditing()
        let attributeText = NSMutableAttributedString(string: last.markdown)
        last.attributed = attributeText
//        last.attributed.append(attChunk)
        last.attributed.endEditing()

        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)

            if let cell = self.tableView.cellForRow(at: indexPath) as? LBChatCell {
                // This updates the textView content WITHOUT replacing whole text
                
                cell.textView.attributedText = last.attributed
                let size = cell.textView.sizeThatFits(.init(width: self.view.bounds.size.width - 50, height: 0))
                
                // Force cell re-layout so TextView expands
//                cell.setNeedsLayout()
//                cell.layoutIfNeeded()
            
                if ceill(self.lastCellHeight) != ceill(cell.bounds.size.height)  {
                    // 🔥 KEY —让 tableView 重新计算高度
                    
                    DispatchQueue.main.async {
                            UIView.performWithoutAnimation {
                                self.tableView.beginUpdates()
                                self.tableView.endUpdates()
                            }
                            self.autoScrollIfNeeded()
                        self.lastCellHeight = size.height
                        }
                    
//                    UIView.setAnimationsEnabled(false)
//                    self.tableView.beginUpdates()
//                    self.tableView.endUpdates()
//                    UIView.setAnimationsEnabled(true)
//                    // 自动滚动到底部（合理判定：避免强制跳）
//                    self.autoScrollIfNeeded()
//                    self.lastCellHeight = size.height
                }else{
                    debugPrint("LBLog 高度不变------ 不处理")
                }
                debugPrint("LBLog self.lastCellHeight \(self.lastCellHeight)   \(cell.bounds.size.height)")
            }

            
        }
    }

    private func autoScrollIfNeeded() {
        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }

    // Demo streaming generator
    private func simulateStreaming() {
        // Example chunks
//        let chunks = [
//            "Swift is a powerful and intuitive programming language for iOS, macOS, watchOS, and tvOS. ",
//            "It is designed to give developers more freedom than ever. ",
//            "\n\n```swift\nlet a = 1\nprint(a)\n```\n\n",
//            "You can use Swift for system programming and apps."
//        ]
        let chunks = sampleTokens()
//        var idx = 0
//        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
//            if idx >= chunks.count {
//                timer.invalidate()
//                return
//            }
//            self.appendChunkToLastMessage(chunks[idx])
//            idx += 20
//        }
    }
    
    func start(interval: TimeInterval = 0.05) {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] t in
            guard let self = self else { return }
            if self.chunks.isEmpty {
                t.invalidate()
                return
            }
            let next = self.chunks.removeFirst()
            self.onChunk?(next)
        }
    }
    
    func stop() {
        timer?.invalidate()
    }
}

extension String {
    func chunked(by size: Int) -> [String] {
        var result: [String] = []
        var start = startIndex

        while start < endIndex {
            let end = index(start, offsetBy: size, limitedBy: endIndex) ?? endIndex
            result.append(String(self[start..<end]))
            start = end
        }
        return result
    }
}

extension LBChatViewController: QMUITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendText(text: textField.text)
        textField.resignFirstResponder()
        return true
    }
    
    func sendText(text: String?)  {
        guard let text = text,text.isEmpty == false else { return }
        let message = LBChatMessage.init(role: .user, markdown: text)
        self.messages.append(message)
        let receviveMessage = LBChatMessage.init(role: .assistant, markdown: text)
        self.messages.append(receviveMessage)
        self.tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            [weak self] in
            self?.simulateStreaming()
        }
    }
    
}

extension LBChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let msg = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: LBChatCell.reuseId, for: indexPath) as! LBChatCell
        // set the cell textView attributed from the model (initial)
        cell.configure(for: msg)
        // set attributed text storage (to be same object)
        cell.textView.attributedText = msg.attributed
        return cell
    }
}
