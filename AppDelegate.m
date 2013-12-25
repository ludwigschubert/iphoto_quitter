//
//  IPMenuletExampleAppDelegate.m
//  IPMenuletExample
//
//  Created by Stan on 11/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "LSDiskArbitration.h"
#import "LSiPhotoDatabase.h"

static NSString *iPhotoBundleIdentifier = @"com.apple.iPhoto";

@implementation AppDelegate
@synthesize toggleStartAtLogin;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver:self
     selector:@selector(switchHandler:)
     name:NSWorkspaceSessionDidBecomeActiveNotification
     object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver:self
     selector:@selector(switchHandler:)
     name:NSWorkspaceSessionDidResignActiveNotification
     object:nil];
    
    NSLog(@"Succesfully registered for NSWorkspaceSession Notifications.");
}


- (void) switchHandler:(NSNotification*) notification
{
    if ([[notification name] isEqualToString: NSWorkspaceSessionDidResignActiveNotification])
    {
        NSLog(@"Quitting iPhoto. (received NSWorkspaceSessionDidResignActiveNotification)");
        [self quitIPhoto];
        [self unmountiPhotoDatabase];
    }
    else
    {
        NSLog(@"Became active. Waiting 10 seconds to allow disk image to eject… (received NSWorkspaceSessionDidBecomeActiveNotification)");
        double delayInSeconds = 10.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"10s are over. Now mounting iPhoto Database Disk Image.");
            [self mountiPhotoDatabase];
            //        [self startIPhoto];
        });

    }
}

# pragma mark - Private Methods

- (void)quitIPhoto
{
    NSArray *iPhotoInstances = [NSRunningApplication runningApplicationsWithBundleIdentifier:iPhotoBundleIdentifier];
    
    for (NSRunningApplication *instance in iPhotoInstances) {
        [instance terminate];
    }
}

- (void)startIPhoto
{
    [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:iPhotoBundleIdentifier
                                                         options:NSWorkspaceLaunchAndHide
                                  additionalEventParamDescriptor:nil
                                                launchIdentifier:NULL];
}

- (void)unmountiPhotoDatabase
{
    NSURL *iPhotoDatabase = [LSiPhotoDatabase mostRecentDatabaseURL];
    NSURL *volumeURL = [LSDiskArbitration volumeURLforFileURL:iPhotoDatabase];
    [LSDiskArbitration unmountVolume:volumeURL];
}

- (void)mountiPhotoDatabase
{
    NSURL *volumeURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"iPhotoDatabaseDiskImagePath"];
    if (volumeURL) {
        [LSDiskArbitration mountVolume:volumeURL];
    } else {
        NSLog(@"No iPhoto database Disk Image path set; not mounting anything.");
    }
    
}

# pragma mark - IBActions

- (IBAction)quit:(id)sender
{
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

// Not currently used
- (IBAction)toggleStartAtLogin:(id)sender
{
    if (self.toggleStartAtLogin.state == NSOnState)
    {
        self.toggleStartAtLogin.state = NSOffState;
    } else {
        self.toggleStartAtLogin.state = NSOnState;
    }
}

# pragma mark Debug

- (IBAction)debug_mountDiskImage:(id)sender
{
    [self mountiPhotoDatabase];
}

- (IBAction)debug_unmountDiskImage:(id)sender
{
    [self unmountiPhotoDatabase];
}

- (IBAction)debug_quitIPhoto:(id)sender
{
    [self quitIPhoto];
}

- (IBAction)debug_startIPhoto:(id)sender
{
    [self startIPhoto];
}

@end
