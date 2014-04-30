//
//  IFGlyphView.h
//  iconfontr
//
//  Created by Chase Zhang on 4/12/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <JNWCollectionView.h>
#import "IFModelProtocol.h"

@interface IFCollectionGlyphCell : JNWCollectionViewCell

@property(nonatomic) id<IFIconModel> content;
@property(nonatomic) NSColor *color;

@end
