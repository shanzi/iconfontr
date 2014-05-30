//
//  IMColorPicker.m
//  IMColorPickerDemo
//
//  Created by Chase Zhang on 5/28/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IMColorPalette.h"

typedef enum{
  IMHighlightStyleNone=0,
  IMHighlightStyleSelected,
  IMHighlightStyleMouseOver,
} IMPickerHighlightStyle;

@interface IMColorPalette ()
{
  SEL _action;
  id _target;
  NSInteger _mouseOverIndex;
  NSMutableArray *_colors;
  NSCursor *_newPickerCursor;
  NSColorPanel *_colorPanel;
}

@end

@implementation IMColorPalette

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      _selectedIndex = -1;
      _colors = [[NSMutableArray alloc] init];
      _mouseOverIndex = -1;
      _pickerSize = 28;
      _newPickerCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:NSImageNameAddTemplate] hotSpot:NSZeroPoint];
    }
    return self;
}

- (BOOL)isFlipped
{
  return YES;
}

- (BOOL)acceptsFirstResponder
{
  return YES;
}

- (void)viewDidMoveToSuperview
{
  [super viewDidMoveToSuperview];
  NSInteger options = (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved
                       | NSTrackingActiveInKeyWindow| NSTrackingInVisibleRect);
  NSTrackingArea *area =
  [[NSTrackingArea alloc] initWithRect:[self bounds]
                               options:options
                                 owner:self
                              userInfo:nil];
  [self addTrackingArea:area];
  [[self window] makeFirstResponder:self];
}

- (void)setColors:(NSArray *)colors
{
  [_colors removeAllObjects];
  [_colors addObjectsFromArray:colors];
}

- (NSArray *)colors
{
  return _colors;
}

- (void)removeSelectedColor
{
  if (_selectedIndex>=0 && _selectedIndex<[_colors count]) {
    [self willChangeValueForKey:@"color"];
    [_colors removeObjectAtIndex:_selectedIndex];
    if (_selectedIndex>=[_colors count]) _selectedIndex = [_colors count] - 1;
    [self didChangeValueForKey:@"color"];
    [self setNeedsDisplay];
  }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
  if (selectedIndex<0) selectedIndex = 0;
  else if (selectedIndex >= [_colors count]) selectedIndex=[_colors count]-1;
  NSInteger oldIndex = _selectedIndex;
  
  [self willChangeValueForKey:@"color"];
  _selectedIndex = selectedIndex;
  [self didChangeValueForKey:@"color"];
  
  if (_selectedIndex != oldIndex) {
    [self setNeedsDisplayInRect:[self rectForIndex:oldIndex]];
    [self setNeedsDisplayInRect:[self rectForIndex:_selectedIndex]];
    [self sendAction:_action to:_target];
  }
}

- (void)addColorsFromColorList:(NSColorList *)colorlist
{
  if (colorlist) {
    for (NSString *key in [colorlist allKeys]) {
      [_colors addObject:[colorlist colorWithKey:key]];
    }
    [self setNeedsDisplay];
  }
}

- (void)applyDefaultColors
{
  [_colors removeAllObjects];
  [_colors addObject:[NSColor blackColor]];
  [_colors addObject:[NSColor whiteColor]];
  NSColorList *colorlist = [NSColorList colorListNamed:@"Crayons"];
  NSArray *keys =
  @[@"Cantaloupe", @"Honeydew", @"Spindrift", @"Sky", @"Lavender", @"Carnation",
    @"Salmon", @"Banana", @"Flora", @"Ice", @"Orchid", @"Bubblegum", @"Lead",
    @"Mercury", @"Tangerine", @"Lime", @"Sea Foam", @"Aqua", @"Grape", @"Strawberry",
    @"Tungsten", @"Silver", @"Maraschino", @"Lemon", @"Spring", @"Turquoise"];
  
  for (NSString *key in keys) {
    [_colors addObject:[colorlist colorWithKey:key]];
  }
  [_colors addObject:[NSColor whiteColor]];
  [_colors addObject:[NSColor whiteColor]];

  _selectedIndex = 0;
  [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
 [super drawRect:dirtyRect];
  
  // calculate range of pickers to draw
  NSRect bounds = [self bounds];
  CGFloat pickerSize = MAX(MIN(_pickerSize, NSWidth(bounds)), 24);
  CGFloat numOfColumns = floor(NSWidth(bounds) / pickerSize);
  CGFloat pickerWidth = NSWidth(bounds) / numOfColumns;
  CGFloat verticalOffset = floor(dirtyRect.origin.y / pickerSize);
  CGFloat numOfRows = ceil(NSHeight(dirtyRect) / pickerSize);
  CGFloat numSkipedLeft = floor(NSMinX(dirtyRect) / pickerWidth);
  CGFloat numToRight = ceil(NSMaxX(dirtyRect) / pickerWidth);
  NSRect pickerRect = NSMakeRect(0, 0, pickerSize, pickerSize);
  CGFloat horizontalPadding = (pickerWidth - pickerSize)/2;
  
  for (NSInteger row=verticalOffset; row <= verticalOffset + numOfRows; row++) {
    for (NSInteger col=numSkipedLeft; col < numToRight; col++) {
      NSInteger index = row * numOfColumns + col;
      if (index > [_colors count]) return;
      
      pickerRect.origin.x = col * pickerWidth + horizontalPadding;
      pickerRect.origin.y = row * pickerSize;
      
      IMPickerHighlightStyle style = IMHighlightStyleNone;
      if (index>=[_colors count]) return;
      else if (index==_selectedIndex) style = IMHighlightStyleSelected;
      else if(index==_mouseOverIndex) style = IMHighlightStyleMouseOver;
      
      [self drawColorCircleWithColor:_colors[index]
                              inRect:pickerRect
                      highlightStyle:style];
    }
  }
}

- (void)drawColorCircleWithColor:(NSColor *)color inRect:(NSRect)rect highlightStyle:(IMPickerHighlightStyle)style
{
  rect.origin.x += 2.0;
  rect.origin.y += 2.0;
  rect.size.width -= 4.0;
  rect.size.height -=4.0;
  CGFloat width = NSWidth(rect);
  CGFloat height = NSHeight(rect);
  CGFloat highlightRadius = MIN(width, height)/2;
  CGFloat colorRadius = highlightRadius * 0.6;
  CGFloat offset = highlightRadius * 0.2;
  
  if (style==IMHighlightStyleMouseOver) {
    NSBezierPath *highlightCircle =
    [NSBezierPath bezierPathWithRoundedRect:rect xRadius:highlightRadius yRadius:highlightRadius];
    [[NSColor controlHighlightColor] setFill];
    [[NSColor lightGrayColor] setStroke];
    [highlightCircle fill];
    [highlightCircle stroke];
  }
  else if (style==IMHighlightStyleSelected){
     NSBezierPath *highlightCircle =
    [NSBezierPath bezierPathWithRoundedRect:rect xRadius:highlightRadius yRadius:highlightRadius];
    [[NSColor whiteColor] setFill];
    [[NSColor lightGrayColor] setStroke];
    [highlightCircle fill];
    [highlightCircle stroke];
  }
  
  NSRect colorCircleRect =
  NSMakeRect(rect.origin.x + offset * 2, rect.origin.y + offset * 2, colorRadius * 2, colorRadius * 2);
  NSColor *circleStrokeColor = [self circleStrokeColorWithColor:color];
  NSBezierPath *colorCircle =
  [NSBezierPath bezierPathWithRoundedRect:colorCircleRect xRadius:colorRadius yRadius:colorRadius];
  
  [color setFill];
  [circleStrokeColor setStroke];

  [colorCircle fill];
  [colorCircle stroke];
}

- (NSColor *)circleStrokeColorWithColor:(NSColor *)color
{
  if ([color isEqualTo:[NSColor controlColor]]) {
    return [NSColor grayColor];
  }
  CGFloat hue, saturation, brightness, alpha;
  color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
  [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
  brightness *= 0.8;
  saturation *= 1.1;
  return [NSColor colorWithCalibratedHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

#pragma mark - Mouse tracking

- (NSInteger)indexForLocation:(NSPoint)location
{
  NSRect bounds = [self bounds];
  CGFloat pickerSize = MAX(MIN(_pickerSize, NSWidth(bounds)), 24);
  NSInteger numOfColumns = floor(NSWidth(bounds) / pickerSize);
  CGFloat pickerWidth = NSWidth(bounds) / numOfColumns;
  NSInteger row = floor(location.y / pickerSize);
  NSInteger left = floor(location.x / pickerWidth);
  return row * numOfColumns + left;
}

- (NSRect)rectForIndex:(NSInteger)index
{
  NSRect bounds = [self bounds];
  CGFloat pickerSize = MAX(MIN(_pickerSize, NSWidth(bounds)), 24);
  NSInteger numOfColumns = floor(NSWidth(bounds) / pickerSize);
  CGFloat pickerWidth = NSWidth(bounds) / numOfColumns;
  return NSMakeRect(index%numOfColumns * pickerWidth, index/numOfColumns * pickerSize, pickerWidth, pickerSize);
}

- (void)mouseMoved:(NSEvent *)theEvent
{
  NSPoint location = [theEvent locationInWindow];
  location = [self convertPoint:location fromView:nil];
  if (!NSPointInRect(location, self.visibleRect)) return;
  
  NSInteger oldIndex = _mouseOverIndex;
  _mouseOverIndex = [self indexForLocation:location];
  if(oldIndex!=_mouseOverIndex) {
    [self setNeedsDisplayInRect:[self rectForIndex:oldIndex]];
    [self setNeedsDisplayInRect:[self rectForIndex:_mouseOverIndex]];
  }
  
  if ([self indexForLocation:location]>=[_colors count] ) {
    if ([NSCursor currentCursor]!=_newPickerCursor) {
      [_newPickerCursor push];
    }
  }
  else {
    [_newPickerCursor pop];
  }
}


- (void)mouseExited:(NSEvent *)theEvent
{
  NSPoint location = [theEvent locationInWindow];
  location = [self convertPoint:location fromView:nil];
  NSInteger oldIndex = _mouseOverIndex;
  _mouseOverIndex = -1;
  [self setNeedsDisplayInRect:[self rectForIndex:oldIndex]];
  [_newPickerCursor pop];
}

- (void)mouseDown:(NSEvent *)theEvent
{
  NSPoint location = [theEvent locationInWindow];
  location = [self convertPoint:location fromView:nil];
  
  NSInteger index = [self indexForLocation:location];
  if (index >= [_colors count]) {
    [_colors addObject:[NSColor whiteColor]];
    self.selectedIndex = [_colors count]-1;
    [self showColorPanel];
  }
  else if ([theEvent clickCount]>1) {
    self.selectedIndex = index;
    [self showColorPanel];
  }
  else {
    self.selectedIndex = index;
    [[self window] makeFirstResponder:self];
  }
}

- (void)keyDown:(NSEvent *)theEvent
{
  if ([theEvent keyCode]==51) {
    [self removeSelectedColor];
  }
  else if ([theEvent keyCode]==48 || ([theEvent keyCode]==3 && ([theEvent modifierFlags] & NSControlKeyMask))) {
    // Tab/ C-F
    self.selectedIndex += 1;
  }
  else if ([theEvent keyCode]==11 && ([theEvent modifierFlags] & NSControlKeyMask)) {
    // C-B
    self.selectedIndex -= 1;
  }
  else [super keyDown:theEvent];
}


#pragma mark - Override action and target

- (SEL)action
{
  return _action;
}

- (void)setAction:(SEL)aSelector
{
  _action = aSelector;
}

- (id)target
{
  return _target;
}

- (void)setTarget:(id)anObject
{
  _target = anObject;
}

- (void)delete:(id)sender
{
  [self removeSelectedColor];
}

#pragma mark - Color panel
- (void)showColorPanel
{
  if (_colorPanel==nil) {
    _colorPanel = [NSColorPanel sharedColorPanel];
    [_colorPanel bind:@"color" toObject:self withKeyPath:@"color" options:nil];
  }
  [[self window] makeFirstResponder:self];
  [[NSApplication sharedApplication] orderFrontColorPanel:_colorPanel];
}

#pragma mark - properties

- (NSColor *)color
{
  if(_selectedIndex>=0 && _selectedIndex<[_colors count]){
    return [_colors objectAtIndex:_selectedIndex];
  }
  return nil;
}

- (void)changeColor:(id)sender
{
  if (_selectedIndex>=0 && _selectedIndex<[_colors count] && _colorPanel.color) {
    [self willChangeValueForKey:@"color"];
    [_colors setObject:_colorPanel.color atIndexedSubscript:_selectedIndex];
    [self didChangeValueForKey:@"color"];
    [self setNeedsDisplayInRect:[self rectForIndex:_selectedIndex]];
    [self sendAction:_action to:_target];
  }
}

- (NSColor *)mouseOverColor
{
  if (_mouseOverIndex>=0 && _mouseOverIndex<[_colors count]) {
    return [_colors objectAtIndex:_mouseOverIndex];
  }
  return nil;
}

@end
