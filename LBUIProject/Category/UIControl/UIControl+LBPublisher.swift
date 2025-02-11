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
    
    public func receive<S>(subscriber: S) where S: Subscriber,
                                                S.Failure == UIControlPublisher.Failure,
                                                S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
        subscriber.receive(subscription: subscription)
    }
}
