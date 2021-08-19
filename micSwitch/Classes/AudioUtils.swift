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

class Audio {
    static let shared = Audio()

    var inputDevice: AudioDeviceID?

    var micMuted: Bool {
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
    
    func toggleMicMute() {
        micMuted = !micMuted
    }

    func addMicMuteListener(listener: @escaping () -> ()) -> Int {
        guard let inputDevice = inputDevice else { return -1 }
        
        let block: AudioObjectPropertyListenerBlock = { (addressesCount, addresses) in
            Log.print { "#mic mute state changed" }
            listener()
        }
        
        let listenerId = nextListenerId
        nextListenerId += 1
        listeners[listenerId] = block
        
        AudioObjectAddPropertyListenerBlock(inputDevice, &AudioObjectAddress.muteState, DispatchQueue.main, block)
        
        listener()
        
        return listenerId
    }
    
    func removeMicMuteListener(listenerId: Int) {
        guard let inputDevice = inputDevice,
            let block = listeners.removeValue(forKey: listenerId)
            else { return }
        
        AudioObjectRemovePropertyListenerBlock(inputDevice, &AudioObjectAddress.muteState, DispatchQueue.main, block)
    }

    private static func getInputDevice() -> AudioDeviceID? {
        var deviceId = kAudioObjectUnknown
        var deviceIdSize = UInt32(MemoryLayout.size(ofValue: deviceId))

        let error = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &AudioObjectAddress.inputDevice,
            0, nil,
            &deviceIdSize, &deviceId)

        return error == kAudioHardwareNoError && deviceId != kAudioObjectUnknown ? deviceId : nil
    }

    private func addDefaultMicListener() {
        let status = AudioObjectAddPropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &AudioObjectAddress.inputDevice, DispatchQueue.main, defaultMicListener)
        Log.print { "#mic added listener to \(inputDevice ?? 11111111) = \(status)" }
    }

    private func removeDefaultMicListener() {
        AudioObjectRemovePropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &AudioObjectAddress.inputDevice, DispatchQueue.main, defaultMicListener)
    }

    private func updateMicListeners() {
        let listeners = self.listeners

        if let inputDevice = self.inputDevice {
            listeners.forEach {
                AudioObjectRemovePropertyListenerBlock(inputDevice, &AudioObjectAddress.muteState, DispatchQueue.main, $0.value)
            }
            self.listeners = [:]
        }

        self.inputDevice = Self.getInputDevice()
        guard let inputDevice = self.inputDevice else { return Log.print { "#mic changed to nil" } }

        listeners.forEach {
            let status = AudioObjectAddPropertyListenerBlock(inputDevice, &AudioObjectAddress.muteState, DispatchQueue.main, $0.value)
            $0.value(1, &AudioObjectAddress.muteState)
            Log.print { "#mic changed to \(inputDevice) = \(status)" }
        }
        self.listeners = listeners
    }

    private lazy var defaultMicListener: AudioObjectPropertyListenerBlock = { (addressesCount, addresses) in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.updateMicListeners() }
    }

    private var listeners = [Int: AudioObjectPropertyListenerBlock]()
    private var nextListenerId: Int = 0

    init() {
        self.inputDevice = Self.getInputDevice()
        addDefaultMicListener()
    }
}
