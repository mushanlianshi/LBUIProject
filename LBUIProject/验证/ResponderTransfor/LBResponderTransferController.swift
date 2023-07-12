//
//  LBResponderTransferController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/6/29.
//

import Foundation

public struct LBResponderEvent: Hashable, Equatable, RawRepresentable, Comparable {
    public var rawValue: Int
    public var hashValue: Int{
        return rawValue
    }
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static func < (lhs: LBResponderEvent, rhs: LBResponderEvent) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public static func == (lhs: LBResponderEvent, rhs: LBResponderEvent) -> Bool{
        return lhs.rawValue == rhs.rawValue
    }
}

public extension LBResponderEvent{
    static let mobile = LBResponderEvent.init(rawValue: 1)
    static let contact = LBResponderEvent.init(rawValue: 2)
}


///如果遵守这个协议  就需要实现接受事件的方法
protocol LBResponderTransferProtocol: NSObject{
//    func receiveEvent(_ eventType: Int)
//    func receiveEvent(_ eventType: LBResponderEvent)
    func receiveEvent(_ eventType: LBResponderEvent, obj: Any?)
//    func receiveEvent(_ eventType: Int, obj: Any)
}

extension UIView{
    func transferEvent(_ event: LBResponderEvent, obj: Any?) {
        
        var nextResponder = self.next
        while nextResponder != nil{
            if let resd = nextResponder as? LBResponderTransferProtocol{
                resd.receiveEvent(event, obj: obj)
                nextResponder = nil
                break
            }
            nextResponder = nextResponder?.next
        }
    }
}

/// 针对场景：controller下面有个自定义viewA   自定义viewA中又有个自定义viewB   自定义viewB中又有个自定义viewC
/// viewC中的一个联系按钮点击了   传统的就是block或则代理 一层层代理出去太繁琐， 通知一对多又不友好
/// RxSwift可以解决一些场景  如果是tableview  RxSwift就处理不了了
class LBResponderTransferController: UIViewController {
    
    lazy var list = [1,2,3,4,5,6,7,8,9]
    
    lazy var tableView: UITableView = {
       let view = UITableView.init(frame: .zero, style: .plain)
        view.blt.registerReusableCell(cell: LBResponderTransferViewA.self)
        view.dataSource = self
        view.rowHeight = 44
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "事件传递"
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}


extension LBResponderTransferController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LBResponderTransferViewA.blt_className) as? LBResponderTransferViewA else { return UITableViewCell() }
        cell.refreshTitle(list[indexPath.row].description)
        return cell
    }

}


extension LBResponderTransferController: LBResponderTransferProtocol{
    func receiveEvent(_ eventType: LBResponderEvent, obj: Any?) {
        print("LBLog event type is \(eventType)")
    }
}




class LBResponderTransferViewA: UITableViewCell {
    
    private lazy var titleLab = UILabel.blt.initWithFont(font: .blt.normalFont(14), textColor: .blt.threeThreeBlackColor())
    
    private lazy var bView = LBResponderTransferViewB()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLab)
        contentView.addSubview(bView)
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.bottom.equalToSuperview()
        }
        bView.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
        }
    }
    
    func refreshTitle(_ title: String?) {
        titleLab.text = title
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class LBResponderTransferViewB: UIView {
    private lazy var cView = LBResponderTransferViewC()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(cView)
        cView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class LBResponderTransferViewC: UIView {
    private lazy var button: UIButton = {
        let view = UIButton.blt.initWithTitle(title: "联系", font: .blt.normalFont(14), color: .blt.threeThreeBlackColor(), target: self, action: #selector(buttonClicked))
        view.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonClicked(){
        self.transferEvent(.contact, obj: nil)
    }
}


