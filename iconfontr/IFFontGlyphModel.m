//
//  IFLocalFontModels.m
//  iconfontr
//
//  Created by Chase Zhang on 4/29/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFFontGlyphModel.h"
#import "NSBezierPath+SVGPathString.h"

@implementation IFFontGlyph

- (NSString *)pathString
{
  return [_bezierPath SVGPathString];
}

- (NSRect)bounds
{
  return [_bezierPath bounds];
}

- (void)setSelected:(BOOL)selected
{
  _selected = selected;
  [(IFFontGlyphSection *)[self section] invalidateSelectedIconsWith:self];
}

@end

@interface IFFontGlyphSection ()
{
  NSMutableArray *_selectedIcons;
}

@end

@implementation IFFontGlyphSection

- (NSString *)name
{
  if (_name==nil || [_name isEqualToString:@""])
    return @"default";
  return _name;
}

- (NSArray *)selectedIcons
{
  if (_selectedIcons==nil) {
    _selectedIcons = [[NSMutableArray alloc] init];
    for (id<IFIconModel> icon in [self icons]) {
      if ([icon selected]) {
        [_selectedIcons addObject:icon];
      }
    }
  }
  return _selectedIcons;
}

- (void)invalidateSelectedIconsWith:(id)icon
{
  _selectedIcons = nil;
}

@end

@implementation IFFontGlyphCollection

@end