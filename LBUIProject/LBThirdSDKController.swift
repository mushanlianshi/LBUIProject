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
    target.write("1123")
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

class LBThirdSDKController: LBBaseCollectionViewController {
    
    lazy var disposeBag = DisposeBag()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.showsVerticalScrollIndicator = false
        view.rowHeight = 55
        return view
    }()
    
    lazy var tableView22: UITableView = {
        let view = UITableView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    lazy var shadowBtn: UIButton = {
       let button = UIButton.blt.initWithTitle(title: "test", font: .blt.normalFont(16), color: .white)
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = button.bounds
        button.layer.insertSublayer(gradient, at: 0)

        button.layer.cornerRadius = 20
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.red.cgColor

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 10
        return button
    }()
    
    override var dataSources: [LBListItemModel]{
        set{}
        get{
            var list = [
                LBListItemModel.init(title: "验证RxSwift", vcClass: LBRxSwiftHomeViewController.self),
                LBListItemModel.init(title: "自定义反转Sequence", vcClass: LBCustomReverseSequenceController.self),
                LBListItemModel.init(title: "自定义操作符", vcClass: LBCustomOperatorController.self),
                LBListItemModel.init(title: "where操作符", vcClass: LBTestWhereViewController.self),
                LBListItemModel.init(title: "JXPagingView", vcClass: LBJXPagingViewController.self),
                LBListItemModel.init(title: "pageView实现", vcClass: LBPageScrollViewController.self),
                LBListItemModel.init(title: "dynamicMemberLookup转发", vcClass: LBTestDynamicMemberLookupController.self),
                LBListItemModel.init(title: "银行卡格式TextField", vcClass: LBBankFormatterTextFieldController.self),
                LBListItemModel.init(title: "本地化", vcClass: LBLocaleViewController.self),
                LBListItemModel.init(title: "fold卡片", vcClass: LBFoldCardViewController.self),
                LBListItemModel.init(title: "Mayo网络库", vcClass: LBTestMayoNetworkController.self),
                LBListItemModel.init(title: "JVideoPlayer 播放器", vcClass: LBSJVideoPlayerController.self),
                LBListItemModel.init(title: "设计模式", vcClass: LBDesignPatternHomeController.self),
                LBListItemModel.init(title: "SwiftEntryKit弹框", vcClass: LBAlertQueueManagerController.self),
                LBListItemModel.init(title: "UICollectionViewCompositionalLayout布局", vcClass: LBCollectionCompositionLayoutViewController.self),
                LBListItemModel.init(title: "骨架屏", vcClass: LBTabAnimatedViewController.self),
                LBListItemModel.init(title: "GPUImage图片滤镜", vcClass: LBGPUImageFilterViewController.self),
//                LBListItemModel.init(title: "down三方库渲染表格", vcClass: LBDownTableTestController.self),
                LBListItemModel.init(title: "SmartCodable替换HandyJson", vcClass: LBSmartCodableReplaceHandyjsonController.self),
            ]
            // IJKMediaFramework 仅含真机 arm64 切片，模拟器下不注册入口
#if !targetEnvironment(simulator)
            list.append(LBListItemModel.init(title: "IJKPlayer 播放器", vcClass: LBIJKPlayerController.self))
#endif
            return list
        }
    }
    
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
        testLBUserDefaultWrapped()
    }
    
    
    func testLBUserDefaultWrapped() {
        UserDefaults.standard.setValue(nil, forKey: "househouse")
        print("LBLog househouse \(UserDefaults.standard.value(forKey: "househouse"))")
        print("LBLog userdefaulvalue \(UserDefaults.hasShowGuidePage)")
        UserDefaults.currentVersion = "1.2.23"
        print("LBLog currentVersion \(UserDefaults.currentVersion)")
        
        UserDefaults.houseId = nil
        print("LBLog houseId \(UserDefaults.houseId)")
    }
    
    func testGeneric() {
        LLLClass<Int>().testPrint()
        LLLClass<String>().testPrint()
        
        LBGenericClass<Int>().testPrint()
        LBGenericClass<String>().testPrint()
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

extension LBThirdSDKController{
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSources[indexPath.row]
        guard let vcClass = item.vcClass as? UIViewController.Type else {
            return
        }
        let vc = vcClass.init()
        vc.view.backgroundColor = .white
        vc.navigationItem.title = item.title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


extension String{
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

enum CardType: CaseIterable{
    case hei
    case hong
}

