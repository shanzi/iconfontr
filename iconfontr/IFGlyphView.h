//
//  IFGlyphView.h
//  iconfontr
//
//  Created by Chase Zhang on 4/12/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <JNWCollectionView.h>

@interface IFGlyphView : JNWCollectionViewCell

@property(nonatomic) NSBezierPath *bezierPath;
@property(nonatomic) NSColor *color;

@end
