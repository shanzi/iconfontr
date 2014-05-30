//
//  NSPropertyViewController.m
//  iconfontr
//
//  Created by Chase Zhang on 5/26/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFPropertyPopover.h"

#import "IFColorPanelController.h"
#import "IFSizePanelController.h"
#import "IFResolutionsPanelController.h"
#import "IFInfoPanelController.h"

static IFPropertyPopover *shared;

@interface IFPropertyPopover () <NSPopoverDelegate>
{
  NSArray *_controllersArray;
  NSMutableDictionary *_popovers;
}

@end

@implementation IFPropertyPopover

+ (instancetype)popover
{
  if (shared==nil) {
    shared = [[IFPropertyPopover alloc] init];
  }
  return shared;
}

+ (void)popWithIdentifier:(NSString *)identifier view:(NSView *)view
{
  [[IFPropertyPopover popover] showPopoverWithIdentifier:identifier ofView:view];
}

- (void)loadNib
{
  if (_colorPanelController && _sizePanelController && _resolutionsPanelController && _infoPanelController) {
    return;
  }
  
  [[NSBundle mainBundle] loadNibNamed:@"IFPropertyView" owner:self topLevelObjects:nil];
}

- (NSViewController *)viewControllerWithIdentifier:(NSString *)identifier
{
  [self loadNib];
  if ([identifier isEqualToString:@"color"]) return _colorPanelController;
  else if ([identifier isEqualToString:@"size"]) return _sizePanelController;
  else if ([identifier isEqualToString:@"resolutions"]) return _resolutionsPanelController;
  else if ([identifier isEqualToString:@"info"]) return _infoPanelController;
  return nil;
}

- (NSPopover *)popoverWithIdentifier:(NSString *)identifier
{
  NSPopover *popover = [_popovers objectForKey:identifier];
  if (popover) return popover;
  popover = [[NSPopover alloc] init];
  popover.appearance = NSPopoverAppearanceMinimal;
  popover.behavior = NSPopoverBehaviorTransient;
  popover.contentViewController = [self viewControllerWithIdentifier:identifier];
  popover.delegate = self;
  [_popovers setObject:popover forKey:identifier];
  return popover;
}

- (void)showPopoverWithIdentifier:(NSString *)identifier ofView:(NSView *)view
{
  NSPopover *popover = [self popoverWithIdentifier:identifier];
  [popover showRelativeToRect:[view bounds] ofView:view preferredEdge:NSMaxYEdge];
}

@end
