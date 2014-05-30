//
//  IFColorPanelController.m
//  iconfontr
//
//  Created by Chase Zhang on 5/30/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//
#import <IMColorPalette.h>
#import "IFColorPanelController.h"

@interface IFColorPanelController ()

@end

@implementation IFColorPanelController

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSData *colorsData = [userDefaults valueForKey:@"colors"];
  if (colorsData) {
    NSArray *colors = [NSUnarchiver unarchiveObjectWithData:colorsData];
    if ([colors count]) {
      _colorPalette.colors = colors;
      _colorPalette.selectedIndex = [[userDefaults valueForKey:@"colorSelectedIndex"] integerValue];
      return;
    }
  }
  [_colorPalette applyDefaultColors];
}



- (void)changeColor:(id)sender
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSData *colorData = [NSArchiver archivedDataWithRootObject:_colorPalette.color];
  NSData *colorsData = [NSArchiver archivedDataWithRootObject:_colorPalette.colors];
  [userDefaults setObject:colorData forKey:@"color"];
  [userDefaults setObject:colorsData forKey:@"colors"];
  [userDefaults setObject:@(_colorPalette.selectedIndex) forKey:@"colorSelectedIndex"];
}

@end
