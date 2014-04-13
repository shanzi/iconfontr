//
//  IFDocument.m
//  iconfontr
//
//  Created by Chase Zhang on 4/12/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFDocument.h"
#import "IFGlyphView.h"

@interface IFDocument () <JNWCollectionViewDataSource, JNWCollectionViewDelegate>
{
  NSMutableArray *_glyphPathArray;
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

- (NSString *)windowNibName
{
  return @"IFDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
  [super windowControllerDidLoadNib:windowController];
  [windowController.window setAcceptsMouseMovedEvents:YES];
  
  // initialize grid layout
  JNWCollectionViewGridLayout *layout = [JNWCollectionViewGridLayout new];
  _collectionView.collectionViewLayout = layout;
  layout.itemSize = NSMakeSize(80, 80);

  // display icons
  [_collectionView reloadData];
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
  CTFontRef theCTFont = CTFontCreateWithGraphicsFont(theCGFont, 64, NULL, NULL);
  _font = (__bridge NSFont *) theCTFont;
  
  // get available glyphs
  NSUInteger glyphCount = [_font numberOfGlyphs];
  _glyphPathArray = [[NSMutableArray alloc] initWithCapacity:glyphCount];
 
  for (NSUInteger i=1; i<=glyphCount; i++) {
    NSRect boundingRect = [_font boundingRectForGlyph:(NSGlyph)i];
    
    if (!NSIsEmptyRect(boundingRect)) {
      // convert glyph into bezier path
      NSBezierPath *path = [[NSBezierPath alloc] init];
      [path moveToPoint:NSMakePoint(-NSMidX(boundingRect), -NSMidY(boundingRect))];
      [path appendBezierPathWithGlyph:(NSGlyph)i inFont:_font];
      [_glyphPathArray addObject:path];
    }
  }
  
  return YES;
}


#pragma mark - DataSource

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return [_glyphPathArray count];
}

- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  IFGlyphView *glyphView = [[IFGlyphView alloc] init];

  NSBezierPath *path = [_glyphPathArray objectAtIndex:indexPath.jnw_item];
  glyphView.bezierPath = path;
  
  return glyphView;
}

- (BOOL)collectionView:(JNWCollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

@end
