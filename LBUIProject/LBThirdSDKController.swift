//
//  LBThirdSDKController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/7/27.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import CommonCrypto

class LBThirdSDKController: UIViewController {
    
    lazy var disposeBag = DisposeBag()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    lazy var tableView22: UITableView = {
        let view = UITableView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    lazy var listDataSources: [[String : Any]] = {
        return [[.title : "RxSwift", .controller : LBThirdSDKController.self],
                [.title : "自定义反转Sequence", .controller : LBCustomReverseSequenceController.self],
                [.title : "自定义操作符", .controller : LBCustomOperatorController.self],
                [.title : "where操作符", .controller : LBTestWhereViewController.self],
               ]
    }()

    
    override func viewDidLoad() {
//        super.viewDidLoad()
        initTableView()
        print("LBLog reduce is \(test(input: 1,2,3,4))")
        let coke = Drinking.drinking(name: "Coke")
        print("LBLog color \(coke.color == .black)") // Black
        let beer = Drinking.drinking(name: "Beer")
        print("LBLog color \(beer.color == UIColor.yellow)") //yellow
        
        let testSubProtocol: Drinking = Drinking()
        print("LBLog testSubProtocol \(testSubProtocol.testName())") ///Drinking
        print("LBLog testSubProtocol \(testSubProtocol.testName2())")///Drinking 222
        
        let drinking = testSubProtocol as LBTestProtocolMethod
        print("LBLog testSubProtocol \(drinking.testName())")   ///Drinking
        print("LBLog testSubProtocol \(drinking.testName2())")  ///LBTestProtocol 222
        //drinking 声明是 LBTestProtocolMethod类型 testName是肯定实现的 可以动态调用实际类型的testName方法  testName2方法不一定实现 调用编译器的LBTestProtocolMethod类型的方法  和继承有点区别  继承最终是实际类型的方法执行
    }
    
    func initTableView() {
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let items: Observable<[[String : Any]]> = Observable.create { observer in
            observer.onNext(
                self.listDataSources
            )
            return Disposables.create()
        }
        
        
        
        
        items.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)){
            (row, element, cell) in
            cell.textLabel?.text = element[.title] as? String
        }
        
        tableView.rx.modelSelected([String : Any].self).subscribe(onNext: {
            element in
            self.pushPage(element)
        }).disposed(by: disposeBag)
        
    }
    
    
    func pushPage(_ info: [String : Any]) {
        guard let tmp = info[.controller] as? UIViewController.Type else { return }
        let vc = tmp.init()
        vc.view.backgroundColor = .white
        vc.title = info[.title] as? String
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func test(input: Int...) -> Int{
        let result = input.reduce(100) { x, y in
            print("LBLog x is \(x) y is \(y)")
            return x + y
        }
        return result
    }

}


fileprivate extension String{
    static let title = "title"
    static let controller = "controller"
}


protocol LBTestProtocolMethod {
    func testName() -> String
//    func testName2() -> String
}

extension LBTestProtocolMethod{
    func testName() -> String{
        return "LBTestProtocol"
    }
    func testName2() -> String{
        return "LBTestProtocol 2222 "
    }
}

class Drinking: LBTestProtocolMethod {
    func testName() -> String{
        return " Drinking testName"
    }
    func testName2() -> String{
        return "Drinking testName2"
    }
    typealias LiquidColor = UIColor
    var color: LiquidColor { return .clear }
    class func drinking(name: String) -> Drinking
    {
        var drinking: Drinking
        switch name
        { case "Coke": drinking = Coke()
            case "Beer": drinking = Beer()
            default: drinking = Drinking()
            
        }
        return drinking
    }
}
class Coke: Drinking {
    override var color: LiquidColor { return .black } }
class Beer: Drinking {
    override var color: LiquidColor { return .yellow } }


extension String {
    var MD5: String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = data(using: .utf8)
        { data.withUnsafeBytes
            {
                (bytes: UnsafePointer<UInt8>) -> Void in CC_MD5(bytes, CC_LONG(data.count), &digest) }
        }
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH)
        {
            digestHex += String(format: "%02x", digest[index])
            
        }
        return digestHex
    }
}
