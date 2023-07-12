//
//  LBVertifyListController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/24.
//

import Foundation
import HandyJSON
import Moya

struct LBVerifyListItemModel: HandyJSON {
    var name = ""
    var age = ""
}



struct LBVerifyListService: LBMoyaTargetTypeProtocol {
    
    ///实现协议需要的额外参数的属性
    var requestTotalExtraParams: [String : Any]?
    
    ///实现协议需要的path
    var path: String{
        get{
            return "/mock/21/userInfo"
        }
    }
    
//    func requestExtraParams() -> [String : Any]? {
//
//        if let params = requestTotalExtraParams{
//            return ["name" : params.name, "token" : params.token, "P" : params.page, "S" : params.token]
//        }
        
//        if case let .list(name, token, page, count) = self {
//            return ["name" : name, "token" : token, "P" : page, "S" : count]
//        }

//        return nil
        
//        switch self {
//        case .login(let name, let token):
//            return ["name" : name, "token" : token]
//        default:
//            return nil
//        }
//    }
    
}

class LBVerifyListController: UIViewController {
    
    lazy var viewModel = LBVerifyListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "继承基类Controller"
        self.lb_viewModel = viewModel
        addLBTableView(.both)
        self.lb_tableView?.mj_header?.beginRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            [weak self] in
            
            self?.viewModel.extraTotalParams = ["eee" : "ccccc", "dddd" : "ccccc"]
            self?.loadDataIsFooter(isFooter: false)
        })
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.lb_tableView?.frame = view.bounds
    }
}




class LBVerifyListViewModel: LBListBaseViewModel<LBVerifyListItemModel, LBVerifyListService> {
    required init() {
        super.init()
        service = LBVerifyListService()
    }
}
