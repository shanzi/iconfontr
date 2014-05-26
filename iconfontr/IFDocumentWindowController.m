//
//  IFDocumentWindowController.m
//  iconfontr
//
//  Created by Chase Zhang on 4/15/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFDocumentWindowController.h"
#import "IFMagnifyCollectionView.h"
#import "IFCollectionGlyphCell.h"
#import "IFExportPanelController.h"
#import "IFPropertyPopover.h"

#import <JNWCollectionView.h>

@interface IFDocumentWindowController ()<JNWCollectionViewDataSource, JNWCollectionViewDelegate, NSToolbarDelegate>
{
}

@end

@implementation IFDocumentWindowController

- (void)dealloc
{
  _collectionView.dataSource = nil;
  _collectionView.delegate = nil;
}

- (NSString *)windowNibName
{
  return @"IFDocumentWindow";
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  [self bind:@"color"
    toObject:[NSUserDefaults standardUserDefaults]
 withKeyPath:@"color"
     options:@{NSValueTransformerNameBindingOption:NSUnarchiveFromDataTransformerName}];
  _collectionView.dataSource = self;
  _collectionView.delegate = self;
  [_collectionView registerClass:[IFCollectionGlyphCell class] forCellWithReuseIdentifier:@"glyphCell"];
  [_collectionView reloadData];
}

- (void)close
{
  [self unbind:@"color"];
  [super close];
}

#pragma mark - bindings
- (void)setColor:(NSColor *)color
{
  _color = color;
  NSArray *cells = [_collectionView visibleCells];
  for (IFCollectionGlyphCell *cell in cells) {
    cell.color = _color;
  }
  NSColor *transformed = [color colorUsingColorSpaceName:NSCalibratedWhiteColorSpace];
  if (transformed.whiteComponent >= 0.95) {
    _collectionView.backgroundColor = [NSColor colorWithCalibratedWhite:0.8 alpha:1.0];
  }
  else {
    _collectionView.backgroundColor = [NSColor whiteColor];
  }
}

#pragma mark - Actions

- (void)toolbarAction:(id)sender
{
  NSInteger tag =[sender tag];
  switch (tag) {
    case 1:
      // show panel
      [IFPropertyPopover popWithIdentifier:[sender identifier] view:sender];
      break;
    case 2:
    case 3:
      [self.window.toolbar setSelectedItemIdentifier:[sender identifier]];
      break;
    case 4:
      // show export menu
      break;
      
    default:
      break;
  }
}

- (void)exportSelection:(id)sender
{
  IFExportPanelController *exportController = [IFExportPanelController shared];
  exportController.contents = _content;
  [exportController showPanelFor:self.window];
}


#pragma mark - save

- (void)exportSingle
{
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  savePanel.message = @"Export";
  savePanel.allowedFileTypes = @[@"svg", @"png", @"tiff", @"jpeg"];
  [savePanel beginSheetModalForWindow:self.window
                    completionHandler:^(NSInteger result) {
                      if(result==NSFileHandlingPanelCancelButton) return;
                      
                      [savePanel orderOut:nil];
                      
                      NSArray *selected = _collectionView.indexPathsForSelectedItems;
                      NSIndexPath *toExport = [selected lastObject];
                      NSString *content = [_collectionView SVGContentForIndexPath:toExport isPathString:NO];
                      if (content) {
                        NSError *err = nil;
                        [content writeToURL:[savePanel URL]
                                 atomically:YES
                                   encoding:NSUTF8StringEncoding
                                      error:&err];
                        if (err) {
                          NSRunCriticalAlertPanel(@"Export Failed",
                                                  @"Failed to write into selected path",
                                                  @"dismiss", nil, nil);
                        }
                      }
                      else {
                        NSRunCriticalAlertPanel(@"Empty Content", @"Nothing to write",
                                                @"dismiss", nil, nil);
                      }
                    }];
}

- (void)exportImages
{
  
}

#pragma mark - DataSource
- (NSInteger)numberOfSectionsInCollectionView:(JNWCollectionView *)collectionView
{
  return [_content.sections count];
}

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  NSArray *sections = [_content sections];
  id<IFIconSectionModel> sec = [sections objectAtIndex:section];
  return [[sec icons] count];
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  IFCollectionGlyphCell *glyphCell = (IFCollectionGlyphCell *)[collectionView dequeueReusableCellWithIdentifier:@"glyphCell"];
  
  NSArray *sections = [_content sections];
  id<IFIconSectionModel> section = [sections objectAtIndex:indexPath.jnw_section];
  id<IFIconModel> glyph = [[section icons] objectAtIndex:indexPath.jnw_item];
  glyphCell.content = glyph;
  glyphCell.color = _color;
  
  return glyphCell;
}

- (BOOL)collectionView:(JNWCollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}


@end
