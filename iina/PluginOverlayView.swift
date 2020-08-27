//
//  PluginOverlayView.swift
//  iina
//
//  Created by Collider LI on 21/1/2019.
//  Copyright © 2019 lhc. All rights reserved.
//

import Cocoa
import WebKit

class PluginOverlayView: WKWebView {
  override func hitTest(_ point: NSPoint) -> NSView? {
    return nil
  }

  func attachTo(windowController: MainWindowController) {
    windowController.pluginOverlayViewContainer.addSubview(self)
    Utility.quickConstraints(["H:|[v]|", "V:|[v]|"], ["v": self])
  }

  static func create(pluginInstance: JavascriptPluginInstance) -> PluginOverlayView {
    let config = WKWebViewConfiguration()
    config.userContentController.addUserScript(WKUserScript(source: """
      window.iina = {
        listeners: {},
        _emit(name, data) {
          const callback = this.listeners[name];
          if (typeof callback === "function") {
            callback.call(null, data);
          }
        },
        onMessage(name, callback) {
          this.listeners[name] = callback;
        },
        postMessage(name, data) {
          webkit.messageHandlers.iina.postMessage([name, data]);
        },
      };
    """, injectionTime: .atDocumentStart, forMainFrameOnly: true))

    config.userContentController.add(pluginInstance.apis!["overlay"] as! WKScriptMessageHandler, name: "iina")

    let webView = PluginOverlayView(frame: .zero, configuration: config)
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.setValue(false, forKey: "drawsBackground")
    webView.isHidden = true

    return webView
  }

}
