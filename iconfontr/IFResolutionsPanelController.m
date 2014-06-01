//
//  IFResolutionsPanelController.m
//  iconfontr
//
//  Created by Chase Zhang on 5/30/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFResolutionsPanelController.h"

@interface IFResolutionsPanelController () <NSTableViewDataSource, NSTableViewDelegate>
{
  NSMenu *_presetMenu;
  NSMenuItem *_customMenuItem;
  NSArray *_resolutions;
  NSMutableArray *_scales;
}
@end

@implementation IFResolutionsPanelController

- (NSArray *)resolutions
{
  if (_resolutions==nil) {
    NSURL *resolutions_url = [[NSBundle mainBundle] URLForResource:@"resolutions" withExtension:@"plist"];
    _resolutions = [NSArray arrayWithContentsOfURL:resolutions_url];
  }
  return _resolutions;
}

- (NSArray *)userDefinedResolutions
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *resolutions = [defaults objectForKey:@"user_resolutions"];
  return resolutions;
}

- (NSMenu *)presetMenu
{
  if (_presetMenu==nil) {
    _presetMenu = [[NSMenu alloc] init];
    [_presetMenu addItemWithTitle:@"Presets" action:nil keyEquivalent:@""];
    [_presetMenu addItem:[NSMenuItem separatorItem]];
    
    // load preset
    NSArray *resolutions = [self resolutions];
    for (NSInteger i=0; i<[resolutions count]; i++) {
      NSDictionary *resolution = [resolutions objectAtIndex:i];
      NSString *name = resolution[@"name"];
      if (name) {
        NSMenuItem *item = [[NSMenuItem alloc] init];
        item.title = name;
        item.tag = i;
        item.action = @selector(presetAction:);
        item.target = self;
        [_presetMenu addItem:item];
      }
      else {
        [_presetMenu addItem:[NSMenuItem separatorItem]];
      }
    }
    [_presetMenu addItem:[NSMenuItem separatorItem]];
    
    // add custom
    NSMenuItem *customItem = [[NSMenuItem alloc] init];
    customItem.title = @"Custom";
    customItem.action = @selector(presetAction:);
    customItem.target = self;
    customItem.tag = -1;
    _customMenuItem = customItem;
    [_presetMenu addItem:customItem];
    
  }
  return _presetMenu;
}

- (NSMenuItem *)currentSelectedMenuItem
{
  NSMenu *presetMenu = [self presetMenu];
  for (NSMenuItem *item in [presetMenu itemArray]) {
    if ([item state]==NSOnState) {
      return item;
    }
  }
  NSMenuItem *custom = [presetMenu itemWithTag:-1];
  [custom setState:NSOnState];
  return custom;
}


- (void)listAction:(id)sender
{
  NSMenu *menu = [self presetMenu];
  menu = [self presetMenu];
  NSRect buttonBounds = [sender bounds];
  CGFloat x = NSMinX(buttonBounds);
  CGFloat y = NSMinY(buttonBounds);
  [menu popUpMenuPositioningItem:[self currentSelectedMenuItem] atLocation:NSMakePoint(x, y) inView:sender];
}


- (void)presetAction:(id)sender
{
  NSMenuItem *item = [self currentSelectedMenuItem];
  [item setState:NSOffState];
  
  if([sender tag]>=0) [self switchToPreset:[_resolutions objectAtIndex:[sender tag]]];
  
  [_tableView reloadData];
  [sender setState:NSOnState];
}

- (void)switchToPreset:(NSDictionary *)preset
{
  _scales = [[NSMutableArray alloc] init];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *baseSize = [preset objectForKey:@"base"];
  NSArray *scales = [preset objectForKey:@"scales"];
  NSInteger width = [[baseSize objectForKey:@"width"] integerValue];
  NSInteger height = [[baseSize objectForKey:@"height"] integerValue];
  
  if (width==height) [defaults setValue:@(YES) forKey:@"square"];
  [defaults setValue:@(width) forKey:@"width"];
  [defaults setValue:@(height) forKey:@"height"];
  
  for (NSDictionary *scale in scales) {
    float s = [[scale objectForKey:@"scale"] floatValue];
    s = roundf(s*10)/10.0;
    NSString *suffix;
    
    if (fabsf(s-1)<0.1) {
      suffix = @"";
    }
    else {
      suffix = [NSString stringWithFormat:@"@%@x", [self scaleStringWithFloat:s]];
    }
    
    NSString *description = [scale objectForKey:@"description"];
    [_scales addObject:@{@"scale": @(s),
                         @"suffix":suffix,
                         @"description":description}];
  }
  [_tableView reloadData];
}


- (void)resolutionAction:(id)sender
{
  if ([sender tag]) {
    if ([_scales count]>1) {
      NSInteger index = [_tableView selectedRow];
      [_scales removeObjectAtIndex:index];
      [self presetAction:_customMenuItem];
      if (index>=[_scales count]) index = [_scales count] -1;
      NSIndexSet *selectSet = [[NSIndexSet alloc] initWithIndex:index];
      [_tableView selectRowIndexes:selectSet byExtendingSelection:NO];
    }
  }
  else {
    if ([self numberOfRowsInTableView:nil]) {
      NSDictionary *scale = [_scales lastObject];
      float s = [[scale valueForKey:@"scale"] floatValue] * 2;
      s = roundf(s * 10)/10.0;
      NSString *suffix = [NSString stringWithFormat:@"@%@x", [self scaleStringWithFloat:s]];
      [_scales addObject:@{@"scale": @(s), @"suffix": suffix}];
      [self presetAction:_customMenuItem];
      
      NSIndexSet *selectSet = [[NSIndexSet alloc] initWithIndex:[_scales count]-1];
      [_tableView selectRowIndexes:selectSet byExtendingSelection:NO];
    }
  }
}

#pragma mark - table delegate and data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  NSInteger count = [_scales count];
  if (count==0) {
    _scales = [NSMutableArray arrayWithObject: @{@"scale": @(1), @"suffix": @""}];
    [[self currentSelectedMenuItem] setState:NSOffState];
    [[[self presetMenu] itemWithTag:-1] setState:NSOnState];
  }
  
  if ([_scales count]>1) [_deleteButton setEnabled:YES];
  else [_deleteButton setEnabled:NO];
  
  return [_scales count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSDictionary *scale = [_scales objectAtIndex:row];
  if ([tableColumn.identifier isEqualToString:@"suffix"]) {
    NSString *suffix = [scale objectForKey:@"suffix"];
    if ([suffix length] == 0) {
      NSTextFieldCell *cell = [tableColumn dataCellForRow:row];
      [cell setPlaceholderString:@"1x"];
    }
    return suffix;
  }
  else if ([tableColumn.identifier isEqualToString:@"size"]) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger width = [defaults integerForKey:@"width"];
    NSInteger height = [defaults integerForKey:@"height"];
    float s = [[scale objectForKey:@"scale"] floatValue];
    width = roundf(width*s);
    height = roundf(height*s);
    return [NSString stringWithFormat:@"(%ldx%ld)", width, height];
  }
  else if ([tableColumn.identifier isEqualToString:@"description"]) {
    return [scale objectForKey:@"description"];
  }
  return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if ([object length]==0) {
      [_scales setObject:@{@"scale": @(1), @"suffix": @""} atIndexedSubscript:row];
  }
  else if ([tableColumn.identifier isEqualToString:@"suffix"]) {
    NSString *value = [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    const char *cvalue = [value cStringUsingEncoding:NSUTF8StringEncoding];
    NSInteger clen = [value lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    float scale = 0;
    char pre = '\0', suf = '\0';
    for (NSInteger i=0; i<clen; i++) {
      char c = cvalue[i];
      if ((c=='@' || c=='_' || c=='.' || c=='-') && i==0){
        pre = c;
      }
      else if (c>='0' && c<='9') {
        scale = scale * 10 + (c-'0');
      }
      else if (c=='.' && (i+1 < clen)) {
        char nd = cvalue[++i];
        scale += (nd-'0')/10.0;
        if (i+1<clen) {
          c = cvalue[i+1];
          if (c>='5' && c <='9') {
            scale += 0.1;
          }
        }
        while ((i+1)<clen && cvalue[i+1]>='0' && cvalue[i+1]<='9') i++;
      }
      else if (c=='x' && i+1 == clen){
        suf = c;
      }
      else {
        return;
      }
    }
    if (scale>0) {
      if (scale > 16) scale = 16;
      
      NSString *suffix = @"";
      if (pre) suffix = [suffix stringByAppendingFormat:@"%c", pre];
      suffix = [suffix stringByAppendingString:[self scaleStringWithFloat:scale]];
      if (suf) suffix = [suffix stringByAppendingFormat:@"%c", suf];
      
      float originScale = [[[_scales objectAtIndex:row] objectForKey:@"scale"] floatValue];
      if (fabsf(originScale-scale)<0.1) return;
      
      [_scales setObject:@{@"scale": @(scale), @"suffix": suffix} atIndexedSubscript:row];
      [[self currentSelectedMenuItem] setState:NSOffState];
      [[[self presetMenu] itemWithTag:-1] setState:NSOnState];
    }
  }
}

- (NSString *)scaleStringWithFloat:(float) scale
{
  if (fabsf(scale - ceilf(scale))<0.1) {
    return [NSString stringWithFormat:@"%.0f", scale];
  }
  else {
    return [NSString stringWithFormat:@"%.1f", scale];
  }
}
@end
