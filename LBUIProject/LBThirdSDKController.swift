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

class LBTextOutputStreamModel: TextOutputStream {
    func write(_ string: String) {
        
    }
}

//这两种写法的区别在于第二种写法中的 `TextOutputStream` 是作为泛型类型的参数名，而不是传递的参数类型。正确的写法是第一种写法，其中的 `Target` 表示泛型类型参数。它的作用是使代码更为灵活，可以接受任何实现了 `TextOutputStream` 协议的类型作为参数，并且符合泛型编程的设计理念。同时，通过 `where` 关键字的限制条件，也保证了实际使用的泛型类型必须实现了 `TextOutputStream` 协议。
// 第三种 虽然和第一种是一样  但不是泛型了  第一种还可以扩展遵守承别的协议   第三种只能重写方法了
//
//而第二种写法中的 `TextOutputStream` 是作为泛型参数名，这个名字只是一个标识符，并没有实际的含义。该方法在使用的时候，相当于声明了一个泛型类型参数 `Target`，但是要求泛型类型 `Target` 的名称必须是 `TextOutputStream`，这显然是不合法的。
//
//因此，正确的写法是第一种写法。
func writeOne<Target>(to target: inout Target) where Target : TextOutputStream{
    print("LBLog writeOne")
}
///这TextOutputStream已经不是类型了  而是变成了泛型 导致实际传入的对象可以不是遵守TextOutputStream协议的
func writeTwo<TextOutputStream>(to target: inout TextOutputStream){
    print("LBLog writeTwo")
}
///参数是TextOutputStream类型的
func writeThree(to target: inout TextOutputStream){
    print("LBLog writeTwo")
}

func writeThree(to target: inout LBThirdSDKController){
    print("LBLog writeTwo")
}


class LLLClass<Equatable>{
    func testPrint() {
        print("LBLog testPrint Equatable")
    }
}

extension LLLClass<String>{
    func testPrint() {
        print("LBLog testPrint string")
    }
}

class LBGenericClass<T>: NSObject {
}

extension LBGenericClass where T: Equatable{
    func testPrint() {
        print("LBLog LBGenericClass Equatable")
    }
}

extension LBGenericClass where T == String{
    func testPrint() {
        print("LBLog LBGenericClass string")
    }
}

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
        return [[.title : "RxSwift", .controller : LBRxSwiftHomeViewController.self],
                [.title : "自定义反转Sequence", .controller : LBCustomReverseSequenceController.self],
                [.title : "自定义操作符", .controller : LBCustomOperatorController.self],
                [.title : "where操作符", .controller : LBTestWhereViewController.self],
                [.title : "JXPagingView", .controller : LBJXPagingViewController.self],
                [.title : "pageView实现", .controller : LBPageScrollViewController.self],
                [.title : "dynamicMemberLookup转发", .controller : LBTestDynamicMemberLookupController.self],
                [.title : "银行卡格式TextField", .controller : LBBankFormatterTextFieldController.self],
                [.title : "本地化", .controller : LBLocaleViewController.self],
                [.title : "fold卡片", .controller : LBFoldCardViewController.self],
                [.title : "Mayo网络库", .controller : LBTestMayoNetworkController.self],
                [.title : "IJKPlayer 播放器", .controller : LBIJKPlayerController.self],
                [.title : "设计模式", .controller : LBDesignPatternHomeController.self],
                [.title : "SwiftEntryKit弹框", .controller : LBAlertQueueManagerController.self],
        ]
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    lazy var imageView2: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UIImageView().kf.setImage(with: <#T##Source?#>)
//        let label = UILabel.blt.initWithFont(font: UIFontPFFontSize(12)), textColor: .blt.threeThreeBlackColor())
        
        print("LBLog viewDidLoad ====== ")
        let card = CardType.allValues
        let card1 = CardType.allValues
        print("LBLog card \(card) ")
        print("LBLog card11 \(card1) ")
        initTableView()
        print("LBLog reduce 2222 is \(test(input: 1,2,3,4))")
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
        let test: Array = [Any]()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [weak self] in
            //在走一遍viewWillAppear事件
            self?.beginAppearanceTransition(true, animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                //在走一遍vieWdidAppear事件
                self?.endAppearanceTransition()
            }
        }
        
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.imageView2)
        imageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.size.equalTo(CGSize(width: 200, height: 300))
        }
        
        imageView2.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(imageView.snp_bottom)
            make.size.equalTo(CGSize(width: 200, height: 300))
        }
        
        ///Webp
//        imageView.kf.setImage(with: URL.init(string: "https://pic-test-1253618833.cos.ap-shanghai.myqcloud.com/Uploads/housephoto/6607/6606515/cos_3da20edd01824cbd.jpeg"))
//        imageView2.kf.setImage(with: URL.init(string: "https://cdn.baletoo.cn/Uploads/housephoto/6607/6606515/cos_3da20edd01824cbd.jpeg"))
        var one = LBTextOutputStreamModel()
        var two = LBThirdSDKController()
        
        writeOne(to: &one)
        writeTwo(to: &two)
        testGeneric()
    }
    
    func testGeneric() {
        LLLClass<Int>().testPrint()
        LLLClass<String>().testPrint()
        
        LBGenericClass<Int>().testPrint()
        LBGenericClass<String>().testPrint()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("LBLog viewWillAppear ====")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("LBLog viewDidAppear ====")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("LBLog viewWillDisappear ====")
    }
    
}


fileprivate extension String{
    static let title = "title"
    static let controller = "controller"
}


protocol LBTestProtocolMethod {
    func testName() -> String
    //    func testName2() -> String
    var testProtocolProperty: String { get set }
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
    var testProtocolProperty: String{
        set{}
        get{ return "" }
    }
    
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
        {   case "Coke": drinking = Coke()
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


protocol LBAllEnumValues{
    static var allValues: [Self] { get }
}

enum CardType{
    case hei
    case hong
}

extension CardType: LBAllEnumValues{
    static var allValues: [CardType]{
        print("LBLog enumvalue is =======")
        return [.hei, .hong]
    }
}

