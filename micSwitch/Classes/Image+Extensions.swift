//
//  Image+Extensions.swift
//  micSwitch
//
//  Created by Denis Stanishevskiy on 20.08.2021.
//

import Foundation

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        guard let image = self.copy() as? NSImage else { return self }
        image.lockFocus()

        color.set()
        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()
        image.isTemplate = false

        return image
    }
}

