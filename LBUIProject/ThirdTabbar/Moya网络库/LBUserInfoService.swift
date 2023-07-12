//
//  LBUserInfoService.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/23.
//

import Foundation
import Moya


///获取用户信息的service  包括登录 登出 根据token userid获取用户信息
enum LBUserInfoService{
    case login(mobile: String, code: String)
    case userInfo
    case logout
}


extension LBUserInfoService: LBMoyaTargetTypeProtocol{
    var requestTotalExtraParams: [String : Any]? {
        get {
            switch self {
            case .logout:
                return nil
            case .userInfo:
                return ["token" : "2370230230923"]
            case .login(let mobile, let code):
                return ["token" : mobile, "code" : code]
            }
        }
        set {
            
        }
    }
    
    
    
    var path: String {
        switch self {
        case .logout:
            return "/mock/21/userInfo"
        default:
            return "/mock/21/userInfo_1684830843715"
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .logout:
            return bltTask()
        case .userInfo:
            return bltTask()
        case .login(let mobile, let code):
            return bltTask(params: ["mobile" : mobile, "code" : code])
        }
    }
    
    
}
