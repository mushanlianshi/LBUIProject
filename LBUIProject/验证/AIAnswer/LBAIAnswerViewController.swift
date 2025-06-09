import UIKit

class LBAIAnswerViewController: UIViewController {
    private let responseLabel = UILabel()
    private var displayText = ""
    private var typingTimer: Timer?
    private var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()

        // 假设这是 AI 返回的文本
        let aiResponse = "你好！我是一名 AI，很高兴帮助你解决问题。responseLabel.font = UIFont.systemFont(ofSize: 16),responseLabel.blt.addBorder(borderWidth: 1, borderColor: .red, cornerRadius: 5)你好！我是一名 AI，很高兴帮助你解决问题。responseLabel.font = UIFont.systemFont(ofSize: 16),responseLabel.blt.addBorder(borderWidth: 1, borderColor: .red, cornerRadius: 5)"
        startTypingEffect(text: aiResponse, interval: 0.05)
    }

    private func setupUI() {
        view.backgroundColor = .white
        responseLabel.numberOfLines = 0
        responseLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(responseLabel)
        responseLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }
        responseLabel.blt.addBorder(borderWidth: 1, borderColor: .red, cornerRadius: 5)
    }

    private func startTypingEffect(text: String, interval: TimeInterval) {
        displayText = text
        responseLabel.text = ""
        currentIndex = 0

        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            guard self.currentIndex < self.displayText.count else {
                timer.invalidate()
                return
            }
            let index = displayText.index(displayText.startIndex, offsetBy: currentIndex)
            responseLabel.text?.append(displayText[index])
            currentIndex += 1
        }
    }
}
