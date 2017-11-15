//
//  AppDelegate.swift
//  Launcher
//
//  Created by dstd on 15/11/2017.
//  Copyright © 2017 Denis Stanishevskiy. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("#YOYO")
        let mainApp = Bundle.main.bundlePath
            .deletingLastPathComponent // Launcher
            .deletingLastPathComponent // LoginItems
            .deletingLastPathComponent // Library
            .deletingLastPathComponent // Contents
        
        NSWorkspace.shared.launchApplication(mainApp)
        
        // Important: If your daemon shuts down too quickly after being launched, launchd may think it has crashed. Daemons that continue this behavior may be suspended and not launched again when future requests arrive. To avoid this behavior, do not shut down for at least 10 seconds after launch.
        // https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html#//apple_ref/doc/uid/10000172i-SW7-108425
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            NSApp.terminate(self)
        }
    }

}

extension String {
    var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
}
