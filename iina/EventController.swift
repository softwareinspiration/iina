//
//  EventController.swift
//  iina
//
//  Created by Collider LI on 17/9/2018.
//  Copyright © 2018 lhc. All rights reserved.
//

import Foundation

protocol EventCallable {
  func call(withArguments args: [Any])
}

class EventController {

  struct Name: RawRepresentable, Hashable {
    typealias RawValue = String
    var rawValue: String

    var hashValue: Int {
      return rawValue.hashValue
    }

    init(_ string: String) { self.rawValue = string }
    init?(rawValue: RawValue) { self.rawValue = rawValue }

    // IINA events
    static let windowLoaded = Name("iina.window-loaded")
    static let windowMoved = Name("iina.window-moved")
    static let windowResized = Name("iina.window-resized")
    static let pipChanged = Name("iina.pip.changed")
  }

  var listeners: [Name: [String: EventCallable]] = [:]

  func hasListener(for name: Name) -> Bool {
    return listeners[name] != nil
  }

  func addListener(_ listener: EventCallable, for name: Name) -> String {
    let uuid = UUID().uuidString
    listeners[name, default: [:]][uuid] = listener
    return uuid
  }

  func removeListener(_ id: String, for name: Name) -> Bool {
    if listeners[name] == nil { return false }
    if listeners[name]![id] == nil { return false }
    listeners[name]![id] = nil
    return true
  }

  func removeAllListener(for name: Name) {
    listeners[name]?.removeAll()
  }

  func emit(_ eventName: Name, data: Any...) {
    guard let listeners = listeners[eventName] else { return }
    for listener in listeners.values {
      listener.call(withArguments: data)
    }
  }
}
