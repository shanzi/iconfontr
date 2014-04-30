//
//  IFGlyphView.m
//  iconfontr
//
//  Created by Chase Zhang on 4/29/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFGlyphView.h"
#define kGlyphViewPadding 2

@implementation IFGlyphView

+ (void)drawPath:(NSBezierPath *)path inFrame:(NSRect)frame color:(NSColor *)color
{
  [NSGraphicsContext saveGraphicsState];
  
  // transform coordinates
  NSAffineTransform *transform = [NSAffineTransform transform];
  [transform translateXBy:NSMidX(frame) yBy:NSMidY(frame)];
  [transform concat];
  
  CGFloat size = MIN(frame.size.width, frame.size.height);
  if (size<=48) {
    NSAffineTransform *scaleTransfrom = [NSAffineTransform transform];
    [scaleTransfrom scaleBy:size/48];
    [scaleTransfrom concat];
  }
  
  
  // draw path
  [color setFill];
  [path fill];
  
  
  [NSGraphicsContext restoreGraphicsState];
}

- (void)drawRect:(NSRect)dirtyRect
{
  [super drawRect:dirtyRect];
  
  // selection
  if (self.selected) {
    NSRect borderRect = NSMakeRect(kGlyphViewPadding,
                                   kGlyphViewPadding,
                                   self.bounds.size.width-kGlyphViewPadding,
                                   self.bounds.size.height-kGlyphViewPadding);
    NSBezierPath *border = [NSBezierPath bezierPathWithRoundedRect:borderRect
                                                           xRadius:borderRect.size.width/2
                                                           yRadius:borderRect.size.height/2];
    [[NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:0.5] setFill];
    [border fill];
  }
  
  [IFGlyphView drawPath:_bezierPath inFrame:dirtyRect color:_color];
}

@end
