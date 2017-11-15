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
    
    @IBOutlet weak var shortcutView: MASShortcutView!
    @IBOutlet weak var walkieTalkieMode: NSButton!
    @IBOutlet weak var launchAtLogin: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shortcutView.associatedUserDefaultsKey = Preferences.preferenceMuteShortcut
        walkieTalkieMode.state = Preferences.walkieTalkieMode ? .on : .off
        launchAtLogin.state = Preferences.launchAtLogin ? .on : .off
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
