//
//  IFGlyphView.m
//  iconfontr
//
//  Created by Chase Zhang on 4/12/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFGlyphView.h"

#define kGlyphViewPadding 2

@implementation IFGlyphView

- (void)drawRect:(NSRect)dirtyRect
{
  [super drawRect:dirtyRect];
  [NSGraphicsContext saveGraphicsState];
  
  
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
  
  // transform coordinates
  NSAffineTransform *transform = [NSAffineTransform transform];
  [transform translateXBy:NSMidX(self.bounds) yBy:NSMidY(self.bounds)];
  [transform concat];
  
  // draw path
  [_color setFill];
  [_bezierPath fill];
  
  
  [NSGraphicsContext restoreGraphicsState];
}

- (void)setSelected:(BOOL)selected
{
  [super setSelected:selected];
  [self setNeedsDisplay:YES];
}

@end
