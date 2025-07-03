class LBDouBaoParse {
    // 用于存储匹配状态的结构体
    struct MatchState {
        let key: String
        var value: String
        var isComplete: Bool = false
        var quoteCount: Int = 0  // 跟踪双引号数量，用于判断字符串结束
        var isEscaped: Bool = false  // 标记当前字符是否被转义
        var lastReportedLength: Int = 0  // 记录上次报告的长度
    }
    
    private var buffer = ""
    private var currentMatches: [String: [MatchState]] = [:]  // 支持同一字段多次出现
    private let targetKeys: [String]  // 要匹配的目标字段
    private let dispatchQueue = DispatchQueue(label: "json.parser.queue")
    
    // 用于识别字段开始的正则表达式字典
    private var startRegexMap: [String: NSRegularExpression] = [:]
    
    // 用于通知新匹配的闭包
    var onNewCharacter: ((String, String, Int) -> Void)?  // (key, newValue, instanceIndex)
    
    // 初始化方法，接收要匹配的字段名数组
    init(targetKeys: [String]) {
        self.targetKeys = targetKeys
        
        // 为每个目标字段创建正则表达式
        for key in targetKeys {
            let pattern = "\"\(key)\"\\s*:\\s*\""
            if let regex = try? NSRegularExpression(pattern: pattern) {
                startRegexMap[key] = regex
            }
        }
    }
    
    // 处理新的字符块
    func processChunk(_ chunk: String) {
        dispatchQueue.async {
            self.buffer.append(chunk)
            self.updateMatches()
        }
    }
    
    // 更新匹配状态
    private func updateMatches() {
        for key in targetKeys {
            if let regex = startRegexMap[key] {
                updateState(for: regex, key: key)
            }
        }
    }
    
    // 更新特定字段的匹配状态
    private func updateState(for regex: NSRegularExpression, key: String) {
        let matches = regex.matches(in: buffer, range: NSRange(buffer.startIndex..., in: buffer))
        
        // 为每个匹配创建或更新状态
        for (matchIndex, match) in matches.enumerated() {
            let matchRange = match.range
            let valueStartIndex = buffer.index(buffer.startIndex, offsetBy: matchRange.upperBound)
            
            // 获取或创建匹配状态
            var states = currentMatches[key] ?? []
            if states.count <= matchIndex {
                let newState = MatchState(key: key, value: "")
                states.append(newState)
                currentMatches[key] = states
            }
            
            // 获取当前状态
            var state = states[matchIndex]
            if state.isComplete { continue }
            
            // 处理新增字符
            let availableRange = valueStartIndex..<buffer.endIndex
            let availableText = String(buffer[availableRange])
            let originalLength = state.value.count
            
            for char in availableText {
                if state.isEscaped {
                    state.value.append(char)
                    state.isEscaped = false
                } else if char == "\\" {
                    state.isEscaped = true
                } else if char == "\"" {
                    state.quoteCount += 1
                    if state.quoteCount == 1 {
                        continue
                    } else {
                        state.isComplete = true
                        break
                    }
                } else {
                    state.value.append(char)
                }
            }
            
            // 如果值有变化，通知外部
            if state.value.count > originalLength {
                let newValue = String(state.value.suffix(state.value.count - originalLength))
                onNewCharacter?(key, newValue, matchIndex)
                state.lastReportedLength = state.value.count
            }
            
            // 更新状态
            states[matchIndex] = state
            currentMatches[key] = states
            
            if state.isComplete { break }
        }
    }
}
