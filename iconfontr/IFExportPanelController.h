//
//  IFExportPanelController.h
//  iconfontr
//
//  Created by Chase Zhang on 4/26/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IFModelProtocol.h"

typedef enum
{
  IFSVGFileType=0,
  IFPNGFileType,
  IFJPEGFileType,
} IFExportFileType;

@interface IFExportPanelController : NSWindowController

@property(nonatomic) BOOL clipToBounds;
@property(nonatomic) BOOL transparency;

@property(nonatomic) BOOL clipEnabled;
@property(nonatomic) BOOL transparencyEnabled;
@property(nonatomic) BOOL sizeEnabled;
@property(nonatomic) BOOL showOnlySelected;

@property(nonatomic) NSColor *foregroundColor;
@property(nonatomic) NSColor *backgroundColor;
@property(nonatomic) NSInteger baseSize;
@property(nonatomic) NSInteger padding;

@property(nonatomic) NSInteger filetype;
@property(nonatomic) id<IFIconCollectionModel> contents;

@property(nonatomic, assign) IBOutlet NSOutlineView *selectionView;

+ (instancetype)shared;

- (void)showPanelFor:(NSWindow *)window;
- (IBAction)panelAction:(id)sender;

@end
