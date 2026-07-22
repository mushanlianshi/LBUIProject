//import UIKit
//import SwiftUI
//import SwiftStreamingMarkdown
//
//// MARK: - 流式文本源
//
//final class StreamSource: StreamedMarkdownSource {
//    private let subject: AsyncStream<String>
//    private(set) var continuation: AsyncStream<String>.Continuation!
//    private var accumulatedText = ""
//
//    var text: AsyncStream<String> { subject }
//
//    init() {
//        var cont: AsyncStream<String>.Continuation!
//        subject = AsyncStream { cont = $0 }
//        continuation = cont
//    }
//
//    func append(_ chunk: String) {
//        accumulatedText += chunk
//        continuation.yield(accumulatedText)
//    }
//
//    func complete() {
//        continuation.finish()
//    }
//}
//
//// MARK: - SwiftUI → UIKit 高度回传
//
//private struct HeightPreferenceKey: PreferenceKey {
//    static let defaultValue: CGFloat = 0
//    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//        value = max(value, nextValue())
//    }
//}
//
//private struct HeightReportingMarkdownView: View {
//    let source: StreamSource
//    let onHeightChange: (CGFloat) -> Void
//
//    var body: some View {
//        StreamedMarkdownView(source: source)
//            .background(
//                GeometryReader { proxy in
//                    Color.clear.preference(
//                        key: HeightPreferenceKey.self,
//                        value: proxy.size.height
//                    )
//                }
//            )
//            .onPreferenceChange(HeightPreferenceKey.self) { height in
//                onHeightChange(height)
//            }
//    }
//}
//
//// MARK: - ViewController
//
//class ViewController: UIViewController {
//    private let scrollView = UIScrollView()
//    private let source = StreamSource()
//    private var lastContentHeight: CGFloat = 0
//
//    private lazy var hostingController: UIHostingController = {
//        let mdView = HeightReportingMarkdownView(
//            source: source,
//            onHeightChange: { [weak self] height in
////                DispatchQueue.main.async {
//                    self?.onContentHeightChanged(height)
////                }
//            }
//        )
//        let hc = UIHostingController(rootView: mdView)
//        hc.view.backgroundColor = .black.withAlphaComponent(0.1)
////        hc.view.layer.borderColor = UIColor.red.cgColor
////        hc.view.layer.borderWidth = 1
//        return hc
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        simulateStream()
//    }
//
//    private func setupUI() {
//        view.backgroundColor = .white
//        addChild(hostingController)
//        view.addSubview(scrollView)
//        scrollView.addSubview(hostingController.view)
//
//        // scrollView 用 Auto Layout 绑定 safeArea，避免硬编码偏移
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
//            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
//            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
//            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
//        ])
//
//        // hostingView 在 scrollView 内部继续用 frame 布局
//        hostingController.view.frame = CGRect(
//            x: 0, y: 16,
//            width: scrollView.bounds.width, height: 0
//        )
//        hostingController.didMove(toParent: self)
//    }
//
//    // 从 kitchen-sink.md 流式输出，一次输出 batchCount 个字
//    private func simulateStream(batchCount: Int = 2) {
//        guard let path = Bundle.main.path(forResource: "kitchen-sink", ofType: "md"),
//              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
//            return
//        }
//
//        let chars = Array(content)
//        var index = 0
//
//        Timer.scheduledTimer(withTimeInterval: 0.015, repeats: true) { [weak self] timer in
//            guard let self else {
//                timer.invalidate()
//                return
//            }
//            guard index < chars.count else {
//                timer.invalidate()
//                self.source.complete()
//                return
//            }
//
//            let end = min(index + batchCount, chars.count)
//            let batch = String(chars[index..<end])
//            self.source.append(batch)
//            index = end
//        }
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        // Auto Layout 解算后更新 hostingView 宽度以匹配 scrollView 内容区
//        hostingController.view.frame.size.width = scrollView.bounds.width
//    }
//
//    // SwiftUI 渲染完成后回调（来自 GeometryReader）
//    private func onContentHeightChanged(_ height: CGFloat) {
//        guard height > 0, abs(height - lastContentHeight) > 1 else { return }
//        lastContentHeight = height
//        debugPrint("LBLog height is \(height)")
//        hostingController.view.frame.size.height = height
//        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: height + 32)
//
//        // 自动滚动到底部
//        let maxOffset = scrollView.contentSize.height - scrollView.bounds.height
//        if maxOffset > 0 {
//            scrollView.setContentOffset(CGPoint(x: 0, y: maxOffset), animated: true)
//        }
//    }
//}
