//
//  IFDocument.m
//  iconfontr
//
//  Created by Chase Zhang on 4/12/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFDocument.h"
#import "IFDocumentWindowController.h"

@interface IFDocument ()
{
  NSMutableArray *_glyphPathes;
  NSFont *_font;
}

@end

@implementation IFDocument

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
  [(IFDocumentWindowController *)windowController setGlyphPathes:_glyphPathes];
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
  _glyphPathes = [[NSMutableArray alloc] initWithCapacity:glyphCount];
 
  for (NSUInteger i=1; i<=glyphCount; i++) {
    NSRect boundingRect = [_font boundingRectForGlyph:(NSGlyph)i];
    
    if (!NSIsEmptyRect(boundingRect)) {
      // convert glyph into bezier path
      NSBezierPath *path = [[NSBezierPath alloc] init];
      [path moveToPoint:NSMakePoint(-NSMidX(boundingRect), -NSMidY(boundingRect))];
      [path appendBezierPathWithGlyph:(NSGlyph)i inFont:_font];
      [_glyphPathes addObject:path];
    }
  }
  
  return YES;
}


@end
