//
//  Preferences.swift
//  micSwitch
//
//  Created by dstd on 15/11/2017.
//  Copyright © 2017 Denis Stanishevskiy. All rights reserved.
//

import Foundation
import ServiceManagement

class Preferences {
    static var walkieTalkieMode: Bool {
        get { return UserDefaults.standard.bool(forKey: Preferences.preferenceWalkieTalkieMode) }
        set { UserDefaults.standard.set(newValue, forKey: Preferences.preferenceWalkieTalkieMode) }
    }
    
    static var launchAtLogin: Bool {
        get {
            guard let jobs = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]])
                else { return false }
            
            let job = jobs.first { $0["Label"] as? String == Preferences.laucherBundleId }
            return job?["OnDemand"] as? Bool ?? false
        }
        set {
            if !SMLoginItemSetEnabled(Preferences.laucherBundleId as CFString, newValue) {
                print("failed to enable launch agent")
            }
        }
    }
    
    static let preferenceMuteShortcut = "muteShortcut"
    static let preferenceWalkieTalkieMode = "walkieTalkieMode"
    static let laucherBundleId = "dstd.github.com.micSwitch.Launcher"
}
