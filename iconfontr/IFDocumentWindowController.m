//
//  IFDocumentWindowController.m
//  iconfontr
//
//  Created by Chase Zhang on 4/15/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFDocumentWindowController.h"
#import "IFMagnifyCollectionView.h"
#import "IFGlyphView.h"
#import "IFColorPicker.h"
#import "IFExportPanelController.h"

#import <JNWCollectionView.h>

@interface IFDocumentWindowController ()<JNWCollectionViewDataSource, JNWCollectionViewDelegate>
{
  NSArray *_glyphPathes;
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
  [_collectionView registerClass:[IFGlyphView class] forCellWithReuseIdentifier:@"glyphView"];
  [_collectionView reloadData];
}

- (void)setGlyphPathes:(NSArray *)glyphPathes
{
  _glyphPathes = glyphPathes;
}

#pragma mark - Actions

- (void)changeColor:(id)sender
{
  _foregroundColor = _colorPicker.foregroundColor;
  _collectionView.backgroundColor = _colorPicker.backgroundColor;
  for (IFGlyphView *view in [_collectionView.documentView subviews]) {
    view.color = _foregroundColor;
    [view setNeedsDisplay:YES];
  }
}

- (void)exportSelection:(id)sender
{
  if ([_collectionView.indexPathsForSelectedItems count]==1) {
    [self exportSingle];
  }
  else {
    IFExportPanelController *exportController = [IFExportPanelController shared];
    [exportController showPanelFor:self.window];
  }
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

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return [_glyphPathes count];
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  IFGlyphView *glyphView = (IFGlyphView *)[collectionView dequeueReusableCellWithIdentifier:@"glyphView"];
  NSBezierPath *path = [_glyphPathes objectAtIndex:indexPath.jnw_item];
  glyphView.bezierPath = path;
  glyphView.color = _foregroundColor;
  
  return glyphView;
}

- (BOOL)collectionView:(JNWCollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

@end
