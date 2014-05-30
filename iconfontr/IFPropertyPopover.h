//
//  NSPropertyViewController.h
//  iconfontr
//
//  Created by Chase Zhang on 5/26/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IFColorPanelController, IFSizePanelController, IFResolutionsPanelController, IFInfoPanelController;

@interface IFPropertyPopover : NSObject

@property (nonatomic) IBOutlet IFColorPanelController *colorPanelController;
@property (nonatomic) IBOutlet IFSizePanelController *sizePanelController;
@property (nonatomic) IBOutlet IFResolutionsPanelController *resolutionsPanelController;
@property (nonatomic) IBOutlet IFInfoPanelController *infoPanelController;

+ (instancetype)popover;
+ (void)popWithIdentifier:(NSString *)identifier view:(NSView *)view;
- (void)showPopoverWithIdentifier:(NSString *)identifier ofView:(NSView *)view;

@end
