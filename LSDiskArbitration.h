//
//  LSDiskArbitration.h
//  iPhotoQuitter
//
//  Created by Ludwig Schubert on 25/12/13.
//
//

#import <Foundation/Foundation.h>
#import <DiskArbitration/DiskArbitration.h>

@interface LSDiskArbitration : NSObject

+ (void)mountVolume:(NSURL*)volumeURL;
+ (void)unmountVolume:(NSURL*)volumeURL;
+ (NSURL*)volumeURLforFileURL:(NSURL*)fileURL;

@end
