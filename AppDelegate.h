//
//  IPMenuletExampleAppDelegate.h
//  IPMenuletExample
//
//  Created by Stan on 11/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    __weak NSMenuItem *toggleStartAtLogin;
}

@property (weak) IBOutlet NSMenuItem *toggleStartAtLogin;

- (IBAction)quit:(id)sender;

@end
