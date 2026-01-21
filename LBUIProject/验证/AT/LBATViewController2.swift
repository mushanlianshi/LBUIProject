//
//  LBATViewController2.swift
//  LBUIProject
//
//  Created by liu bin on 2025/11/21.
//


import UIKit

class LBATViewController2: UIViewController {

    let textView = LBMentionTextView()
    let list = [
        Mention(userId: "1", name: "张三"),
        Mention(userId: "2", name: "李四"),
        Mention(userId: "3", name: "王五"),
    ]

    let menu = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupTextView()
        setupMenu()
    }

    private func setupTextView() {
        textView.frame = CGRect(x: 20, y: 120, width: view.bounds.width - 40, height: 200)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray.cgColor
        view.addSubview(textView)

        textView.onMentionTrigger = { [weak self] rect in
            guard let self else { return }
            self.menu.isHidden = false
            self.menu.frame = CGRect(
                x: rect.minX + 20,
                y: rect.maxY + 140,
                width: 150,
                height: 150
            )
        }
    }

    private func setupMenu() {
        menu.dataSource = self
        menu.delegate = self
        menu.isHidden = true
        view.addSubview(menu)
    }
}

extension LBATViewController2: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = list[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textView.insertMention(list[indexPath.row])
        menu.isHidden = true
    }
}
