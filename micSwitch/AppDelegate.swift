//
//  AppDelegate.swift
//  micSwitch
//
//  Created by dstd on 13/11/2017.
//  Copyright © 2017 Denis Stanishevskiy. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let statusButton = statusItem.button {
            statusButton.target = self
            statusButton.action = #selector(statusItemClicked(_:))
        }
        
        muteListenerId = Audio.addMicMuteListener { [weak self] in
            self?.updateMicStatus()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        Audio.removeMicMuteListener(listenerId: muteListenerId)
    }

  @IBOutlet weak var window: NSWindow!

    private func updateMicStatus() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(named: NSImage.Name(Audio.micMuted ? "micOff" : "micOn"))
    }
    
    @objc func statusItemClicked(_ sender: Any?) {
        Audio.toggleMicMute()
        updateMicStatus()
    }

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var muteListenerId: Int = -1
}
