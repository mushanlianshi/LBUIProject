//
//  LBRxSwiftTableViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/10.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import BLTUIKitProject

//A present B 如果想在present C   只能用B去present C  A这个时候已经present不出来C了
//A present B 如果B的modalPresentationStyle不是fullScreen  A的viewWillDisappear等的声明周期是不会走的
///RxDataSources封装好了 sectionModel模型  只要使用的时候传进去泛型就好AnimatableSectionModel 遵守->AnimatableSectionModelType ->SectionModelType, IdentifiableType
typealias LBRxNumberSectionModel = AnimatableSectionModel<String, Double>

class LBRxSwiftTableViewController: UIViewController {
    
    lazy var disposeBag = DisposeBag()
    
    lazy var viewModel = LBRxSwiftTableViewModel()
    
    lazy var alertVC = BLTAlertController.init(title: "ewewf", mesage: "", style: .alert, sureTitle: "sure", sureBlock: nil)!
    
    lazy var tableView: UITableView = {
        let tb = UITableView.init(frame: .zero, style: .plain)
        tb.register(LBRxTableViewCell.self, forCellReuseIdentifier: LBRxTableViewCell.blt_className)
        tb.register(LBRxTableSectionView.self, forHeaderFooterViewReuseIdentifier: LBRxTableSectionView.blt_className)
        return tb
    }()
    
    let tabDataSources = RxTableViewSectionedReloadDataSource<LBRxNumberSectionModel>(
            configureCell: { (ds, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: LBRxTableViewCell.blt_className)!
                cell.textLabel?.text = "\(element) @ row \(indexPath.row)"
                return cell
            }
//            titleForHeaderInSection: { dataSource, sectionIndex in
//
//                return dataSource[sectionIndex].model
//            }
            
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Rx TableView"
        view.backgroundColor = .white
        view.addSubview(tableView)
        bindTableView()
        loadData()
        let bubbleView = SpeechBubbleView()
        bubbleView.backgroundColor = .lightGray
        view.addSubview(bubbleView)
        bubbleView.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.top.equalTo(30)
            make.width.equalTo(200)
            make.height.equalTo(60)
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//            print("first present")
//            self.alertVC.modalPresentationStyle = .fullScreen
//            self.present(self.alertVC, animated: true)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                print("first dimiss \(self.alertVC.presentingViewController)")
//                self.alertVC.dismiss(animated: false)
////                self.alertVC.presentingViewController?.viewWillAppear(true)
//                self.alertVC.beginAppearanceTransition(true, animated: true)
////                self.alertVC.endAppearanceTransition()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                    print("second dimiss")
//                    self.present(self.alertVC, animated: true)
//                })
//
//            })
//        })
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    func presentAlert(text: String, vc: UIViewController) -> BLTAlertController{
        let alertVC = BLTAlertController.init(title: text, mesage: "", style: .alert, sureTitle: "确定") { action in
            
        }!
        alertVC.modalPresentationStyle = .fullScreen
        vc.present(alertVC, animated: true)
        return alertVC
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    private func bindTableView(){
        
        
        
        ///绑定数据源和样式的
        viewModel.itemListObserver.bind(to: tableView.rx.items(dataSource: tabDataSources)).disposed(by: disposeBag)
        tableView.rx.itemSelected.subscribe(onNext: { indexPath in
            print("LBLog tap indexPath \(indexPath.section) \(indexPath.row)")
        }).disposed(by: disposeBag)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
//        let config = tableView.rx.items(dataSource: tabDataSources) as? Observable<[LBRxNumberSectionModel]>
        
    }
    
    private func loadData(){
        Observable<Int>.interval(.seconds(3), scheduler: MainScheduler.instance).subscribe { [weak self] time in
            print("LBLog time is \(time)")
            let model = LBRxNumberSectionModel.init(model: "\(time.element)", items: [1, 2, 3])
            self?.viewModel.appendModel(model: model)
        }.disposed(by: disposeBag)

    }
    
    

}

extension LBRxSwiftTableViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: LBRxTableSectionView.blt_className) as! LBRxTableSectionView
        view.titleLab.text = viewModel.list[section].model
        return view
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


struct LBRxSwiftTableViewModel{
    
    var list = [LBRxNumberSectionModel]()
    let itemListObserver: PublishSubject<[LBRxNumberSectionModel]> = PublishSubject<[LBRxNumberSectionModel]>()
    
    mutating func appendModel(model: LBRxNumberSectionModel) {
        list.append(model)
        itemListObserver.onNext(list)
    }
}

class LBRxTableViewCell: UITableViewCell {
    lazy var titleLab = UILabel.blt.initWithFont(font: .blt.normalFont(16), textColor: .blt.threeThreeBlackColor())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        titleLab.textAlignment = .center
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class LBRxTableSectionView: UITableViewHeaderFooterView {
    lazy var titleLab = UILabel.blt.initWithFont(font: .blt.normalFont(16), textColor: .blt.threeThreeBlackColor())
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLab)
        titleLab.backgroundColor = .blt.f6BackgroundColor()
        titleLab.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//func testGenericFunction<T: AnyObject>(){
//    return T()
//}

class SpeechBubbleView: UIView {
    
//    func testGeneric<T: AnyObject>(){
//        return T()
//    }
    
    
    
    var fillColor = UIColor.white
    var borderColor = UIColor.black
    var borderWidth: CGFloat = 1.0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath()
        
        let arrowWidth: CGFloat = 20.0
        let arrowHeight: CGFloat = 10.0
        let cornerRadius: CGFloat = 10.0
        
        // 绘制左上角圆角矩形
        path.move(to: CGPoint(x: cornerRadius, y: 0.0))
        path.addLine(to: CGPoint(x: rect.width - arrowWidth - cornerRadius, y: 0.0))
        path.addArc(withCenter: CGPoint(x: rect.width - arrowWidth - cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: CGFloat(3.0 * Double.pi / 2.0),
                    endAngle: 0.0,
                    clockwise: true)
        path.addLine(to: CGPoint(x: rect.width - arrowWidth, y: arrowHeight))
        path.addLine(to: CGPoint(x: rect.width, y: arrowHeight + cornerRadius))
        path.addArc(withCenter: CGPoint(x: rect.width - arrowWidth - cornerRadius, y: arrowHeight + cornerRadius),
                    radius: cornerRadius,
                    startAngle: 0.0,
                    endAngle: CGFloat(Double.pi / 2.0),
                    clockwise: true)
        path.addLine(to: CGPoint(x: cornerRadius, y: arrowHeight + cornerRadius * 2.0))
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: arrowHeight + cornerRadius),
                    radius: cornerRadius,
                    startAngle: CGFloat(Double.pi / 2.0),
                    endAngle: CGFloat(Double.pi),
                    clockwise: true)
        path.addLine(to: CGPoint(x: 0.0, y: cornerRadius))
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: CGFloat(Double.pi),
                    endAngle: CGFloat(3.0 * Double.pi / 2.0),
                    clockwise: true)
        path.close()
        
        // 绘制箭头
        path.move(to: CGPoint(x: rect.width - arrowWidth, y: arrowHeight))
        path.addLine(to: CGPoint(x: rect.width - arrowWidth / 2.0, y: 0.0))
        path.addLine(to: CGPoint(x: rect.width, y: arrowHeight))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.lineWidth = borderWidth
        
        layer.addSublayer(shapeLayer)
    }
}



