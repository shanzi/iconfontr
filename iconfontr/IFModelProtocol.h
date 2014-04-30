//
//  IFIconModelProtocol.h
//  iconfontr
//
//  Created by Chase Zhang on 4/29/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFIconModel <NSObject>
@required
- (NSString *)name;
- (NSString *)unicode;
- (NSString *)pathString;
- (NSBezierPath *)bezierPath;
- (NSRect)bounds;
@optional
- (NSString *)CSSClassName;
- (NSString *)fullCSSClassString;
- (NSArray *)tags;
- (BOOL)selected;
- (void)setSelected:(BOOL)selected;
- (id)section;
- (id)collection;

@end

@protocol IFIconSectionModel <NSObject>
@required
- (NSString *)name;
- (NSArray *)icons;
@optional
- (NSArray *)selectedIcons;
- (id)collection;

@end

@protocol IFIconCollectionModel <NSObject>
@required
- (NSString *)name;
- (NSString *)familyName;
@optional
- (NSString *)weight;
- (CGFloat)unitPerEM;
- (NSRange)unicodeRange;
- (NSArray *)sections;


@end