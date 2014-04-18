//
//  IFDocumentWindowController.m
//  iconfontr
//
//  Created by Chase Zhang on 4/15/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFDocumentWindowController.h"
#import "IFGlyphView.h"
#import "IFColorPicker.h"

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
  self.window.backgroundColor = [NSColor whiteColor];
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


- (void)changeColor:(id)sender
{
  _foregroundColor = _colorPicker.foregroundColor;
  _collectionView.backgroundColor = _colorPicker.backgroundColor;
  for (IFGlyphView *view in _collectionView.visibleCells) {
    view.color = _foregroundColor;
    [view setNeedsDisplay:YES];
  }
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
