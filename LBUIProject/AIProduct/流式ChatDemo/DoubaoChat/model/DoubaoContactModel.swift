//
//  DoubaoContactModel.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import Foundation

/// 找人卡片 model（正文流式中途穿插插入的结构性卡片）
/// 插入后内容不变，只有结构 insert（snapshot diff 自动处理，无 reconfigure 需求）
struct DoubaoContactModel: Identifiable, Hashable {

    let id = UUID()
    /// 姓名
    let name: String
    /// 头衔（如「机器学习专家 · 前 Alibaba」）
    let title: String
    /// 一句话介绍
    let intro: String
    /// 擅长标签
    let tags: [String]
    /// 头像底色（按 name 稳定取色，保证每次渲染一致）
    var avatarColorHex: Int {
        var hash = 5381
        for scalar in name.unicodeScalars {
            hash = (hash << 5) &+ Int(scalar.value)
        }
        let palette: [Int] = [0x0E8AFD, 0x7C5CFC, 0x00B8A9, 0xFD890E, 0xE85D75]
        return palette[abs(hash) % palette.count]
    }

    static func == (lhs: DoubaoContactModel, rhs: DoubaoContactModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
