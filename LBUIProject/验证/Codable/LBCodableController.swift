//
//  LBCodableController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/3/6.
//

import Foundation


struct School: Codable {
    var name = ""
    var location: String?
    
    /// 使用CodingKeys来忽略location解析,  CodingKeys不声明的不会解析
//    enum CodingKeys: String, CodingKey {
//        case name
//    }
}


struct Student: Codable{
    var name:String?
    var age:Int?
    /// 使用CodingKeys来忽略homeAddress解析,  CodingKeys不声明的不会解析， 使用nickName 来解析name
    var homeAddress: String?
    var school: School
//    enum CodingKeys:String,CodingKey{
//        case age
//        case name = "nickName"
//        case school
//    }
}



class LBCodableController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dic: [String : Any] = ["age":10, "nickName" : "liubin", "homeAddress" : "利辛县孙集镇", "school": [
            "name" : "利辛中学", "location" : "利辛县人名中路"
        ]]
         let data = try! JSONSerialization.data(withJSONObject: dic)
         let jsonDecoder = JSONDecoder()
         let item = try! jsonDecoder.decode(Student.self, from: data)
        print("LBLOg item name \(item.name)")
        print("LBLOg item homeAddress \(item.homeAddress)")
        print("LBLOg item school \(item.school)")
        print("LBLOg item school.name \(item.school.name)")
        print("LBLOg item school.location \(item.school.location)")
    }
}
