//
//  IFLocalFontModels.h
//  iconfontr
//
//  Created by Chase Zhang on 4/29/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFModelProtocol.h"

@interface IFFontGlyph : NSObject<IFIconModel>

@property(nonatomic) NSString* name;
@property(nonatomic) NSString* unicode;
@property(nonatomic) NSBezierPath *bezierPath;
@property(nonatomic) BOOL selected;
@property(nonatomic, weak) id<IFIconSectionModel> section;
@property(nonatomic, weak) id<IFIconCollectionModel> collection;

@end

@interface IFFontGlyphSection : NSObject<IFIconSectionModel>

@property(nonatomic) NSString* name;
@property(nonatomic) NSArray *icons;
@property(nonatomic, weak) id<IFIconCollectionModel> collection;

- (void)invalidateSelectedIconsWith:(id)icon;

@end

@interface IFFontGlyphCollection : NSObject<IFIconCollectionModel>

@property(nonatomic) NSString *name;
@property(nonatomic) NSString *familyName;
@property(nonatomic) NSArray *sections;

@end
