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

@available(iOS 13.0, *)
final class UIControlSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription where SubscriberType.Input == Control {
    private var subscriber: SubscriberType?
    private let control: Control

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
    
    @available(iOS 13.0, *)
    public func receive<S>(subscriber: S) where S: Subscriber,
                                                S.Failure == UIControlPublisher.Failure,
                                                S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
        subscriber.receive(subscription: subscription)
    }
}
