//
//  IFMagnifyCollectionView.h
//  iconfontr
//
//  Created by Chase Zhang on 4/15/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <JNWCollectionView.h>

@interface IFMagnifyCollectionView : JNWCollectionView

- (NSString *)SVGContentForIndexPath:(NSIndexPath*)indexPath isPathString:(BOOL)isPathString;

@end
