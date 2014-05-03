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
} IFExportFileType;

@interface IFExportPanelController : NSWindowController

@property(nonatomic) BOOL showOnlySelected;
@property(nonatomic) BOOL resolutionEnabled;
@property(nonatomic) BOOL removeResolutionEnabled;

@property(nonatomic) NSColor *color;
@property(nonatomic) NSInteger baseSize;
@property(nonatomic) NSInteger padding;
@property(nonatomic) NSArray *resolutions;

@property(nonatomic) NSInteger resolutionPresetTag;
@property(nonatomic) NSInteger filetype;
@property(nonatomic) id<IFIconCollectionModel> contents;

@property(nonatomic, assign) IBOutlet NSOutlineView *selectionView;
@property(nonatomic, assign) IBOutlet NSTableView *resolutionsView;

+ (instancetype)shared;

- (void)showPanelFor:(NSWindow *)window;
- (IBAction)panelAction:(id)sender;
- (IBAction)editResolution:(id)sender;

@end
