//
//  LBATDeepSeekViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/11/21.
//

class LBATDeepSeekViewController: UIViewController {
    
    let textView = LBDeepSeekMentionTextView()
    let addMentionButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 设置TextView
        textView.frame = CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 200)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.cornerRadius = 8
//        textView.atBlock = {
//            [weak self] in
//            self?.showUserSelection()
//        }
        view.addSubview(textView)
        
        // 设置添加@按钮
        addMentionButton.frame = CGRect(x: 20, y: 320, width: 120, height: 44)
        addMentionButton.setTitle("添加@用户", for: .normal)
        addMentionButton.addTarget(self, action: #selector(showUserSelection), for: .touchUpInside)
        view.addSubview(addMentionButton)
        
        // 显示被@用户的按钮
        let showUsersButton = UIButton(type: .system)
        showUsersButton.frame = CGRect(x: 160, y: 320, width: 120, height: 44)
        showUsersButton.setTitle("显示@用户", for: .normal)
        showUsersButton.addTarget(self, action: #selector(showMentionedUsers), for: .touchUpInside)
        view.addSubview(showUsersButton)
    }
    
    @objc private func showUserSelection() {
        let alert = UIAlertController(title: "选择用户", message: nil, preferredStyle: .actionSheet)
        
        let users = ["张三", "李四", "王五", "赵六"]
        
        for user in users {
            let action = UIAlertAction(title: user, style: .default) { [weak self] _ in
                self?.textView.addMention(userName: user, userId: user)
            }
            alert.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    @objc private func showMentionedUsers() {
//        let users = textView.getMentionedUsers()
//        let message = users.isEmpty ? "没有@用户" : "被@的用户: \(users.joined(separator: ", "))"
//        
//        let alert = UIAlertController(title: "@用户列表", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "确定", style: .default))
//        present(alert, animated: true)
    }
}
