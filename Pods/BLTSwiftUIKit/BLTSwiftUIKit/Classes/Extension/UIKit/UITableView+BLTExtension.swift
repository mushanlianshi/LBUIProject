//
//  UITableView+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/12/5.
//

import Foundation

extension BLTNameSpace where Base: UITableView{
    
    public static func initTableView(_ style: UITableView.Style = .plain) -> UITableView{
        let tableView = UITableView.init(frame: .zero, style: style)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        return tableView
    }
    
    public func registerReusableCell222<T: UITableViewCell>() -> T{
        base.register(T.self, forCellReuseIdentifier: T.blt_className)
        return T()
    }
    
    public func registerReusableCell<T: UITableViewCell>(cell: T.Type){
        base.register(T.self, forCellReuseIdentifier: T.blt_className)
    }
    
    public func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T{
        guard let cell = base.dequeueReusableCell(withIdentifier: T.blt_className, for: indexPath) as? T else {
            fatalError(.dequeueCellFailedMsg)
        }
        return cell
    }
    
    public func registerReusableHeaderFooter<T: UITableViewHeaderFooterView>(header: T.Type){
        base.register(T.self, forHeaderFooterViewReuseIdentifier: T.blt_className)
    }
    
    public func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>() -> T{
        guard let view = base.dequeueReusableHeaderFooterView(withIdentifier: T.blt_className)  as? T else {
            fatalError(.dequeueHeaderFooterFailedMsg)
        }
        return view
    }
    
}


extension String{
    static let dequeueCellFailedMsg = "LBLog dequeue cell failed, please sure register cell first"
    static let dequeueHeaderFooterFailedMsg = "LBLog dequeue header/footer failed, please sure register header/footer first"
}
