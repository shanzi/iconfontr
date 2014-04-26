//
//  IFColorPickerView.m
//  iconfontr
//
//  Created by Chase Zhang on 4/18/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFColorPicker.h"

#import <NSColor+Crayola.h>

#define kPickerSize 24.0
#define kPickerInnerSize 5.0
#define kPickerPadding 4

@interface IFColorPicker ()
{
  NSRect _pickerRect;
  NSRect _pickerInnerRect;
  id _target;
  SEL _action;
}

@end

@implementation IFColorPicker

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  _pickerRect.origin.x = kPickerPadding;
  _pickerRect.origin.y = kPickerPadding;
  _pickerRect.size.width = kPickerSize - kPickerPadding * 2;
  _pickerRect.size.height = kPickerSize - kPickerPadding * 2;
  
  _pickerInnerRect.origin.x = kPickerSize/2 - kPickerInnerSize/2;
  _pickerInnerRect.origin.y = kPickerSize - kPickerPadding - kPickerInnerSize;
  _pickerInnerRect.size.width= kPickerInnerSize;
  _pickerInnerRect.size.height = kPickerInnerSize;
}

- (void)drawRect:(NSRect)dirtyRect
{
  [super drawRect:dirtyRect];
  
  NSInteger maxPickerCount = ceil(self.bounds.size.width/kPickerSize)-1;
  NSInteger colorsCount = MIN([self colorsCount], maxPickerCount);
  
  [NSGraphicsContext saveGraphicsState];
  
  NSRect boundRect = self.bounds;
  boundRect.origin.y-=2;
  NSBezierPath *border = [NSBezierPath bezierPathWithRect:boundRect];
  [[NSColor crayolaGraniteGrayColor] setStroke];
  [border stroke];
  
  NSAffineTransform *transform = [NSAffineTransform transform];
  CGFloat transformX = NSMidX(self.bounds) - colorsCount * kPickerSize / 2;
  CGFloat transformY = NSMidY(self.bounds) - kPickerSize / 2;
  [transform translateXBy:transformX yBy:transformY];
  [transform concat];
  
  NSBezierPath *circle = [NSBezierPath bezierPathWithRoundedRect:_pickerRect
                                                         xRadius:kPickerSize/2
                                                         yRadius:kPickerSize/2];
  
  NSBezierPath *innerCircle = [NSBezierPath bezierPathWithRoundedRect:_pickerInnerRect
                                                              xRadius:kPickerInnerSize/2
                                                              yRadius:kPickerInnerSize/2];
  [transform translateXBy:-transformX yBy:-transformY];
  [transform translateXBy:kPickerSize yBy:0];
  for (NSInteger i=0; i<colorsCount; i++) {
    
    
    [[self backgroundColorAtIndex:i] setFill];
    [circle fill];
    
    [[self foregroundColorAtIndex:i] setFill];
    [innerCircle fill];
    
    if (_pickedIndex==i || (_pickedIndex - [self colorsCount])==i) {
      [[NSColor blackColor] setStroke];
      [circle stroke];
    }
    [transform concat];
  }
  [NSGraphicsContext restoreGraphicsState];
}

- (NSInteger)colorsCount
{
  return 9;
}


- (NSColor *)foregroundColorAtIndex:(NSInteger)index
{
  switch (index) {
    case 0:
      return [NSColor blackColor];
    default:
      return [NSColor whiteColor];
  }
}

- (NSColor *)backgroundColorAtIndex:(NSInteger)index
{
  switch (index) {
    case 1:
      return [NSColor crayolaCeruleanColor];
    case 2:
      return [NSColor crayolaAquamarineColor];
    case 3:
      return [NSColor crayolaBananaColor];
    case 4:
      return [NSColor crayolaBittersweetColor];
    case 5:
      return [NSColor crayolaBurntOrangeColor];
    case 6:
      return [NSColor crayolaFernColor];
    case 7:
      return [NSColor crayolaInchwormColor];
    case 8:
      return [NSColor crayolaRedColor];
    default:
      return [NSColor clearColor];
  }
}


- (BOOL)setPickedForLocation:(NSPoint)location isRightClick:(BOOL)rightClick
{
  NSInteger maxPickerCount = ceil(self.bounds.size.width/kPickerSize)-1;
  NSInteger colorsCount = MIN([self colorsCount], maxPickerCount);
  CGFloat transformX = NSMidX(self.bounds) - colorsCount * kPickerSize / 2;
  NSInteger picked = ceil((location.x - transformX)/kPickerSize) - 1;
  if (picked >= colorsCount || picked < 0) return NO;
  
  if (rightClick)
    picked += [self colorsCount];
  
  if (picked==_pickedIndex)
    return NO;
  else {
    self.pickedIndex = picked;
    return YES;
  }
}


- (void)mouseUp:(NSEvent *)theEvent
{
  [super mouseUp:theEvent];
  
  NSPoint location = [self convertPoint:theEvent.locationInWindow fromView:nil];
  if ([self setPickedForLocation:location isRightClick:NO]) {
    [self setNeedsDisplay:YES];
    [self sendAction:_action to:_target];
  }
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
  [super rightMouseUp:theEvent];
  
  NSPoint location = [self convertPoint:theEvent.locationInWindow fromView:nil];
  if ([self setPickedForLocation:location isRightClick:YES]) {
    [self setNeedsDisplay:YES];
    [self sendAction:_action to:_target];
  }
}

- (void)setPickedIndex:(NSInteger)pickedIndex
{
  NSInteger maxIndex = [self colorsCount];
  _pickedIndex = pickedIndex;
  if (pickedIndex >= maxIndex) {
    pickedIndex -= maxIndex;
    pickedIndex = pickedIndex>maxIndex ? maxIndex-1 : pickedIndex;
    _foregroundColor = [self backgroundColorAtIndex:pickedIndex];
    _backgroundColor = [self foregroundColorAtIndex:pickedIndex];
  }
  else {
    _foregroundColor = [self foregroundColorAtIndex:pickedIndex];
    _backgroundColor = [self backgroundColorAtIndex:pickedIndex];
  }
}

#pragma mark - overide target and action
- (id)target
{
  return _target;
}

- (void)setTarget:(id)anObject
{
  _target = anObject;
}

- (SEL)action
{
  return _action;
}

- (void)setAction:(SEL)aSelector
{
  _action = aSelector;
}
@end
