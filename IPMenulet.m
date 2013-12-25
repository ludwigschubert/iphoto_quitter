//
//  IPMenulet.m
//  IPMenuletExample
//
//  Created by Stan on 11/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "IPMenulet.h"

@interface IPMenulet ()

@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) NSImage *menuIcon;
@property (weak) IBOutlet NSMenuItem *diskImageItem;

@end


@implementation IPMenulet

- (void)awakeFromNib
{
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:30.0];
	[self.statusItem setHighlightMode:YES];
	[self.statusItem setEnabled:YES];
	[self.statusItem setToolTip:@"Automatically quits iPhoto when switching Users"];
    [self.statusItem setMenu:self.statusMenu];

		
	// Title as Image
	self.menuIcon = [NSImage imageNamed:@"MenuIconTemplate"];
    [self.menuIcon setSize:NSSizeFromCGSize(CGSizeMake(22.0, 22.0))];
//    [self.menuIcon setTemplate:YES];
	[self.statusItem setImage:self.menuIcon];
    
    [self refreshUI];
}

- (void)refreshUI
{
    NSURL *diskImageURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"iPhotoDatabaseDiskImagePath"];
    if (diskImageURL) {
        NSString *diskImageFile = [diskImageURL.pathComponents lastObject];
        self.diskImageItem.title = diskImageFile;
    } else {
        self.diskImageItem.title = @"Select iPhoto Disk Image…";
    }
}

- (IBAction)selectDiskImageWasClicked:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel new];
    [openPanel setAllowedFileTypes:@[@"dmg", @"sparsebundle", @"DiskImage"]];
    [openPanel setMessage:@"Choose the disk image that contains your iPhoto library…"];
    
    if ([openPanel runModal] == NSOKButton) {
        NSURL *diskImageURL = [openPanel URL];
        [[NSUserDefaults standardUserDefaults] setURL:diskImageURL forKey:@"iPhotoDatabaseDiskImagePath"];
    }
    [self refreshUI];
}


@end
