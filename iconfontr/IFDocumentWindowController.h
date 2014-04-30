//
//  IFDocumentWindowController.h
//  iconfontr
//
//  Created by Chase Zhang on 4/15/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IFModelProtocol.h"
@class IFMagnifyCollectionView;
@class IFColorPicker;

@interface IFDocumentWindowController : NSWindowController

@property(assign) IBOutlet IFMagnifyCollectionView *collectionView;
@property(assign) IBOutlet IFColorPicker *colorPicker;
@property(nonatomic, weak) id<IFIconCollectionModel> content;

- (IBAction)changeColor:(id)sender;
- (IBAction)exportSelection:(id)sender;

@end
