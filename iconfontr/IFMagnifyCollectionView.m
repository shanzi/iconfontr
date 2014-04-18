//
//  IFMagnifyCollectionView.m
//  iconfontr
//
//  Created by Chase Zhang on 4/15/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFMagnifyCollectionView.h"
#import "IFCollectionGridLayout.h"

#define kEqualsKeyCode 24
#define kMinusKeyCode 27

@interface IFMagnifyCollectionView ()
{
  IFCollectionGridLayout *_gridLayout;
}

@end

@implementation IFMagnifyCollectionView

- (void)awakeFromNib
{
  [super awakeFromNib];
  [self invokeMagnification];
  [self applyGridLayout];
}

- (void)applyGridLayout
{
  if (_gridLayout==nil) {
    _gridLayout = [[IFCollectionGridLayout alloc] init];
    _gridLayout.itemSize = NSMakeSize(100, 100);
    _gridLayout.allowsLiveLayout = YES;
    self.collectionViewLayout = _gridLayout;
  }
}

- (void)invokeMagnification
{
  if (!self.allowsMagnification) {
    self.allowsMagnification = YES;
    self.magnification = 1.0;
    self.maxMagnification = 3;
    self.minMagnification = 1.0;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(liveMagnifyWillStart:)
                                                 name:NSScrollViewWillStartLiveMagnifyNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(liveMagnifyDidEnd:)
                                                 name:NSScrollViewDidEndLiveMagnifyNotification
                                               object:self];
  }
}

- (void)liveMagnifyWillStart:(NSNotification *)n
{
  _gridLayout.allowsLiveLayout = NO;
}

- (void)liveMagnifyDidEnd:(NSNotification *)n
{
  if (self.magnification<=1.01 || [self.documentView frame].size.width <= self.visibleSize.width) {
    _gridLayout.allowsLiveLayout = YES;
    [self.collectionViewLayout invalidateLayout];
  }
}

- (void)keyDown:(NSEvent *)theEvent
{
  // cancel the sound played after keydown
}

- (void)keyUp:(NSEvent *)theEvent
{
  if ([theEvent keyCode]==kEqualsKeyCode) {
    self.magnification += 0.2;
  }
  else if([theEvent keyCode]==kMinusKeyCode) {
    self.magnification -= 0.2;
  }
}

- (void)layoutDocumentView {
	if (_gridLayout.allowsLiveLayout) {
    [super layoutDocumentView];
  }
}

@end
