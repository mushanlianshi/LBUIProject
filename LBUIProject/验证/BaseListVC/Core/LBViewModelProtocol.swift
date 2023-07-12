//
//  LBViewModelProtocol.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/25.
//

import Foundation
import HandyJSON
import Moya


///ViewModel 需要准守的协议 提供获取list数据的方法
public protocol LBBaseViewModelProtocol: AnyObject{
    
    associatedtype ModelType: HandyJSON
    
    associatedtype ServiceTarget: LBMoyaTargetTypeProtocol
    
    var service: ServiceTarget? { get set }
    
    var provider: MoyaProvider<ServiceTarget>? { get set}
    
    ///额外的参数  需要额外的参数的 使用了属性 没有用下面说的方法  需要子类来实现  如果实现的是类或则struct 就可以set get当一个存储属性来实现了 如果是enum来实现  只能是计算属性了
    ///(用方法没有用属性  是因为此协议可以被enum实现  如果用enum来实现的话  就不能用存储属性了  只能用计算属性 所以这里选择了用方法来实现)
    var extraTotalParams: [String : Any]? { get set }
    
}


//extension LBBaseViewModelProtocol{
    
//}





///不是列表的viewmodel协议
public protocol LBViewModelProtocol: LBBaseViewModelProtocol{
    var resultModel: ModelType? { get set }
}



///listView 的viewmodel协议
public protocol LBListViewModelProtocol: LBBaseViewModelProtocol where ServiceTarget: LBMoyaTargetTypeProtocol{
    
    ///获取数据请求的
    func loadDataIsFooter(_ isFooter: Bool, successBlock: (@escaping () -> Void), failureBlock: (@escaping (_ error: Error?) -> Void))
    
    
    var dataList: [ModelType] { get set }
    
    func getModelList(from result: [String : Any]?) -> [ModelType]
    
    var page: Int { get set }
    
    var count: Int { get set }
    
    var hasMoreData: Bool { get set }
    
}


extension LBListViewModelProtocol{
    
    func getModelList(from result: [String : Any]?) -> [ModelType]{
        guard let list = result?["list"] as? [[String : Any]] else{
            return [ModelType]()
        }
        let result = list.map { dic in
            ModelType.deserialize(from: dic)
        }.compactMap{ $0 }
        return result
    }
    
    ///获取数据请求的
    func loadDataIsFooter(_ isFooter: Bool, successBlock: (@escaping () -> Void), failureBlock: (@escaping (_ error: Error?) -> Void)){
        guard let _ = service else { return }
        if isFooter == false{
            self.page = 1
        }
        
        var totalParams = [String : Any]()
        totalParams = totalParams.blt.addEntriesFromDic(dic: extraTotalParams)
        totalParams["P"] = self.page
        totalParams["S"] = self.count
        
        service?.requestTotalExtraParams = totalParams
        
        provider?.request(service!, completion: { [weak self] result in
            guard let weakSelf = self else { return }
            let result = LBMoyaProviderResult.convertToBusinessResult(result: result)
            switch result{
                case .success(let res):
                let list = weakSelf.getModelList(from: res.businessResult)
                weakSelf.dataList.append(contentsOf: list)
                weakSelf.page += 1
                weakSelf.hasMoreData = !list.isEmpty
            case .failure(_):
                failureBlock(nil)
            }
        })
    }
}






///默认实现了一个基类的viewModel  也可以自己实现viewmodel遵守LBListViewModelProtocol协议即可  实现一个基类是为了方便初始化一些变量
class LBListBaseViewModel<T: HandyJSON, ServiceType: LBMoyaTargetTypeProtocol>: NSObject, LBListViewModelProtocol {
    
    var extraTotalParams: [String : Any]?{
        didSet{
            service?.requestTotalExtraParams = extraTotalParams
        }
    }
    
    typealias ServiceTarget = ServiceType
    typealias ModelType = T
    
    ///需要子类来实现
    var service: ServiceTarget?
    
    var provider: Moya.MoyaProvider<ServiceTarget>?
    
    var page: Int = 1
    
    var count: Int = 10
    
    var hasMoreData: Bool = true
    
    
    var dataList: [ModelType]

    
    required override init() {
        self.dataList = [ModelType]()
        self.provider = Moya.MoyaProvider<ServiceTarget>()
    }
    
}
