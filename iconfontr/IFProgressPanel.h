//
//  IFProgressPanel.h
//  iconfontr
//
//  Created by Chase Zhang on 5/3/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFProgressPanel : NSPanel

@property(nonatomic) double value;
@property(nonatomic) NSString *title;
@property(nonatomic) NSString *cancelButtonTitle;
@property(nonatomic) BOOL cancelEnabled;
@property(nonatomic, readonly) BOOL hasCanceled;

@end
