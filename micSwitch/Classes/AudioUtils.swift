//
//  MicUtils.swift
//  micSwitch
//
//  Created by dstd on 13/11/2017.
//  Copyright © 2017 Denis Stanishevskiy. All rights reserved.
//

import Foundation
import AudioToolbox

struct AudioObjectAddress {
    static var inputDevice = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultInputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMaster)
    
    static var muteState = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyMute,
        mScope: kAudioDevicePropertyScopeInput,
        mElement: kAudioObjectPropertyElementMaster)
}

struct Audio {
    static var inputDevice: AudioDeviceID? {
        var deviceId = kAudioObjectUnknown
        var deviceIdSize = UInt32(MemoryLayout.size(ofValue: deviceId))
        
        let error = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &AudioObjectAddress.inputDevice,
            0, nil,
            &deviceIdSize, &deviceId)
        
        return error == kAudioHardwareNoError && deviceId != kAudioObjectUnknown ? deviceId : nil
    }

    static var micMuted: Bool {
        get {
            guard let inputDevice = inputDevice else { return true }
            
            var muteState: UInt32 = 0
            var muteStateSize = UInt32(MemoryLayout.size(ofValue: muteState))
            
            let error = AudioObjectGetPropertyData(
                inputDevice, &AudioObjectAddress.muteState,
                0, nil,
                &muteStateSize, &muteState)
            
            return error == kAudioHardwareNoError ? muteState == 1 : true
        }
        
        set {
            guard let inputDevice = inputDevice else { return }

            var muteState: UInt32 = newValue ? 1 : 0
            let muteStateSize = UInt32(MemoryLayout.size(ofValue: muteState))
            
            AudioObjectSetPropertyData(
                inputDevice, &AudioObjectAddress.muteState,
                0, nil,
                muteStateSize, &muteState)
        }
    }
    
    static func toggleMicMute() {
        micMuted = !micMuted
    }
    
    static func addMicMuteListener(listener: @escaping () -> ()) -> Int {
        guard let inputDevice = inputDevice else { return -1 }
        
        let block: AudioObjectPropertyListenerBlock = { (addressesCount, addresses) in
            listener()
        }
        
        let listenerId = nextListenerId
        nextListenerId += 1
        listeners[listenerId] = block
        
        AudioObjectAddPropertyListenerBlock(inputDevice, &AudioObjectAddress.muteState, DispatchQueue.main, block)
        
        listener()
        
        return listenerId
    }
    
    static func removeMicMuteListener(listenerId: Int) {
        guard let inputDevice = inputDevice,
            let block = listeners.removeValue(forKey: listenerId)
            else { return }
        
        AudioObjectRemovePropertyListenerBlock(inputDevice, &AudioObjectAddress.muteState, DispatchQueue.main, block)
    }
    
    private static var listeners = [Int: AudioObjectPropertyListenerBlock]()
    private static var nextListenerId: Int = 0
}

