//
//  LSDiskArbitration.m
//  iPhotoQuitter
//
//  Created by Ludwig Schubert on 25/12/13.
//
//

#import "LSDiskArbitration.h"

@implementation LSDiskArbitration

void unmount_disk_done(DADiskRef disk, DADissenterRef dissenter, void *context);
void mount_disk_done(DADiskRef disk, DADissenterRef dissenter, void *context);

# pragma mark - Public Methods

+ (NSURL*)volumeURLforFileURL:(NSURL*)fileURL
{
    if ([fileURL.absoluteString hasPrefix:@"file:///Volumes/"]) {
        NSRange range = {0,3};
        NSURL *volumeURL = [NSURL fileURLWithPathComponents:[fileURL.pathComponents subarrayWithRange:range]];
        return volumeURL;
    } else {
        NSLog(@"File is not stored on a Volume. (Path: %@)", fileURL.absoluteString);
        return nil;
    }
}

+ (void)mountVolume:(NSURL*)volumeURL
{
    NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/hdiutil" arguments:@[@"attach", volumeURL.absoluteString]];
    [task waitUntilExit];
    if (task.terminationStatus == 0) {
        NSLog(@"Mounting succeeded.");
    } else {
        NSLog(@"Mounting failed.");
    }
}

+ (void)unmountVolume:(NSURL*)volumeURL
{
    CFAllocatorRef allocator = CFAllocatorGetDefault();
    DASessionRef session = DASessionCreate(allocator);
    DASessionScheduleWithRunLoop(session, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    DADiskRef disk = DADiskCreateFromVolumePath(allocator, session, (__bridge CFURLRef)(volumeURL));
    if (disk) {
        DADiskRef wholedisk = DADiskCopyWholeDisk(disk);
        if (wholedisk) {
            NSLog(@"Unmounting %s…", DADiskGetBSDName(wholedisk));
            DADiskUnmount(wholedisk, kDADiskUnmountOptionWhole, unmount_disk_done, NULL);
        } else {
            NSLog(@"Couldn't get whole disk for volume %s", DADiskGetBSDName(disk));
        }
    } else {
        NSLog(@"Volume URL didn't point to a valid Volume, or the colume wasn't mounted. (URL: %@)", [volumeURL absoluteString]);
    }
}

# pragma mark - Mount and unmount Callbacks

void unmount_disk_done(DADiskRef disk, DADissenterRef dissenter, void *context)
{
    if (disk) {
        const char * name = DADiskGetBSDName(disk);
        CFDictionaryRef diskinfo = DADiskCopyDescription(disk);
        CFURLRef fspath = CFDictionaryGetValue(diskinfo, kDADiskDescriptionVolumePathKey);
        if (dissenter) { /* Unmount failed. */
            char buf[MAXPATHLEN];
            if (CFURLGetFileSystemRepresentation(fspath, false, (UInt8 *)buf, sizeof(buf))) {
                fprintf(stderr, "Unmount failed (Error: 0x%x Reason: %s).  Retrying.\n", DADissenterGetStatus(dissenter), buf);
            } else {
                NSLog(@"Couldn't get Filesystem Representation of disk %s.", name);
            }
        } else {
            NSLog(@"Unmounted %s succesfully.", name);
        }
    } else {
        NSLog(@"Disk unmounting callback called with nil disk...?!");
    }
}

@end
