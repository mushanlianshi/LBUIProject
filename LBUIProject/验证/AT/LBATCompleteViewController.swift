//
//  LBATCompleteViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/11/21.
//

import UIKit
import SnapKit

// MARK: - 拼音转换
private extension String {
    /// 将中文转为拼音（去声调，小写，带空格）："张三" → "zhang san"
    var pinyin: String {
        let mutable = NSMutableString(string: self) as CFMutableString
        CFStringTransform(mutable, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(mutable, nil, kCFStringTransformStripCombiningMarks, false)
        return (mutable as String).trimmingCharacters(in: .whitespaces)
    }

    /// 连续无空格拼音："张三" → "zhangsan"，用于 "zhangsan" 匹配
    var pinyinContinuous: String { pinyin.replacingOccurrences(of: " ", with: "") }

    /// 将字符串中的中文转为连续拼音，非中文原样保留："张san" → "zhangsan"
    var convertChineseToPinyin: String {
        let mutable = NSMutableString(string: self) as CFMutableString
        CFStringTransform(mutable, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(mutable, nil, kCFStringTransformStripCombiningMarks, false)
        return (mutable as String).replacingOccurrences(of: " ", with: "")
    }
}

// MARK: - @用户 数据模型
struct LBATUserModel {
    let userId: String
    let name: String
}

// MARK: - @功能 完整实现 claude code写的，目前可用版本
/// 特性：
/// 1. 输入 @ 弹出用户选择列表，支持输入文字过滤
/// 2. 支持多个 @ 用户，可相邻也可分开
/// 3. @ 用户高亮展示（蓝色字体）
/// 4. 删除时整体删除 @用户（包括 @ 符号和尾部空格）
/// 5. 光标无法进入 @ 用户内部
class LBATCompleteViewController: UIViewController {

    // MARK: - 用户数据
    private let allUsers: [LBATUserModel] = [
        LBATUserModel(userId: "1", name: "张三"),
        LBATUserModel(userId: "2", name: "李四"),
        LBATUserModel(userId: "3", name: "张三丰"),
        LBATUserModel(userId: "4", name: "张四号"),
        LBATUserModel(userId: "5", name: "孙七"),
        LBATUserModel(userId: "6", name: "周八"),
        LBATUserModel(userId: "7", name: "吴九"),
        LBATUserModel(userId: "8", name: "郑十"),
    ]

    private lazy var filteredUsers: [LBATUserModel] = allUsers

    /// 中文名 → 拼音（连续无空格）缓存，如 "张三" → "zhangsan"
    private lazy var userPinyinMap: [String: String] = {
        Dictionary(uniqueKeysWithValues: allUsers.map { ($0.name, $0.name.pinyinContinuous) })
    }()

    /// 用户名字最大长度，用于判断是否退出 @ 模式
    private lazy var maxUserNameLength: Int = allUsers.map { $0.name.count }.max() ?? 0
    /// 用户名拼音最大长度
    private lazy var maxUserPinyinLength: Int = userPinyinMap.values.map { $0.count }.max() ?? 0

    // MARK: - 富文本属性 Key
    private let mentionKey = NSAttributedString.Key("ATCompleteMentionKey")
    private let mentionIdKey = NSAttributedString.Key("ATCompleteMentionIdKey")

    // MARK: - 状态
    private let defaultFont = UIFont.systemFont(ofSize: 16)
    private var isAtMode = false

    // MARK: - UI 元素
    private lazy var hintLabel: UILabel = {
        let lb = UILabel()
        lb.text = "在输入框中输入 @ 选择用户"
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.textColor = .gray
        return lb
    }()

    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = defaultFont
        tv.layer.borderWidth = 1 / UIScreen.main.scale
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.cornerRadius = 8
        tv.delegate = self
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        return tv
    }()

    private lazy var userTableView: UITableView = {
        let tv = UITableView()
        tv.layer.borderWidth = 1 / UIScreen.main.scale
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.cornerRadius = 8
        tv.dataSource = self
        tv.delegate = self
        tv.isHidden = true
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()

    private lazy var extractButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("提取 @ 用户", for: .normal)
        btn.addTarget(self, action: #selector(didTapExtract), for: .touchUpInside)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemBlue.cgColor
        btn.layer.cornerRadius = 6
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return btn
    }()

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "@功能完整实现"
        setupUI()

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    private func setupUI() {
        view.addSubview(hintLabel)
        view.addSubview(textView)
        view.addSubview(userTableView)
        view.addSubview(extractButton)

        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.left.equalTo(15)
        }

        textView.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(8)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(160)
        }

        userTableView.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(6)
            make.left.right.equalTo(textView)
            make.height.equalTo(44 * 4)
        }

        extractButton.snp.makeConstraints { make in
            make.top.equalTo(userTableView.snp.bottom).offset(15)
            make.left.equalTo(textView)
            make.height.equalTo(36)
        }
    }

    // MARK: - 交互
    @objc private func didTapBackground() {
        view.endEditing(true)
        hideUserList()
    }

    @objc private func didTapExtract() {
        let users = extractMentionedUsers()
        if users.isEmpty {
            showAlert("暂无 @ 用户")
        } else {
            showAlert("已 @ 用户：\(users.joined(separator: "、"))")
        }
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    // MARK: - 用户列表管理
    private func showUserList() {
        filteredUsers = allUsers
        userTableView.reloadData()
        userTableView.isHidden = false
    }

    private func hideUserList() {
        userTableView.isHidden = true
        isAtMode = false
    }

    /// 判断是否应退出 @ 模式（输入超出用户名字最大长度）
    /// 规则：汉字数 > 名字最大长度，或拼音长度 > 名字拼音最大长度
    private func shouldExitAtMode(query: String) -> Bool {
        if query.isEmpty { return false }
        let hasPinyin = query.lowercased().rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil
        if hasPinyin {
            return query.lowercased().convertChineseToPinyin.count > maxUserPinyinLength
        } else {
            return query.count > maxUserNameLength
        }
    }

    /// 根据 @ 后面的文字过滤用户列表
    /// - 含有拼音字母 → 全文转拼音做拼音匹配
    /// - 纯中文 → 中文名匹配
    /// - 无匹配 → 全列表
    private func updateFilter() {
        guard isAtMode, let atPos = findLastUnmentionAtBeforeCursor() else {
            hideUserList()
            return
        }
        let cursor = textView.selectedRange.location
        guard cursor > atPos else { return }

        let query = (textView.text as NSString).substring(with: NSRange(location: atPos + 1, length: cursor - atPos - 1))

        // 超出名字最大长度 → 就不在查询了，后面有需要可以直接退出@模式 调用hideUserList。  不退出，删除回来还能进入at模式
        if shouldExitAtMode(query: query) {
            userTableView.isHidden = true
//            hideUserList()
            return
        }

        if query.isEmpty {
            filteredUsers = allUsers
        } else {
            let hasPinyin = query.lowercased().rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil

            if hasPinyin {
                // 含拼音字母 → 中文转拼音后整体匹配
                let pinyinQuery = query.lowercased().convertChineseToPinyin
                debugPrint("LBLog query pinyin \(pinyinQuery)")
                filteredUsers = allUsers.filter { user in
                    guard let pinyin = userPinyinMap[user.name] else { return false }
                    return pinyin.contains(pinyinQuery)
                }
            } else {
                debugPrint("LBLog query hanzi \(query)")
                // 纯中文 → 中文名匹配
                filteredUsers = allUsers.filter { $0.name.contains(query) }
            }

//            if filteredUsers.isEmpty { filteredUsers = allUsers }
        }

        userTableView.reloadData()
        userTableView.isHidden = false
    }

    // MARK: - 查找 @ 位置
    /// 从光标位置往前查找最近的、不属于已有 mention 的 @ 符号
    private func findLastUnmentionAtBeforeCursor() -> Int? {
        guard let attributedText = textView.attributedText else { return nil }
        let cursor = textView.selectedRange.location
        let fullText = attributedText.string as NSString
        for i in (0 ..< cursor).reversed() {
            if fullText.substring(with: NSRange(location: i, length: 1)) == "@",
               attributedText.attribute(mentionKey, at: i, effectiveRange: nil) == nil {
                return i
            }
        }
        return nil
    }

    // MARK: - 插入 @ 用户
    private func insertMention(_ user: LBATUserModel) {
        guard let atPos = findLastUnmentionAtBeforeCursor() else {
            insertMentionAtCursor(user)
            return
        }
        let cursor = textView.selectedRange.location
        let replaceRange = NSRange(location: atPos, length: cursor - atPos)
        let mentionAttr = buildMentionAttributedString(user)
        let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
        mutable.replaceCharacters(in: replaceRange, with: mentionAttr)
        applyAttributedText(mutable, cursorAt: atPos + mentionAttr.length)
        isAtMode = false
        hideUserList()
    }

    /// 兜底：直接在光标处插入
    private func insertMentionAtCursor(_ user: LBATUserModel) {
        let cursor = textView.selectedRange.location
        let mentionAttr = buildMentionAttributedString(user)
        let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
        mutable.insert(mentionAttr, at: cursor)
        applyAttributedText(mutable, cursorAt: cursor + mentionAttr.length)
        hideUserList()
    }

    /// 构建 @用户 富文本
    private func buildMentionAttributedString(_ user: LBATUserModel) -> NSMutableAttributedString {
        let text = "@\(user.name) "
        let attr = NSMutableAttributedString(string: text, attributes: mentionAttributes)
        attr.addAttribute(mentionKey, value: text, range: NSRange(location: 0, length: text.count))
        attr.addAttribute(mentionIdKey, value: user.userId, range: NSRange(location: 0, length: text.count))
        debugPrint("LBLog add mentionIdKey \(user.userId)")
        debugPrint("LBLog add mentionKey \(text)")
        return attr
    }

    private func applyAttributedText(_ attr: NSMutableAttributedString, cursorAt location: Int) {
        textView.attributedText = attr
        textView.selectedRange = NSRange(location: location, length: 0)
        textView.typingAttributes = defaultTypingAttributes
    }

    // MARK: - 提取所有 @ 用户
    private func extractMentionedUsers() -> [String] {
        guard let attr = textView.attributedText else { return [] }
        var users: [String] = []
        attr.enumerateAttribute(mentionIdKey, in: NSRange(location: 0, length: attr.length), options: []) { value, _, _ in
            guard let userId = value as? String, userId.count > 0 else { return }
            if let user = allUsers.first(where: { $0.userId == userId }) {
                users.append(user.name)
            }
        }
        return users
    }

    // MARK: - 富文本属性
    private var mentionAttributes: [NSAttributedString.Key: Any] {
        [.font: defaultFont, .foregroundColor: UIColor.systemBlue]
    }

    private var defaultTypingAttributes: [NSAttributedString.Key: Any] {
        [.font: defaultFont, .foregroundColor: UIColor.label]
    }
}

// MARK: - UIGestureRecognizerDelegate
extension LBATCompleteViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 点击在用户列表内部时，不拦截触摸，让 tableView 处理
        if let view = touch.view, view.isDescendant(of: userTableView) {
            return false
        }
        return true
    }
}

// MARK: - UITextViewDelegate
extension LBATCompleteViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.markedTextRange != nil { return true }

        // 输入 @ → 弹出用户列表
        if text == "@" {
            isAtMode = true
            showUserList()
            return true
        }

        // 按下删除键
        if text.isEmpty, range.length == 1 {
//            debugPrint("LBLog delete text textView.text \(textView.text ?? "")")
            return handleBackspace(textView: textView, range: range)
        }

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        updateFilter()
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        protectCursor()

        // @ 模式下光标移动到 @ 之前 → 取消 @ 模式
        guard isAtMode else { return }
        if let atPos = findLastUnmentionAtBeforeCursor() {
            if textView.selectedRange.location <= atPos {
                hideUserList()
            }
        } else {
            hideUserList()
        }
    }

    // MARK: - 删除处理
    private func handleBackspace(textView: UITextView, range: NSRange) -> Bool {
        guard let full = textView.attributedText else { return true }
        let location = range.location
        if location == 0 { return true }

        if deleteMentionIfNeeded(full: full, at: location) { return false }
        return true
    }

    private func deleteMentionIfNeeded(full: NSAttributedString, at location: Int) -> Bool {
        var effectiveRange = NSRange(location: 0, length: 0)
        guard full.attribute(mentionKey, at: location, longestEffectiveRange: &effectiveRange, in: NSRange(location: 0, length: full.length)) != nil else {
            return false
        }

        // 保险：如果 effectiveRange 没包含 @，往前扩展一位
        var deleteRange = effectiveRange
        if deleteRange.location > 0 {
            let prevChar = (full.string as NSString).substring(with: NSRange(location: deleteRange.location - 1, length: 1))
            if prevChar == "@" {
                deleteRange.location -= 1
                deleteRange.length += 1
            }
        }

        let mutable = NSMutableAttributedString(attributedString: full)
        mutable.deleteCharacters(in: deleteRange)
        applyAttributedText(mutable, cursorAt: deleteRange.location)
        return true
    }

    // MARK: - 光标保护
    /// 防止光标落在 @ 用户中间（允许落在开头和末尾）
    private func protectCursor() {
        let pos = textView.selectedRange.location
        guard let attr = textView.attributedText, pos < attr.length else { return }

        var effectiveRange = NSRange(location: 0, length: 0)
        if attr.attribute(mentionKey, at: pos, effectiveRange: &effectiveRange) != nil,
           pos > effectiveRange.location {
            textView.selectedRange = NSRange(location: effectiveRange.location + effectiveRange.length, length: 0)
        }
    }
    
}

// MARK: - UITableViewDelegate & DataSource
extension LBATCompleteViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let user = filteredUsers[indexPath.row]
        cell.textLabel?.text = "@\(user.name)"
        cell.textLabel?.textColor = .systemBlue
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = filteredUsers[indexPath.row]
        insertMention(user)
    }
}
