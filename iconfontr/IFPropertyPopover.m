//
//  NSPropertyViewController.m
//  iconfontr
//
//  Created by Chase Zhang on 5/26/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFPropertyPopover.h"

static IFPropertyPopover *shared;

@interface IFPropertyPopover () <NSPopoverDelegate>
{
  NSArray *_viewArray;
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

- (void)loadView
{
  if (_viewArray==nil) {
    NSArray *array;
    [[NSBundle mainBundle] loadNibNamed:@"IFPropertyView"
                                  owner:self
                        topLevelObjects:&array];
    _viewArray = array;
  }
}

- (NSView *)viewWithIdentifier:(NSString *)identifier
{
  [self loadView];
  for (NSView *view in _viewArray) {
    if ([view isKindOfClass:[NSView class]] && [[view identifier] isEqualToString:identifier])
      return view;
  }
  return nil;
}

- (NSViewController *)viewControllerWithIdentifier:(NSString *)identifier
{
  NSViewController *controller = [[NSViewController alloc] init];
  controller.view = [self viewWithIdentifier:identifier];
  return controller;
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
