//
//  NSPropertyViewController.h
//  iconfontr
//
//  Created by Chase Zhang on 5/26/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFPropertyPopover : NSObject

+ (instancetype)popover;
+ (void)popWithIdentifier:(NSString *)identifier view:(NSView *)view;
- (void)showPopoverWithIdentifier:(NSString *)identifier ofView:(NSView *)view;

@end
