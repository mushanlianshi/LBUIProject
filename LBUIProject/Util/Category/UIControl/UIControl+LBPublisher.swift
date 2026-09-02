//
//  UIControl+LBPublisher.swift
//
//
//  Created by liubin
//

import Combine
import UIKit

/// 给UIControl 添加Combine publisher
extension UIControl{
    public func publisher(for events: UIControl.Event) -> UIControlPublisher<UIControl>{
        return UIControlPublisher(control: self, events: events)
    }
}

/// 给UITextField添加Publishers
extension UITextField{
    public func publisherForTextChanged() -> AnyPublisher<String?, Never> {
        return UIControlPublisher(control: self, events: .editingChanged).map({ $0.text }).eraseToAnyPublisher()
    }
}

/// 给UISwitch添加Publishers
extension UISwitch{
    public func publisher() -> AnyPublisher<Bool, Never> {
        return UIControlPublisher(control: self, events: .valueChanged).map({ $0.isOn }).eraseToAnyPublisher()
    }
}

/// 给UISwitch添加Publishers
extension UISlider{
    public func publisher() -> AnyPublisher<Float, Never> {
        return UIControlPublisher(control: self, events: .valueChanged).map({ $0.value }).eraseToAnyPublisher()
    }
}

extension UIRefreshControl {
    public func refreshControlPublisher() -> AnyPublisher<Bool, Never>{
        return UIControlPublisher(control: self, events: .valueChanged).map({ $0.isRefreshing }).eraseToAnyPublisher()
    }
}

final class UIControlSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription where SubscriberType.Input == Control {
    private var subscriber: SubscriberType?
    private let control: Control
    /// 记录订阅的事件：cancel 时据此移除 target-action
    private let event: UIControl.Event

    init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        self.event = event
        control.addTarget(self, action: #selector(eventHandler), for: event)
    }

    func request(_ demand: Subscribers.Demand) {
        
    }

    func cancel() {
        /// addTarget 对 target 是非持有引用，必须显式移除；
        /// 否则 control 比 subscription 长寿时（复用 cell、单例 view 等），
        /// 事件触发会调到已释放的 subscription → 野指针崩溃
        control.removeTarget(self, action: #selector(eventHandler), for: event)
        subscriber = nil
    }

    @objc private func eventHandler() {
        _ = subscriber?.receive(control)
    }
}

public struct UIControlPublisher<Control: UIControl>: Publisher {

    public typealias Output = Control
    public typealias Failure = Never

    let control: Control
    let controlEvents: UIControl.Event

    init(control: Control, events: UIControl.Event) {
        self.control = control
        self.controlEvents = events
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber,
                                                S.Failure == UIControlPublisher.Failure,
                                                S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
        subscriber.receive(subscription: subscription)
    }
}
