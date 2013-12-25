//
//  LSiPhotoDatabase.m
//  iPhotoQuitter
//
//  Created by Ludwig Schubert on 25/12/13.
//
//

#import "LSiPhotoDatabase.h"

@implementation LSiPhotoDatabase

+ (NSURL*)mostRecentDatabaseURL
{
    NSArray *libraryDatabases = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.iApps"] objectForKey:@"iPhotoRecentDatabases"];
    if (libraryDatabases.count > 0) {
        NSString *iPhotoDatabasePath = [libraryDatabases firstObject];
        return [NSURL URLWithString:iPhotoDatabasePath];
    } else {
        NSLog(@"Couldn't find iPhoto Database, so can't unmount enclosing volume.");
    }
    return nil;
}

@end
