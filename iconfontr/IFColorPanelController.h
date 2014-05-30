//
//  IFColorPanelController.h
//  iconfontr
//
//  Created by Chase Zhang on 5/30/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IMColorPalette;

@interface IFColorPanelController : NSViewController

@property (assign) IBOutlet IMColorPalette *colorPalette;

- (IBAction)changeColor:(id)sender;

@end
