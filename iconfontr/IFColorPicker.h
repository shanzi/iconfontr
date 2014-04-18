//
//  IFColorPickerView.h
//  iconfontr
//
//  Created by Chase Zhang on 4/18/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface IFColorPicker : NSControl

@property(nonatomic, readonly) NSColor *foregroundColor;
@property(nonatomic, readonly) NSColor *backgroundColor;
@property(nonatomic) NSInteger pickedIndex;

@end
