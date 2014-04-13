//
//  IFGlyphView.m
//  iconfontr
//
//  Created by Chase Zhang on 4/12/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFGlyphView.h"

@interface IFGlyphView()
{
  BOOL _mouseOver;
}

@end

@implementation IFGlyphView

- (void)drawRect:(NSRect)dirtyRect
{
  [super drawRect:dirtyRect];
  [NSGraphicsContext saveGraphicsState];
  
  
  // selection
  if (self.selected) {
    NSBezierPath *border = [NSBezierPath bezierPathWithRect:self.bounds];
    [[NSColor colorWithCalibratedRed:0.3 green:0.5 blue:1.0 alpha:1.0] setStroke];
    [border setLineWidth:4.0];
    [border stroke];
  }
  else if (_mouseOver){
    NSBezierPath *border = [NSBezierPath bezierPathWithRect:self.bounds];
    [[NSColor controlHighlightColor] setStroke];
    [border setLineWidth:4.0];
    [border stroke];
  }
  
  // transform coordinates
  NSAffineTransform *transform = [NSAffineTransform transform];
  [transform translateXBy:NSMidX(self.bounds) yBy:NSMidY(self.bounds)];
  [transform concat];
  
  // draw path
  [[NSColor blackColor] setFill];
  [_bezierPath fill];
  
  
  [NSGraphicsContext restoreGraphicsState];
}

- (void)setSelected:(BOOL)selected
{
  [super setSelected:selected];
  [self setNeedsDisplay:YES];
}

- (void)viewDidMoveToSuperview
{
  [super viewDidMoveToSuperview];
  [self addTrackingRect:self.bounds
                  owner:self
               userData:nil
           assumeInside:NO];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
  _mouseOver = YES;
  [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
  _mouseOver = NO;
  [self setNeedsDisplay:YES];
}

@end
