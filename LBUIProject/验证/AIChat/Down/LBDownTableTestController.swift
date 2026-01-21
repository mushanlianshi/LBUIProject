import UIKit
import Down

class LBDownTableTestController: UIViewController {
    // 1. 初始化 UITextView（纯富文本展示，无需 WebView）
    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false // 禁用滚动，适配动态高度
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        tv.backgroundColor = .white
        return tv
    }()
    
    // 2. 累计 Markdown 内容（流式输出场景用）
    private var accumulatedMarkdown = ""
    // 3. 固定文本宽度（与 UITextView 实际显示宽度一致）
    private var textDisplayWidth: CGFloat {
        view.bounds.width - textView.textContainerInset.left - textView.textContainerInset.right
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // 模拟流式加载带表格的 Markdown（如 AI 逐块返回）
        simulateStreamMarkdown()
    }
    
    // 布局 UI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        // 只约束上下左右，高度动态计算后更新
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // 模拟：流式接收 Markdown 分块（含表格）
    private func simulateStreamMarkdown() {
        let markdownChunks2 = [
            """
            | 📌 项目         | 📝 内容                       | 🎚️ 状态/选择              |
            |----------------|-------------------------------|--------------------------|
            | 🏢 出差审批     | 2025年GIAC峰会集中办公        | 🔵 已批准 ⚪ 驳回         |
            | 🚆 交通工具     | 火车（二等座）                | 🔘 飞机 🔘 高铁 🔴 火车   |
            | 🔁 是否多次往返 | 北京⇄上海                    | ✅ 是 ❎ 否              |
            | ⚠️ 特殊事项     | 无                           | 📌 下拉选项：🔻 无 🔘 绕道/节假日 |
            | 📎 附件上传     | 通知邮件.jpg                 | 🖱️ [点击上传]            |
            """
        ]
        let markdownChunks = [
            "# Down 0.11.0 表格示例\n",
            "这是用 Down 旧版本渲染的表格，支持边框、对齐：\n",
            "| 姓名 | 年龄 | 城市 |\n",
            "|------|------|------|\n",
            "| 张三 | 25   | 上海 |\n",
            "| 李四 | 30   | 北京 |\n",
            "| 王五 | 28   | 广州 |\n",
            "\n**加粗文本** + *斜体文本* 测试"
        ]
        
        // 逐块拼接并实时渲染
        for (index, chunk) in markdownChunks.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.6) { [weak self] in
                guard let self = self else { return }
                // 1. 累计 Markdown 内容
                self.accumulatedMarkdown += chunk
                // 2. 渲染 Markdown（含表格样式配置）
                self.renderMarkdown()
            }
        }
    }
    
    // 核心：Down 0.11.0 专属渲染逻辑（含表格样式）
    private func renderMarkdown() {
        // 1. 初始化 DownStyler（0.11.0 版本是可选型，需解包）
        let styler = DownStyler.init()
        
        
        // 4. Down 解析 Markdown 为 NSAttributedString（含表格）
        do {
            let down = Down(markdownString: accumulatedMarkdown)
            // 关键：传入配置好的 styler
            let attributedString = try down.toAttributedString(styler: styler)
            
            // 5. 赋值给 UITextView
            textView.attributedText = attributedString
            
            // 6. 实时计算并更新 UITextView 高度
            let contentHeight = calculateAttributedStringHeight(attributedString: attributedString)
            updateTextViewHeight(height: contentHeight)
            
            print("当前渲染高度：\(contentHeight)")
        } catch {
            print("Markdown 解析错误：\(error.localizedDescription)")
        }
    }
    
    // 计算 NSAttributedString 高度（适配表格、换行等）
    private func calculateAttributedStringHeight(attributedString: NSAttributedString) -> CGFloat {
        let constraintRect = CGSize(
            width: textDisplayWidth,
            height: .greatestFiniteMagnitude // 高度设为无限大，让文本自然换行
        )
        
        // 关键：options 必须包含这两个参数，否则表格/多行文本高度计算不准
        let boundingRect = attributedString.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        // 向上取整，避免高度不足导致内容截断
        return ceil(boundingRect.height)
    }
    
    // 动态更新 UITextView 高度约束
    private func updateTextViewHeight(height: CGFloat) {
        // 移除旧的高度约束（若存在）
        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                textView.removeConstraint(constraint)
            }
        }
        
        // 添加新的高度约束
        let heightConstraint = NSLayoutConstraint(
            item: textView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: height
        )
        textView.addConstraint(heightConstraint)
    }
}
