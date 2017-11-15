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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shortcutView.associatedUserDefaultsKey = Preferences.preferenceMuteShortcut
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window?.level = .floating
    }
    
    @IBAction func quit(_ sender: Any) {
        NSApp.terminate(self)
    }
}
