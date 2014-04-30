//
//  IFTableGlyphCell.m
//  iconfontr
//
//  Created by Chase Zhang on 4/30/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFTableGlyphCell.h"
#import "IFGlyphView.h"

@interface IFTableGlyphCell()

@end

@implementation IFTableGlyphCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  if (self.objectValue) {
    NSBezierPath *path = self.objectValue;
    if ([controlView isFlipped]) {
      NSAffineTransform *flip = [NSAffineTransform transform];
      [flip scaleXBy:1.0 yBy:-1.0];
      path = [flip transformBezierPath:path];
    }
    [IFGlyphView drawPath:path
                  inFrame:cellFrame
                    color:[NSColor blackColor]];
  }
}

@end
