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
#import "IFProgressPanel.h"
#import "NSBezierPath+SVGPathString.h"

static IFExportPanelController *shared;

@interface IFExportPanelController ()<NSOutlineViewDataSource, NSTableViewDataSource, NSTableViewDelegate>
{
  NSWindow *_modalWindow;
  NSDictionary *_saveTask;
  NSOperationQueue *_saveQueue;
  IFProgressPanel *_progressPanel;
  NSArray *_resolutionPreset;
}

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
    self.color = [NSColor blackColor];
    self.baseSize = 64;
    self.padding = 0;
    self.filetype = IFSVGFileType;
    self.showOnlySelected = YES;
    _saveQueue = [[NSOperationQueue alloc] init];
    _progressPanel = [[IFProgressPanel alloc] init];
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
  _modalWindow = window;
  [_modalWindow beginSheet:self.window
        completionHandler:^(NSModalResponse returnCode) {
          [self.window orderOut:nil];
        }];
}

- (void)setFiletype:(NSInteger)filetype
{
  _filetype = filetype;
  switch (filetype) {
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
    [self output];
  }
  else {
    [_modalWindow endSheet:self.window];
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

- (void)setResolutionPresetTag:(NSInteger)resolutionPresetTag
{
  _resolutionPresetTag = resolutionPresetTag;
  if (_resolutionPresetTag>0) {
    if (_resolutionPreset==nil) {
      NSURL *presetURL = [[NSBundle mainBundle] URLForResource:@"resolution-preset"
                                                 withExtension:@"plist"];
      _resolutionPreset = [NSArray arrayWithContentsOfURL:presetURL];
    }
    NSMutableArray *resolutions =
    [[NSMutableArray alloc] initWithArray:[_resolutionPreset objectAtIndex:resolutionPresetTag-1]];
    _resolutions = resolutions;
    [_resolutionsView reloadData];
  }
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
  self.resolutionPresetTag = 0;
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

#pragma mark - Output
- (NSArray *)collectIconsToSave
{
  NSMutableArray *iconsToSave = [[NSMutableArray alloc] init];
  for (id<IFIconSectionModel> icons in [_contents sections]) {
    [iconsToSave addObjectsFromArray:[icons selectedIcons]];
  }
  return iconsToSave;
}

- (void)output
{
  NSArray *iconsToSave = [self collectIconsToSave];
  if ([iconsToSave count]==0) {
    NSAlert *alert = [NSAlert alertWithMessageText:@"No icons to Export"
                                     defaultButton:@"Dismiss"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"Please select one or more icons and resolutions to export"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:self.window
                  completionHandler:nil];
    return;
  }
  else if ([iconsToSave count]==1 && (_filetype==IFSVGFileType || [_resolutions count]==1)) {
    [self saveSingle:[iconsToSave firstObject]];
  }
  else {
    [self saveMultiple:iconsToSave];
  }
}

- (void)saveSingle:(id<IFIconModel>)icon
{
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  savePanel.allowedFileTypes = @[(_filetype==IFSVGFileType ? @"svg" : @"png")];
  savePanel.canCreateDirectories = YES;
  [_saveQueue setSuspended:YES];
  [savePanel beginSheetModalForWindow:self.window
                    completionHandler:^(NSInteger result) {
                      if (result==NSFileHandlingPanelCancelButton) return;
                      [_saveQueue addOperationWithBlock:^{
                        [self saveIcon:icon resolution:[self.resolutions lastObject] url:savePanel.URL];
                      }];
                    }];
}

- (void)saveMultiple:(NSArray *)icons
{
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  openPanel.title = @"Select Directory to Export Multitple Icons";
  openPanel.allowedFileTypes = nil;
  openPanel.canChooseDirectories = YES;
  openPanel.allowsMultipleSelection = NO;
  openPanel.canCreateDirectories = YES;
  [_saveQueue setSuspended:YES];
  [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
    if (result==NSFileHandlingPanelCancelButton) return;
    [_saveQueue addOperationWithBlock:^{
      [self saveIcons:icons toDirectoryURL:openPanel.URL];
    }];
  }];
}

- (BOOL)saveIcon:(id<IFIconModel>)icon resolution:(NSDictionary *)resolution url:(NSURL *)url
{
  NSError *err = nil;
  BOOL success = NO;
  if (_filetype==IFSVGFileType) {
    NSBezierPath *path = [icon bezierPath];
    NSString *color = [NSBezierPath SVGColorStringWithColor:_color];
    NSString *svgText = [path SVGTextWithWidth:nil height:nil canvasStyle:nil pathStyle:color];
    success = [svgText writeToURL:url
                       atomically:YES
                         encoding:NSUTF8StringEncoding
                            error:&err];
    
  }
  else {
    NSInteger width = [[resolution objectForKey:@"width"] integerValue];
    NSInteger height = [[resolution objectForKey:@"height"] integerValue];
    NSInteger padding = [[resolution objectForKey:@"padding"] integerValue];
    NSData *data = [self PNGImageDataForPath:[icon bezierPath]
                                       width:width
                                      height:height
                                     padding:padding];
    success = [data writeToURL:url options:NSAtomicWrite error:&err];
  }
  if (err){
    [_saveQueue setSuspended:YES];
    [_saveQueue addOperationWithBlock:^{
      NSAlert *errorAlert = [NSAlert alertWithError:err];
      [errorAlert beginSheetModalForWindow:self.window
                         completionHandler:nil];
    }];
  }
  return success;
}

- (void)saveIcons:(NSArray *)icons toDirectoryURL:(NSURL *)url
{
  _progressPanel.title = @"Exporting Icons";
  _progressPanel.value = 0;
  
  [self.window beginSheet:_progressPanel
        completionHandler:nil];
  
  double singleTaskAmount = 0;
  if (_filetype==IFSVGFileType) {
    singleTaskAmount = 100.0/[icons count];
  }
  else {
    singleTaskAmount = 100.0/([icons count] * [_resolutions count]);
  }
  
  NSInteger unamedCount = 0;
  for (id<IFIconModel> icon in icons) {
    if (_progressPanel.hasCanceled) break;
    NSString *name = [icon name];
    
    if ([name length]==0)
      name = [NSString stringWithFormat:@"unamed-%ld", (++unamedCount)];
    
    if (_filetype==IFSVGFileType) {
      name = [name stringByAppendingString:@".svg"];
      
      NSURL *fileURL = [NSURL URLWithString:name relativeToURL:url];
      if ([self saveIcon:icon resolution:nil url:fileURL]) _progressPanel.value+=singleTaskAmount;
      else break;
    }
    else {
      for(NSDictionary *resolution in self.resolutions) {
        NSString *filename = nil;
        NSString *suffix = [resolution objectForKey:@"suffix"];
        if (suffix) filename = [name stringByAppendingString:suffix];
        filename = [filename stringByAppendingString:@".png"];
        NSURL *fileURL = [NSURL URLWithString:filename relativeToURL:url];
        if ([self saveIcon:icon resolution:resolution url:fileURL]) _progressPanel.value+=singleTaskAmount;
        else break;
      }
    }
  }
  [NSThread sleepForTimeInterval:1.0];
  [self.window endSheet:_progressPanel];
  [_progressPanel orderOut:nil];
}

- (NSData *)PNGImageDataForPath:(NSBezierPath *)path width:(NSInteger)width height:(NSInteger)height padding:(NSInteger)padding
{
  NSRect frame = NSMakeRect(padding, padding, width-padding*2, height-padding*2);
  NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                  pixelsWide:width
                                                                  pixelsHigh:height
                                                               bitsPerSample:8
                                                             samplesPerPixel:4
                                                                    hasAlpha:YES
                                                                    isPlanar:NO
                                                              colorSpaceName:NSCalibratedRGBColorSpace
                                                                 bytesPerRow:8*width
                                                                bitsPerPixel:32];

  [NSGraphicsContext saveGraphicsState];
  NSGraphicsContext *g = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
  [NSGraphicsContext setCurrentContext:g];
  [IFGlyphView drawPath:path inFrame:frame fitScale:YES color:_color];
  [NSGraphicsContext restoreGraphicsState];
  return [rep representationUsingType:NSPNGFileType properties:nil];
}

- (void)windowDidEndSheet:(NSNotification *)notification
{
  NSLog(@"%@", notification);
  [_saveQueue setSuspended:NO];
}
@end
