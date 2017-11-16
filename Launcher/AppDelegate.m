//
//  AppDelegate.m
//  Launcher
//
//  Created by dstd on 17/11/2017.
//  Copyright © 2017 Denis Stanishevskiy. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString* mainApp = NSBundle.mainBundle.bundlePath
                        .stringByDeletingLastPathComponent // Launcher
                        .stringByDeletingLastPathComponent // LoginItems
                        .stringByDeletingLastPathComponent // Library
                        .stringByDeletingLastPathComponent;// Contents
    [[NSWorkspace sharedWorkspace] launchApplication:mainApp];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSApp terminate:self];
    });
}

@end

