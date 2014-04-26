//
//  NSBezierPath+SVGPathString.h
//  iconfontr
//
//  Created by Chase Zhang on 4/26/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (SVGPathString)

- (NSString *)SVGPathString;
- (NSString *)SVGText;
- (NSString *)SVGTextWithWidth:(NSString *)width height:(NSString *)height canvasStyle:(NSString *)cstyle pathStyle:(NSString *)style;

+ (NSString *)SVGColorStringWithColor:(NSColor *)color;

@end
