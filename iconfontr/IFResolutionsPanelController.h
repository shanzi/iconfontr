//
//  IFResolutionsPanelController.h
//  iconfontr
//
//  Created by Chase Zhang on 5/30/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFResolutionsPanelController : NSViewController

@property(nonatomic) IBOutlet NSTableView *tableView;
@property(nonatomic) IBOutlet NSButton *deleteButton;

- (IBAction)listAction:(id)sender;
- (IBAction)presetAction:(id)sender;
- (IBAction)resolutionAction:(id)sender;

@end
