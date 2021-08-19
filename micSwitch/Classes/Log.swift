//
//  Log.swift
//  micSwitch
//
//  Created by Denis Stanishevskiy on 19.08.2021.
//  Copyright © 2021 Denis Stanishevskiy. All rights reserved.
//

import Foundation

enum Log {
    static func print(_ closure: () -> String) {
#if DEBUG
        Swift.print(closure())
#endif
    }
}
