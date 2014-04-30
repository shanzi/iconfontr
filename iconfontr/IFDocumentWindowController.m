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
#import "IFColorPicker.h"
#import "IFExportPanelController.h"

#import <JNWCollectionView.h>

@interface IFDocumentWindowController ()<JNWCollectionViewDataSource, JNWCollectionViewDelegate>
{
  NSColor *_foregroundColor;
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
  _colorPicker.pickedIndex = 0;
  _foregroundColor = _colorPicker.foregroundColor;
  _collectionView.dataSource = self;
  _collectionView.delegate = self;
  [_collectionView registerClass:[IFCollectionGlyphCell class] forCellWithReuseIdentifier:@"glyphCell"];
  [_collectionView reloadData];
}

#pragma mark - Actions

- (void)changeColor:(id)sender
{
  _foregroundColor = _colorPicker.foregroundColor;
  _collectionView.backgroundColor = _colorPicker.backgroundColor;
  for (IFCollectionGlyphCell *view in [_collectionView.documentView subviews]) {
    view.color = _foregroundColor;
    [view setNeedsDisplay:YES];
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
  glyphCell.color = _foregroundColor;
  
  return glyphCell;
}

- (BOOL)collectionView:(JNWCollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

@end
