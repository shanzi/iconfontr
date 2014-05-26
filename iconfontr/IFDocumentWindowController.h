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

@interface IFDocumentWindowController : NSWindowController

@property(assign) IBOutlet IFMagnifyCollectionView *collectionView;
@property(nonatomic, weak) id<IFIconCollectionModel> content;
@property(nonatomic) NSColor *color;

- (IBAction)exportSelection:(id)sender;
- (IBAction)toolbarAction:(id)sender;

@end
