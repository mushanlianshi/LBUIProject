//
//  LBAIChatViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/9/1.
//

import Foundation


import UIKit
import Down   // Markdown 渲染库（CocoaPods / SwiftPM 安装）

// 每段内容
struct MarkdownChunk {
    var text: String
}

// MARK: - Stream Buffer (节流优化)
actor StreamBuffer {
    private var buffer = ""
    private var flushTask: Task<Void, Never>?

    func append(_ token: String, flush: @escaping (String) -> Void) {
        buffer.append(token)
        flushTask?.cancel()
        flushTask = Task {
            try? await Task.sleep(nanoseconds: 30_000_000) // 30ms
            if !Task.isCancelled {
                let out = buffer
                buffer = ""
                await MainActor.run {
                    flush(out)
                }
            }
        }
    }
}

// MARK: - Cell
class MarkdownCell: UITableViewCell {
    let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label.numberOfLines = 0
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
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
class LBAIChatViewController: UITableViewController {
    private var chunks: [MarkdownChunk] = [MarkdownChunk(text: "")]
    private let buffer = StreamBuffer()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MarkdownCell.self, forCellReuseIdentifier: "MarkdownCell")

        // 模拟流式输出
        Task {
            let tokens = sampleTokens()
            for token in tokens {
                try? await Task.sleep(nanoseconds: 20_000_000) // 模拟服务端 50ms 1个token
                await buffer.append(token) { [weak self] batched in
                    self?.appendText(batched)
                }
            }
        }
    }

    private func appendText(_ text: String) {
        guard var last = chunks.last else { return }
        UIView.setAnimationsEnabled(false)
        if last.text.count > 500 {
            chunks.append(MarkdownChunk(text: text))
            let indexPath = IndexPath(row: chunks.count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .fade)
        } else {
            last.text.append(text)
            chunks[chunks.count - 1] = last
            let indexPath = IndexPath(row: chunks.count - 1, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? MarkdownCell {
                cell.configure(text: last.text)
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.scrollToRow(at: IndexPath(row: chunks.count - 1, section: 0), at: .bottom, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chunks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarkdownCell", for: indexPath) as! MarkdownCell
        cell.configure(text: chunks[indexPath.row].text)
        return cell
    }
}

// MARK: - 模拟服务器 tokens
func sampleTokens() -> [String] {
    let longMarkdown = """
    《西游记》是中国古典四大名著之一，由明代小说家吴承恩创作，是中国古代第一部浪漫主义章回体长篇神魔小说。以下是关于《西游记》的详细介绍：
        ---
        ### 一、基本信息
        - **作者**：吴承恩（字汝忠，号射阳居士），明代文学家。
        - **成书时间**：十六世纪中叶（约1522—1566年）。
        - **地位**：与《三国演义》《水浒传》《红楼梦》并称中国古典四大名著，是中国神魔小说的经典之作。
        ---
        ### 二、故事梗概
        《西游记》以“唐僧取经”这一历史事件为蓝本，通过艺术加工，讲述了唐僧师徒四人西天取经的传奇故事：
        1. **孙悟空的起源**：孙悟空由仙石孕育而生，后拜师菩提祖师，习得七十二变、筋斗云等神通，大闹天宫，被如来佛祖压在五行山下。
        2. **唐僧的来历**：唐僧原为佛祖的二弟子金蝉子，因犯错被贬下凡，后在唐朝出家，受命前往西天取经。
        3. **取经之路**：唐僧在五行山救出孙悟空，后收猪八戒、沙僧为徒，师徒四人历经九九八十一难，降妖伏魔，最终到达西天取得真经，修成正果。主要人物主要
    ###人物名称
    1. **孙悟空**
       - 别名：齐天大圣、美猴王、孙行者
       - 武器：如意金箍棒
       - 性格：嫉恶如仇、机智勇敢、桀骜不驯
       - 特点：七十二变、火眼金睛、筋斗云
    2. **唐僧**
       - 别名：陈玄奘、金蝉子
       - 性格：慈悲为怀、坚定执着
       - 角色：取经的核心人物，象征着普度众生的佛教精神
    3. **猪八戒**
       - 别名：悟能、天蓬元帅
       - 武器：九齿钉耙
       - 性格：好吃懒做、贪图小便宜，但忠心耿耿
    4. **沙僧**
       - 别名：悟净、卷帘大将
       - 武器：月牙铲
       - 性格：沉默寡言、任劳任怨
    5. **白龙马**
       - 原为西海龙王之子，后化作白马驮载唐僧，最终修成正果。
    ---
    ### 四、主题思想
    1. **惩恶扬善**：通过师徒四人降妖伏魔的故事，表达了对正义的追求和对邪恶的憎恶。
    2. **团队合作**：师徒四人各有所长，共同克服困难，体现了团队合作的重要性。
    3. **坚持与信念**：唐僧历经磨难仍不改初心，象征着对理想的执着追求。
    4. **社会现实的反映**：小说通过虚构的情节，隐喻了封建社会的黑暗与腐败。
    ---
    ### 五、艺术特色
    1. **浪漫主义手法**：以丰富的想象和夸张的手法，构建了一个奇幻的神话世界。
    2. **生动的动物形象**：将动物拟人化，赋予其鲜明的性格和复杂的内心世界。
    3. **讽刺与幽默**：通过对天庭、人间的描写，巧妙地讽刺了封建社会的弊端。
    ---
    ### 六、文化影响
    1. **文学地位**：《西游记》是中国古代文学的巅峰之作，对后世文学创作影响深远。
    2. **传播与翻译**：自问世以来，被翻译成多种语言，成为世界文学的经典之作。
    3. **文化符号**：孙悟空、猪八戒等形象已成为中国文化的重要符号，广泛应用于影视、动漫等领域。
    ---
    《西游记》不仅是一部神话小说，更是一部蕴含深刻哲理和社会批判的经典作品，值得细细品味。

    《西游记》是中国古典四大名著之一，由明代小说家吴承恩创作，是中国古代第一部浪漫主义章回体长篇神魔小说。以下是关于《西游记》的详细介绍：
    ---
    ### 一、基本信息
    - **作者**：吴承恩（字汝忠，号射阳居士），明代文学家。
    - **成书时间**：十六世纪中叶（约1522—1566年）。
    - **地位**：与《三国演义》《水浒传》《红楼梦》并称中国古典四大名著，是中国神魔小说的经典之作。
    ---
    ### 二、故事梗概
    《西游记》以“唐僧取经”这一历史事件为蓝本，通过艺术加工，讲述了唐僧师徒四人西天取经的传奇故事：
    1. **孙悟空的起源**：孙悟空由仙石孕育而生，后拜师菩提祖师，习得七十二变、筋斗云等神通，大闹天宫，被如来佛祖压在五行山下。
    2. **唐僧的来历**：唐僧原为佛祖的二弟子金蝉子，因犯错被贬下凡，后在唐朝出家，受命前往西天取经。
    3. **取经之路**：唐僧在五行山救出孙悟空，后收猪八戒、沙僧为徒，师徒四人历经九九八十一难，降妖伏魔，最终到达西天取得真经，修成正果。
    ---
    ### 三、主要人物
    1. **孙悟空**
       - 别名：齐天大圣、美猴王、孙行者
       - 武器：如意金箍棒
       - 性格：嫉恶如仇、机智勇敢、桀骜不驯
       - 特点：七十二变、火眼金睛、筋斗云
    2. **唐僧**
       - 别名：陈玄奘、金蝉子
       - 性格：慈悲为怀、坚定执着
       - 角色：取经的核心人物，象征着普度众生的佛教精神
    3. **猪八戒**
       - 别名：悟能、天蓬元帅
       - 武器：九齿钉耙
       - 性格：好吃懒做、贪图小便宜，但忠心耿耿
    4. **沙僧**
       - 别名：悟净、卷帘大将
       - 武器：月牙铲
       - 性格：沉默寡言、任劳任怨
    5. **白龙马**
       - 原为西海龙王之子，后化作白马驮载唐僧，最终修成正果。
    ---
    ### 四、主题思想
    1. **惩恶扬善**：通过师徒四人降妖伏魔的故事，表达了对正义的追求和对邪恶的憎恶。
    2. **团队合作**：师徒四人各有所长，共同克服困难，体现了团队合作的重要性。
    3. **坚持与信念**：唐僧历经磨难仍不改初心，象征着对理想的执着追求。
    4. **社会现实的反映**：小说通过虚构的情节，隐喻了封建社会的黑暗与腐败。
    ---
    ### 五、艺术特色
    1. **浪漫主义手法**：以丰富的想象和夸张的手法，构建了一个奇幻的神话世界。
    2. **生动的动物形象**：将动物拟人化，赋予其鲜明的性格和复杂的内心世界。
    3. **讽刺与幽默**：通过对天庭、人间的描写，巧妙地讽刺了封建社会的弊端。
    ---
    ### 六、文化影响
    1. **文学地位**：《西游记》是中国古代文学的巅峰之作，对后世文学创作影响深远。
    2. **传播与翻译**：自问世以来，被翻译成多种语言，成为世界文学的经典之作。
    3. **文化符号**：孙悟空、猪八戒等形象已成为中国文化的重要符号，广泛应用于影视、动漫等领域。
    ---
    《西游记》不仅是一部神话小说，更是一部蕴含深刻哲理和社会批判的经典作品，值得细细品味。

    《西游记》是中国古典四大名著之一，由明代小说家吴承恩创作，是中国古代第一部浪漫主义章回体长篇神魔小说。以下是关于《西游记》的详细介绍：
    ---
    ### 一、基本信息
    - **作者**：吴承恩（字汝忠，号射阳居士），明代文学家。
    - **成书时间**：十六世纪中叶（约1522—1566年）。
    - **地位**：与《三国演义》《水浒传》《红楼梦》并称中国古典四大名著，是中国神魔小说的经典之作。
    ---
    ### 二、故事梗概
    《西游记》以“唐僧取经”这一历史事件为蓝本，通过艺术加工，讲述了唐僧师徒四人西天取经的传奇故事：
    1. **孙悟空的起源**：孙悟空由仙石孕育而生，后拜师菩提祖师，习得七十二变、筋斗云等神通，大闹天宫，被如来佛祖压在五行山下。
    2. **唐僧的来历**：唐僧原为佛祖的二弟子金蝉子，因犯错被贬下凡，后在唐朝出家，受命前往西天取经。
    3. **取经之路**：唐僧在五行山救出孙悟空，后收猪八戒、沙僧为徒，师徒四人历经九九八十一难，降妖伏魔，最终到达西天取得真经，修成正果。
    ---
    ### 三、主要人物
    1. **孙悟空**
       - 别名：齐天大圣、美猴王、孙行者
       - 武器：如意金箍棒
       - 性格：嫉恶如仇、机智勇敢、桀骜不驯
       - 特点：七十二变、火眼金睛、筋斗云
    2. **唐僧**
       - 别名：陈玄奘、金蝉子
       - 性格：慈悲为怀、坚定执着
       - 角色：取经的核心人物，象征着普度众生的佛教精神
    3. **猪八戒**
       - 别名：悟能、天蓬元帅
       - 武器：九齿钉耙
       - 性格：好吃懒做、贪图小便宜，但忠心耿耿
    4. **沙僧**
       - 别名：悟净、卷帘大将
       - 武器：月牙铲
       - 性格：沉默寡言、任劳任怨
    5. **白龙马**
       - 原为西海龙王之子，后化作白马驮载唐僧，最终修成正果。
    ---
    ### 四、主题思想
    1. **惩恶扬善**：通过师徒四人降妖伏魔的故事，表达了对正义的追求和对邪恶的憎恶。
    2. **团队合作**：师徒四人各有所长，共同克服困难，体现了团队合作的重要性。
    3. **坚持与信念**：唐僧历经磨难仍不改初心，象征着对理想的执着追求。
    4. **社会现实的反映**：小说通过虚构的情节，隐喻了封建社会的黑暗与腐败。
    ---
    ### 五、艺术特色
    1. **浪漫主义手法**：以丰富的想象和夸张的手法，构建了一个奇幻的神话世界。
    2. **生动的动物形象**：将动物拟人化，赋予其鲜明的性格和复杂的内心世界。
    3. **讽刺与幽默**：通过对天庭、人间的描写，巧妙地讽刺了封建社会的弊端。
    ---
    ### 六、文化影响
    1. **文学地位**：《西游记》是中国古代文学的巅峰之作，对后世文学创作影响深远。
    2. **传播与翻译**：自问世以来，被翻译成多种语言，成为世界文学的经典之作。
    3. **文化符号**：孙悟空、猪八戒等形象已成为中国文化的重要符号，广泛应用于影视、动漫等领域。
    ---
    《西游记》不仅是一部神话小说，更是一部蕴含深刻哲理和社会批判的经典作品，值得细细品味。

    《西游记》是中国古典四大名著之一，由明代小说家吴承恩创作，是中国古代第一部浪漫主义章回体长篇神魔小说。以下是关于《西游记》的详细介绍：
    ---
    ### 一、基本信息
    - **作者**：吴承恩（字汝忠，号射阳居士），明代文学家。
    - **成书时间**：十六世纪中叶（约1522—1566年）。
    - **地位**：与《三国演义》《水浒传》《红楼梦》并称中国古典四大名著，是中国神魔小说的经典之作。
    ---
    ### 二、故事梗概
    《西游记》以“唐僧取经”这一历史事件为蓝本，通过艺术加工，讲述了唐僧师徒四人西天取经的传奇故事：
    1. **孙悟空的起源**：孙悟空由仙石孕育而生，后拜师菩提祖师，习得七十二变、筋斗云等神通，大闹天宫，被如来佛祖压在五行山下。
    2. **唐僧的来历**：唐僧原为佛祖的二弟子金蝉子，因犯错被贬下凡，后在唐朝出家，受命前往西天取经。
    3. **取经之路**：唐僧在五行山救出孙悟空，后收猪八戒、沙僧为徒，师徒四人历经九九八十一难，降妖伏魔，最终到达西天取得真经，修成正果。
    ---
    ### 三、主要人物
    1. **孙悟空**
       - 别名：齐天大圣、美猴王、孙行者
       - 武器：如意金箍棒
       - 性格：嫉恶如仇、机智勇敢、桀骜不驯
       - 特点：七十二变、火眼金睛、筋斗云
    2. **唐僧**
       - 别名：陈玄奘、金蝉子
       - 性格：慈悲为怀、坚定执着
       - 角色：取经的核心人物，象征着普度众生的佛教精神
    3. **猪八戒**
       - 别名：悟能、天蓬元帅
       - 武器：九齿钉耙
       - 性格：好吃懒做、贪图小便宜，但忠心耿耿
    4. **沙僧**
       - 别名：悟净、卷帘大将
       - 武器：月牙铲
       - 性格：沉默寡言、任劳任怨
    5. **白龙马**
       - 原为西海龙王之子，后化作白马驮载唐僧，最终修成正果。
    ---
    ### 四、主题思想
    1. **惩恶扬善**：通过师徒四人降妖伏魔的故事，表达了对正义的追求和对邪恶的憎恶。
    2. **团队合作**：师徒四人各有所长，共同克服困难，体现了团队合作的重要性。
    3. **坚持与信念**：唐僧历经磨难仍不改初心，象征着对理想的执着追求。
    4. **社会现实的反映**：小说通过虚构的情节，隐喻了封建社会的黑暗与腐败。
    ---
    ### 五、艺术特色
    1. **浪漫主义手法**：以丰富的想象和夸张的手法，构建了一个奇幻的神话世界。
    2. **生动的动物形象**：将动物拟人化，赋予其鲜明的性格和复杂的内心世界。
    3. **讽刺与幽默**：通过对天庭、人间的描写，巧妙地讽刺了封建社会的弊端。
    ---
    ### 六、文化影响
    1. **文学地位**：《西游记》是中国古代文学的巅峰之作，对后世文学创作影响深远。
    2. **传播与翻译**：自问世以来，被翻译成多种语言，成为世界文学的经典之作。
    3. **文化符号**：孙悟空、猪八戒等形象已成为中国文化的重要符号，广泛应用于影视、动漫等领域。
    ---
    《西游记》不仅是一部神话小说，更是一部蕴含深刻哲理和社会批判的经典作品，值得细细品味。
    """
    return longMarkdown.map { String($0) } // 模拟 token 流（一个字一个字）
}

