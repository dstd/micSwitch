//
//  PreferencesViewController.swift
//  micSwitch
//
//  Created by dstd on 15/11/2017.
//  Copyright © 2017 Denis Stanishevskiy. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    static func newInstance() -> PreferencesViewController {
        return PreferencesViewController(nibName: NSNib.Name(rawValue: "Preferences"), bundle: nil)
    }
    
    @IBOutlet var inputDeviceName: NSTextField!
    @IBOutlet var shortcutView: MASShortcutView!
    @IBOutlet var walkieTalkieMode: NSButton!
    @IBOutlet var launchAtLogin: NSButton!

    private var muteListenerId: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        shortcutView.associatedUserDefaultsKey = Preferences.preferenceMuteShortcut
        walkieTalkieMode.state = Preferences.walkieTalkieMode ? .on : .off
        launchAtLogin.state = Preferences.launchAtLogin ? .on : .off
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        muteListenerId = Audio.shared.addDeviceStateListener { [weak self] in
            self?.inputDeviceName.stringValue = Audio.shared.inputDeviceName ?? "—"
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        Audio.shared.removeDeviceStateListener(listenerId: muteListenerId)
    }

    @IBAction func walkieTalkieModeChanged(_ sender: Any) {
        Preferences.walkieTalkieMode = walkieTalkieMode.state == .on
    }
    
    @IBAction func launchAtLoginChanged(_ sender: Any) {
        Preferences.launchAtLogin = launchAtLogin.state == .on
    }
    @IBAction func quit(_ sender: Any) {
        NSApp.terminate(self)
    }
}
