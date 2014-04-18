//
//  IFCollectionGridLayout.m
//  iconfontr
//
//  Created by Chase Zhang on 4/15/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFCollectionGridLayout.h"

@implementation IFCollectionGridLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
  return _allowsLiveLayout;
}

@end
