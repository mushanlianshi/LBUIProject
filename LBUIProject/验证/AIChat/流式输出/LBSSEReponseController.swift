//
//  LBSSEReponseController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/7/2.
//

import Foundation

class LBSSEReponseController: UIViewController{
    
    let dataBuffer = NSMutableData()
    var session: URLSession!
    private var receivedData = Data()
    private var outputTextView: UITextView!
    lazy var doubaoParse: LBDouBaoParse = {
        let parser = LBDouBaoParse.init(targetKeys: ["thought", "plan_title", "description"])
        parser.onNewCharacter = { key, value, index  in
            print("字段: \(key), 当前匹配: \(value) \(index)")
        }
        return parser
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let config = URLSessionConfiguration.default
        session = URLSession.init(configuration: config, delegate: self, delegateQueue: nil)
        startStreaming()
        //        testParser()
    }
    
    private func setupUI() {
        outputTextView = UITextView(frame: view.bounds.insetBy(dx: 20, dy: 40))
        outputTextView.font = UIFont.systemFont(ofSize: 14)
        outputTextView.isEditable = false
        outputTextView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.addSubview(outputTextView)
    }
    
    // 使用示例
    func testParser() {
        let parser = LBDouBaoParse.init(targetKeys: ["thought", "plan_title", "description"])
        parser.onNewCharacter = { key, value, index  in
            print("字段: \(key), 当前匹配: \(value) \(index)")
        }
        
        // 模拟流式输入
        let jsonStream = """
        {
          "event": "interrupt",
          "plan_details": {
            "initial_user_query": "帮我写一篇上海人口数据分析报告",
            "locale": "zh-CN",
            "thought": "用户需要一篇关于上海人口数据的分析报告。为了全面覆盖这一主题，需要收集上海人口的历史变化、当前统计数据、未来预测、年龄结构、地域分布、流动人口等多方面信息。",
            "plan_title": "上海人口数据分析报告研究计划",
            "steps": [
              {
                "step_number": 1,
                "title": "上海人口历史演变与现状",
                "description": "收集上海从改革开放以来的人口变化数据，包括总量变化、增长率、户籍人口与外来人口比例等关键指标"
              },
              {
                "step_number": 2,
                "title": "上海人口结构与分布",
                "description": "调研上海当前人口的年龄结构、教育程度、职业分布，以及各区县人口密度和区域分布特征"
              },
              {
                "step_number": 3,
                "title": "上海人口发展趋势与挑战",
                "description": "收集有关上海人口未来发展的预测数据，以及面临的老龄化、人口承载力等问题的研究报告"
              }
            ]
          }
        }
        """.map { String($0) } // 转换为字符数组
        
        
        // 模拟逐个字符输入
        DispatchQueue.global().asyncAfter(deadline: .now(), execute: {
            for char in jsonStream {
                parser.processChunk(char)
                Thread.sleep(forTimeInterval: 0.05) // 为了演示效果，添加短暂延迟
            }
        })
    }
    
    func startStreaming() {
        guard let url = URL.init(string: "http://localhost:8088") else {
            return
        }
        let request = URLRequest(url: url)
        let task = self.session.dataTask(with: request)
        task.resume()
    }
    
    func parseChunkedTextLine(_ line: String) {
        
    }
}


extension LBSSEReponseController: URLSessionDataDelegate{
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        doubaoParse.processChunk(String(data: data, encoding: .utf8) ?? "")
        receivedData.append(data)
        
        // 尝试解析 JSON
        if let text = String(data: receivedData, encoding: .utf8) {
            DispatchQueue.main.async {
                self.outputTextView.text = text
            }
            //                    parseChunkedTextLine( text)
            
            // 尝试解析整个 JSON（最后才会完整）
            if let jsonData = text.data(using: .utf8) {
                do {
                    let obj = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    print("✅ 完整 JSON:", obj)
                } catch {
                    // 尚未完成时不解析
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if let error {
            print("LBLog error is \(error)")
        }else{
            print("LBLog completed ========")
        }
    }
    
    func extractPlanInfo(from text: String) -> (planTitle: String?, thought: String?, descriptions: [String]) {
        var planTitle: String?
        var thought: String?
        var descriptions: [String] = []
        
        // 提取 plan_title
        if let match = text.range(of: #""plan_title"\s*:\s*"([^"]+)""#, options: .regularExpression) {
            planTitle = String(text[match]).components(separatedBy: ":")[1].trimmingCharacters(in: CharacterSet(charactersIn: "\" "))
        }
        
        // 提取 thought
        if let match = text.range(of: #""thought"\s*:\s*"([^"]+)""#, options: .regularExpression) {
            thought = String(text[match]).components(separatedBy: ":")[1].trimmingCharacters(in: CharacterSet(charactersIn: "\" "))
        }
        
        // 提取所有 steps.description
        let regex = try! NSRegularExpression(pattern: #""description"\s*:\s*"([^"]+)""#)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        for match in matches {
            if let range = Range(match.range(at: 1), in: text) {
                let desc = String(text[range])
                descriptions.append(desc)
            }
        }
        
        return (planTitle, thought, descriptions)
    }
}
