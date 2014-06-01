//
//  IFSizePanelController.m
//  iconfontr
//
//  Created by Chase Zhang on 5/30/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFSizePanelController.h"

@interface IFSizePanelController ()

@end

@implementation IFSizePanelController

- (void)awakeFromNib
{
  [super awakeFromNib];
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  if ([userDefaults boolForKey:@"square"]) {
    [userDefaults bind:@"height" toObject:userDefaults withKeyPath:@"width" options:nil];
  }
  else {
    [userDefaults unbind:@"height"];
  }
}

- (void)lockStateChanged:(id)sender
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  if ([sender state] == NSOffState) {
    [userDefaults unbind:@"height"];
  }
  else {
    [userDefaults bind:@"height" toObject:userDefaults withKeyPath:@"width" options:nil];
  }
}

@end
