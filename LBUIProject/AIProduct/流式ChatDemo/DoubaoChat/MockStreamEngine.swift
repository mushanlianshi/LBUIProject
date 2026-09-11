//
//  MockStreamEngine.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import Foundation

/// Mock 流式事件（模拟真实 SSE：不同类型的事件/卡片按剧本顺序穿插到达）
enum DoubaoMockEvent {
    /// 思考块出现（VC 插入 thinking 卡片，展开态）
    case thinkingStart
    /// 思考文本追加一截
    case thinkingText(String)
    /// 思考结束（VC 更新为折叠态，带用时）
    case thinkingEnd(seconds: Int)
    /// 正文 cell 出现（VC 插入 markdown 卡片）
    case answerStart
    /// 正文文本追加一截
    case answerText(String)
    /// 正文流式中途穿插插入找人卡片
    case contactCard(name: String, title: String, intro: String, tags: [String])
    /// 回答结束，追加推荐问卡片
    case recommend(questions: [String])
    /// 空拍（纯消耗节拍，制造「上一块输出完 → 停顿 → 下一卡片出现」的节奏）
    case idle
}

/// Mock 流式引擎：把一份「剧本」（事件数组）按固定节拍逐个吐出，
/// 模拟服务端 SSE 流——思考过程、正文、找人卡片、推荐问穿插到达。
/// demo 无网络依赖，剧本即数据源；真实产品把 onEvent 换成 SSE/WS 解析回调即可
final class DoubaoMockStreamEngine {

    /// 事件出口（主线程回调）
    var onEvent: ((DoubaoMockEvent) -> Void)?

    private var timer: Timer?
    private var queue: [DoubaoMockEvent] = []

    private let interval: TimeInterval

    init(interval: TimeInterval = 0.045) {
        self.interval = interval
    }

    var isRunning: Bool { timer != nil }

    // MARK: - 生命周期
    func start(script: [DoubaoMockEvent]) {
        stop()
        queue = script
        guard !script.isEmpty else { return }
        let timer = Timer(timeInterval: interval, repeats: true) { [weak self] t in
            guard let self else {
                t.invalidate()
                return
            }
            guard !self.queue.isEmpty else {
                self.stop()
                return
            }
            self.onEvent?(self.queue.removeFirst())
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        queue = []
    }

    // MARK: - 剧本
    /// 按用户问题生成一轮完整剧本。三段正文分别用 md 文件做数据源（markdown 流式渲染验证）：
    /// 正文A(tables.md 表格) → 卡片① → 正文B(multi-paragraph.md 多语言段落) → 卡片② → 正文C(math.md 公式) → 推荐问
    static func script(for question: String) -> [DoubaoMockEvent] {
        var events: [DoubaoMockEvent] = []

        // 1. 思考过程（流式增长，打完整段才折叠）
        events.append(.thinkingStart)
        let thinking = """
        用户在问「\(question)」。先拆解问题关键词，明确用户真正想了解的方向。
        检索相关领域的知识：需要覆盖背景概念、核心结论、可操作建议三个层面。
        这个问题涉及专业判断，可以推荐几位该领域的资深人士给用户深入咨询。
        整理回答结构：先给结论，再展开细节，最后补充专家引荐和相关问题推荐。
        """
        events.append(contentsOf: chunks(of: thinking, event: { .thinkingText($0) }, size: 7))
        events.append(.idle)
        events.append(.thinkingEnd(seconds: 3))

        // 2. 正文A：tables.md（表格流式渲染——半截表格行先按文本渲染，行补全后聚合为表格）
        let answerA = "关于「\(question)」，先用一组表格数据给你建立整体认知：\n\n"
            + Self.loadMarkdown("tables")
        events.append(.answerStart)
        events.append(contentsOf: chunks(of: answerA, event: { .answerText($0) }, size: 10))

        // 3. 找人卡片①（正文A定格，卡片结构性插入）
        events.append(contentsOf: Array(repeating: .idle, count: 10))
        events.append(.contactCard(name: "王明远",
                                   title: "架构师 · 前 Alibaba P9",
                                   intro: "12 年分布式系统经验，主导过多个亿级流量系统的架构演进，擅长技术选型与演进路径规划。",
                                   tags: ["系统架构", "技术选型", "高并发"]))

        // 4. 正文B：multi-paragraph.md 前段（多语言混排段落，验证复杂文本排版）
        let answerB = "再从一段多语言排版的文字里看看文本处理的细节，"
            + "顺便推荐一位这个领域的专家：\n\n"
            + String(Self.loadMarkdown("multi-paragraph").prefix(1000))
        events.append(contentsOf: Array(repeating: .idle, count: 10))
        events.append(.answerStart)
        events.append(contentsOf: chunks(of: answerB, event: { .answerText($0) }, size: 10))

        // 5. 找人卡片②
        events.append(contentsOf: Array(repeating: .idle, count: 10))
        events.append(.contactCard(name: "林知夏",
                                   title: "技术负责人 · 现任某 AI 独角兽",
                                   intro: "从 0 到 1 搭过两条业务线，擅长在资源受限的团队里做架构取舍与迭代节奏把控。",
                                   tags: ["0到1", "团队管理", "架构取舍"]))

        // 6. 正文C：math.md（KaTeX 公式流式渲染——半截公式先原文显示，补全后渲染成形）
        let answerC = "\n\n最后附上一组经典公式，直观感受下数学排版的能力：\n\n"
            + Self.loadMarkdown("math")
        events.append(contentsOf: Array(repeating: .idle, count: 10))
        events.append(.answerStart)
        events.append(contentsOf: chunks(of: answerC, event: { .answerText($0) }, size: 10))

        // 7. 推荐问（最后出现）
        events.append(contentsOf: Array(repeating: .idle, count: 10))
        events.append(.recommend(questions: [
            "「\(question)」的主流方案有哪些优缺点？",
            "新手入门该从哪一步开始？",
            "有没有可参考的开源项目？",
        ]))
        return events
    }

    /// 从 bundle 读 md 数据源（Resources 目录已随 target 打包）
    private static func loadMarkdown(_ name: String) -> String {
        guard let path = Bundle.main.path(forResource: name, ofType: "md"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            debugPrint("LBLog mock 数据源 \(name).md 加载失败")
            return "（\(name).md 加载失败）"
        }
        return content
    }

    /// 文本按 size 切块映射为事件（模拟 token 粒度的流式到达）
    private static func chunks(of text: String,
                               event: (String) -> DoubaoMockEvent,
                               size: Int) -> [DoubaoMockEvent] {
        var result: [DoubaoMockEvent] = []
        var buffer = ""
        for ch in text {
            buffer.append(ch)
            if buffer.count >= size {
                result.append(event(buffer))
                buffer = ""
            }
        }
        if !buffer.isEmpty {
            result.append(event(buffer))
        }
        return result
    }
}
