//
//  IFDocument.h
//  iconfontr
//
//  Created by Chase Zhang on 4/12/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <JNWCollectionView.h>

@interface IFDocument : NSDocument

@property(nonatomic, readonly) NSFont *font;
@property(nonatomic, readonly) NSArray *glyphs;

@property(assign) IBOutlet JNWCollectionView* collectionView;

@end
