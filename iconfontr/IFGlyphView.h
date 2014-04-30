//
//  IFGlyphView.h
//  iconfontr
//
//  Created by Chase Zhang on 4/29/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFGlyphView : NSView

@property(nonatomic) BOOL selected;
@property(nonatomic) NSBezierPath *bezierPath;
@property(nonatomic) NSColor *color;

+ (void)drawPath:(NSBezierPath *)path inFrame:(NSRect)frame color:(NSColor *)color;

@end
