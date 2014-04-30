//
//  IFDocument.m
//  iconfontr
//
//  Created by Chase Zhang on 4/12/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFFontDocument.h"
#import "IFDocumentWindowController.h"
#import "IFFontGlyphModel.h"

@interface IFFontDocument ()
{
  NSMutableArray *_glyphPathes;
  NSFont *_font;
  IFFontGlyphCollection *_collection;
}

@end

@implementation IFFontDocument

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) makeWindowControllers
{
  IFDocumentWindowController *windowController = [[IFDocumentWindowController alloc] init];
  windowController.content = _collection;
  [self addWindowController:windowController];
}



+ (BOOL)autosavesInPlace
{
    return NO;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
  // read font from url
  CFURLRef theCFURL = (__bridge CFURLRef)url;
  CGDataProviderRef dataProvider = CGDataProviderCreateWithURL(theCFURL);
  CGFontRef theCGFont = CGFontCreateWithDataProvider(dataProvider);
  
  if (theCGFont == NULL) return NO;
  
  // cast CGFont back to NSFont
  CTFontRef theCTFont = CTFontCreateWithGraphicsFont(theCGFont, 48, NULL, NULL);
  _font = (__bridge NSFont *) theCTFont;
  
  // get available glyphs
  NSUInteger glyphCount = [_font numberOfGlyphs];
  _collection = [[IFFontGlyphCollection alloc] init];
  
  IFFontGlyphSection *defaultSection = [[IFFontGlyphSection alloc] init];
  defaultSection.collection = _collection;
  
  NSMutableArray *glyphs = [[NSMutableArray alloc] initWithCapacity:glyphCount];
 
  for (NSUInteger i=1; i<=glyphCount; i++) {
    NSRect boundingRect = [_font boundingRectForGlyph:(NSGlyph)i];
    
    if (!NSIsEmptyRect(boundingRect)) {
      // convert glyph into bezier path
      NSBezierPath *path = [[NSBezierPath alloc] init];
      [path moveToPoint:NSMakePoint(-NSMidX(boundingRect), -NSMidY(boundingRect))];
      [path appendBezierPathWithGlyph:(NSGlyph)i inFont:_font];
      if (!NSIsEmptyRect([path bounds])) {
        IFFontGlyph *glyph = [[IFFontGlyph alloc] init];
        unichar charCode = (unichar)i;
        glyph.unicode = [NSString stringWithCharacters:&charCode length:1];
        glyph.bezierPath = path;
        glyph.collection = _collection;
        glyph.section = defaultSection;
        [glyphs addObject:glyph];
      }
    }
  }
  
  defaultSection.icons = glyphs;
  _collection.sections = @[defaultSection];
  
  if (_collection) return YES;
  return NO;
}


@end
