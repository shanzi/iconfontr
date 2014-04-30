//
//  IFExportPanelController.m
//  iconfontr
//
//  Created by Chase Zhang on 4/26/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFExportPanelController.h"
#import "IFGlyphView.h"
#import "IFFontGlyphModel.h"

static IFExportPanelController *shared;

@interface IFExportPanelController ()<NSOutlineViewDataSource, NSOutlineViewDelegate>

@end

@implementation IFExportPanelController

+ (instancetype)shared
{
  if (shared==nil){
    shared = [[IFExportPanelController alloc] init];
  }
  return shared;
}

- (id)init
{
  self = [super init];
  if (self) {
    self.clipToBounds = YES;
    self.transparency = YES;
    self.backgroundColor = [NSColor whiteColor];
    self.baseSize = 64;
    self.padding = 0;
    self.filetype = IFSVGFileType;
    self.showOnlySelected = YES;
  }
  return self;
}

- (NSString *)windowNibName
{
  return @"IFExportPanel";
}

- (void)showPanelFor:(NSWindow *)window
{
  if(self.window==nil) [self loadWindow];
  
  [NSApp beginSheet:self.window
     modalForWindow:window
      modalDelegate:self
     didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
        contextInfo:nil];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
  [sheet orderOut:nil];
}

- (void)setFiletype:(NSInteger)filetype
{
  _filetype = filetype;
  switch (filetype) {
    case IFJPEGFileType:
      self.clipEnabled = YES;
      self.transparencyEnabled = NO;
      self.transparency = NO;
      self.sizeEnabled = YES;
      break;
    case IFPNGFileType:
      self.clipEnabled = YES;
      self.transparencyEnabled = YES;
      self.sizeEnabled = YES;
      self.transparency = YES;
      break;
    case IFSVGFileType:
      self.clipEnabled = NO;
      self.clipToBounds = YES;
      self.transparencyEnabled = YES;
      self.sizeEnabled = NO;
      self.transparency = YES;
      break;
  }
}

- (void)panelAction:(id)sender
{
  if ([sender tag]==1) {
    [NSApp endSheet:self.window
         returnCode:NSFileHandlingPanelOKButton];
  }
  else {
    [NSApp endSheet:self.window
         returnCode:NSFileHandlingPanelCancelButton];
  }
}

- (void)setContents:(id<IFIconCollectionModel>)contents
{
  _contents = contents;
  [_selectionView reloadData];
}

- (void)setShowOnlySelected:(BOOL)showOnlySelected
{
  _showOnlySelected = showOnlySelected;
  [_selectionView reloadData];
}


#pragma mark - OutlineView Datasource
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if (item==nil) {
    return [[_contents sections] count];
  }
  else if ([item conformsToProtocol:@protocol(IFIconSectionModel)]){
    id<IFIconSectionModel> section = item;
    if (_showOnlySelected)
      return [[section selectedIcons] count];
    else
      return [[section icons] count];
  }
  else {
    return 0;
  }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  return [item conformsToProtocol:@protocol(IFIconSectionModel)];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  if (item==nil) {
    return [[_contents sections] objectAtIndex:index];
  }
  else if (_showOnlySelected) {
    return [[item selectedIcons] objectAtIndex:index];
  }
  else {
    return [[item icons] objectAtIndex:index];
  }
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  if ([[tableColumn identifier] isEqualToString:@"select"]) {
    if ([item conformsToProtocol:@protocol(IFIconSectionModel)]) {
      NSInteger state = [object integerValue];
      if (state==NSOffState) {
        for (id<IFIconModel>icon in [item icons]) {
          [icon setSelected:NO];
        }
      }
      else {
        for (id<IFIconModel>icon in [item icons]) {
          [icon setSelected:YES];
        }
      }
      [outlineView reloadItem:item reloadChildren:YES];
    }
    else if ([item conformsToProtocol:@protocol(IFIconModel)]) {
      [item setSelected:([object integerValue]!=NSOffState)];
      [outlineView reloadItem:item reloadChildren:NO];
      if ([item section]) [outlineView reloadItem:[item section]
                                   reloadChildren:_showOnlySelected];
    }
  }
  else if ([[tableColumn identifier] isEqualToString:@"name"]){
    if (object && ![object isEqualToString:@""]) {
      if([item isKindOfClass:[IFFontGlyph class]]) {
        [(IFFontGlyph *)item setName:object];
      }
      else if ([item isKindOfClass:[IFFontGlyphSection class]]) {
        [(IFFontGlyphSection *)item setName:object];
      }
        
      [outlineView reloadItem:item reloadChildren:NO];
    }
  }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  if ([[tableColumn identifier] isEqualToString:@"select"]) {
    if ([item conformsToProtocol:@protocol(IFIconModel)]) {
      return @([item selected]? NSOnState:NSOffState);
    }
    else if ([item conformsToProtocol:@protocol(IFIconSectionModel)]) {
      NSInteger selectedCount = [[item selectedIcons] count];
      if (selectedCount==[[item icons] count]) {
        return @(NSOnState);
      }
      else if (selectedCount>0) {
        return @(NSMixedState);
      }
      else {
        return @(NSOffState);
      }
    }
  }
  else if ([[tableColumn identifier] isEqualToString:@"name"]) {
    NSLog(@"%@", [item name]);
    return [item name];
  }
  else if ([[tableColumn identifier] isEqualToString:@"preview"]) {
    if ([item conformsToProtocol:@protocol(IFIconModel)]) {
      return [item bezierPath];
    }
  }
  else if ([[tableColumn identifier] isEqualToString:@"description"]) {
    if ([item conformsToProtocol:@protocol(IFIconModel)]) {
      NSRect rect = [item bounds];
      return [NSString stringWithFormat:@"  %.2f x %.2f (pt)", rect.size.width, rect.size.height];
    }
    else {
      return [NSString stringWithFormat:@"%ld of %ld icons selected",
               [[item selectedIcons] count],
               [[item icons] count]];
    }
  }
  return nil;
}

#pragma mark - OutlineView Datasource

@end
