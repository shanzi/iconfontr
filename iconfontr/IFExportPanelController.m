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

@interface IFExportPanelController ()<NSOutlineViewDataSource, NSTableViewDataSource, NSTableViewDelegate>

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
    case IFPNGFileType:
      self.resolutionEnabled = YES;
      break;
    case IFSVGFileType:
      self.resolutionEnabled = NO;
      self.removeResolutionEnabled = NO;
      [_resolutionsView deselectAll:nil];
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

- (NSArray *)resolutions
{
  if ([_resolutions count]==0) {
    NSMutableArray *resolutions = [[NSMutableArray alloc] init];
    [resolutions addObject:@{
                             @"suffix":@"",
                             @"width":@(48),
                             @"height":@(48),
                             @"padding":@(0)
                             }];
    _resolutions = resolutions;
  }
  return _resolutions;
}

- (void)editResolution:(id)sender{
  NSInteger selectedRow = [_resolutionsView selectedRow];
  if ([sender tag]==0) {
    NSDictionary *resolution = [_resolutions lastObject];
    NSString *suffix = [resolution objectForKey:@"suffix"];
    NSInteger width = [[resolution objectForKey:@"width"] integerValue];
    NSInteger height = [[resolution objectForKey:@"height"] integerValue];
    NSInteger padding = [[resolution objectForKey:@"padding"] integerValue];
    
    NSDictionary *newResolution =
    @{@"suffix": (suffix==nil || [suffix isEqualToString:@""])? @"@2x":@"",
      @"width": @(width*2),
      @"height": @(height*2),
      @"padding": @(padding*2)};
    [(NSMutableArray *)_resolutions addObject:newResolution];
    [_resolutionsView reloadData];
    [_resolutionsView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow+1] byExtendingSelection:NO];
  }
  else {
    [(NSMutableArray *)_resolutions removeObjectAtIndex:selectedRow];
    [_resolutionsView reloadData];
    [_resolutionsView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow-1] byExtendingSelection:NO];
  }
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

#pragma mark - Tableview Datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return [self.resolutions count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSDictionary *resolution = [_resolutions objectAtIndex:row];
  return [resolution objectForKey:tableColumn.identifier];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSDictionary *resolution = [_resolutions objectAtIndex:row];
  NSMutableDictionary *newResolution = [[NSMutableDictionary alloc] initWithDictionary:resolution];
  [newResolution setObject:object forKey:tableColumn.identifier];
  NSInteger padding = [[newResolution objectForKey:@"padding"] integerValue];
  NSInteger width = [[newResolution objectForKey:@"width"] integerValue];
  NSInteger height = [[newResolution objectForKey:@"height"] integerValue];
  NSInteger maxPadding = MIN(width, height) / 2 - 1;
  padding = MIN(maxPadding, padding);
  [newResolution setObject:@(padding) forKey:@"padding"];
  [(NSMutableArray *)_resolutions setObject:newResolution atIndexedSubscript:row];
  [_resolutionsView reloadData];
}

#pragma mark - Tableview Delegate
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
  self.removeResolutionEnabled = [_resolutionsView selectedRow]>=0 && [_resolutions count]>1;
}

@end
