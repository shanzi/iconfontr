//
//  IFGlyphView.m
//  iconfontr
//
//  Created by Chase Zhang on 4/12/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFCollectionGlyphCell.h"
#import "IFGlyphView.h"


@interface IFCollectionGlyphCell()
{
  IFGlyphView *_contentView;
}

@end

@implementation IFCollectionGlyphCell

- (NSView *)contentView
{
  if (_contentView==nil) {
    _contentView = [[IFGlyphView alloc] initWithFrame:self.frame];
    _contentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self addSubview:_contentView];
  }
  return _contentView;
}

- (void)setSelected:(BOOL)selected
{
  [super setSelected:selected];
  if ([_content respondsToSelector:@selector(setSelected:)]) {
    [_content performSelector:@selector(setSelected:) withObject:@(selected)];
  }
  _contentView.selected = selected;
  [_contentView setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
  NSArray *selected = [self.collectionView indexPathsForSelectedItems];
  if (![selected containsObject:self.indexPath]) {
    [self.collectionView selectItemAtIndexPath:self.indexPath
                              atScrollPosition:JNWCollectionViewScrollPositionNone
                                      animated:NO];
  }
  [super rightMouseDown:theEvent];
}

- (void)setContent:(id)content
{
  _content = content;
  IFGlyphView *contentView = (IFGlyphView *)self.contentView;
  contentView.bezierPath = [_content bezierPath];
}

- (NSColor *)color
{
  IFGlyphView *contentView = (IFGlyphView *)self.contentView;
  return contentView.color;
}

- (void)setColor:(NSColor *)color
{
  IFGlyphView *contentView = (IFGlyphView *)self.contentView;
  contentView.color = color;
  [contentView setNeedsDisplay:YES];
}

@end
