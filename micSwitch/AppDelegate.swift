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
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var mutedStateItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let statusButton = statusItem.button {
            statusButton.target = self
            statusButton.action = #selector(statusItemClicked(_:))
            statusButton.sendAction(on: [NSEvent.EventTypeMask.leftMouseUp, NSEvent.EventTypeMask.rightMouseUp])
        }
        
        muteListenerId = Audio.addMicMuteListener { [weak self] in
            self?.updateMicStatus()
        }
        
        MASShortcutBinder.shared().bindShortcut(withDefaultsKey: Preferences.preferenceMuteShortcut) {
            Audio.toggleMicMute()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        Audio.removeMicMuteListener(listenerId: muteListenerId)
    }

    @IBAction func showPreferences(_ sender: Any) {
        let preferences = PreferencesViewController.newInstance()
        
        let popOver = NSPopover()
        popOver.appearance = NSAppearance(named: .aqua)
        popOver.contentViewController = preferences
        popOver.behavior = .transient
        popOver.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .minY)

        NSApp.activate(ignoringOtherApps: true)
    }

    private func updateMicStatus() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(named: NSImage.Name(Audio.micMuted ? "micOff" : "micOn"))
    }
    
    @objc func statusItemClicked(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }
        switch event.type {
        case NSEvent.EventType.rightMouseUp:
            showPreferences(self)
        default:
            Audio.toggleMicMute()
        }
    }
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var muteListenerId: Int = -1
}
