//
//  UIControl+LBPublisher.swift
//
//
//  Created by liubin
//

import Combine
import UIKit

/// 给UIControl 添加Combine publisher
extension BLTNameSpace where Base: UIControl{
    public func publisher(for events: UIControl.Event) -> UIControlPublisher<UIControl>{
        return UIControlPublisher(control: self.base, events: events)
    }
}

/// 给UITextField添加Publishers
extension BLTNameSpace where Base: UITextField{
    @available(iOS 13.0, *)
    public func publisherForTextChanged() -> AnyPublisher<String?, Never> {
        return UIControlPublisher(control: self.base, events: .editingChanged).map({ $0.text }).eraseToAnyPublisher()
    }
}

/// 给UISwitch添加Publishers
extension BLTNameSpace where Base: UISwitch{
    @available(iOS 13.0, *)
    public func publisher() -> AnyPublisher<Bool, Never> {
        return UIControlPublisher(control: self.base, events: .valueChanged).map({ $0.isOn }).eraseToAnyPublisher()
    }
}

/// 给UISwitch添加Publishers
extension BLTNameSpace where Base: UISlider{
    @available(iOS 13.0, *)
    public func publisher() -> AnyPublisher<Float, Never> {
        return UIControlPublisher(control: self.base, events: .valueChanged).map({ $0.value }).eraseToAnyPublisher()
    }
}

extension BLTNameSpace where Base: UIRefreshControl {
    @available(iOS 13.0, *)
    public func refreshControlPublisher() -> AnyPublisher<Bool, Never>{
        return UIControlPublisher(control: self.base, events: .valueChanged).map({ $0.isRefreshing }).eraseToAnyPublisher()
    }
}

// 一个订阅描述， 订阅者告诉发布者，他需要订阅的信息
@available(iOS 13.0, *)
final class UIControlSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription where SubscriberType.Input == Control {
    private var subscriber: SubscriberType?
    private let control: Control

    // subscriber是订阅者， control是被订阅的对象， event是被订阅对象里被订阅的事件
    init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(eventHandler), for: event)
    }

    func request(_ demand: Subscribers.Demand) {
        
    }

    func cancel() {
        subscriber = nil
    }

    // 当点击事件发生时，调用订阅者订阅的方法，告诉订阅者
    @objc private func eventHandler() {
        _ = subscriber?.receive(control)
    }
}


// 一个发布者， 根据要订阅的控件类型，和事件来创建一个发布者。当这个类型有这个事件发生的时候， 发出消息
public struct UIControlPublisher<Control: UIControl>: Publisher {

    // 输出的类型是UIControl类型
    public typealias Output = Control
    // 错误类型为Never，不可能出现错误
    public typealias Failure = Never

    let control: Control
    let controlEvents: UIControl.Event

    init(control: Control, events: UIControl.Event) {
        self.control = control
        self.controlEvents = events
    }
    
    // 实现发布者协议的receive的方法，在里面让发布者和订阅者绑定起来
    @available(iOS 13.0, *)
    public func receive<S>(subscriber: S) where S: Subscriber,
                                                S.Failure == UIControlPublisher.Failure,
                                                S.Input == UIControlPublisher.Output {
        // 创建一个订阅描述， 让订阅者来订阅的。 创建一个subscriber为订阅者， 订阅control的controlEvents事件的描述，当有这个事件的时候，发布消息，订阅者就能收到了
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
        // 订阅者订阅这个描述信息，等有发布的时候就能收到了 Subscriber.receive(subscription:) 是建立发布者和订阅者之间正式连接的桥梁，也是让订阅者掌握主动权的开始。
        subscriber.receive(subscription: subscription)
    }
}
