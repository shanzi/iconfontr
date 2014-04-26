//
//  IFExportPanelController.m
//  iconfontr
//
//  Created by Chase Zhang on 4/26/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFExportPanelController.h"

static IFExportPanelController *shared;

@interface IFExportPanelController ()

@end

@implementation IFExportPanelController

+ (instancetype)shared
{
  if (shared==nil){
    shared = [[IFExportPanelController alloc] init];
  }
  return shared;
}

- (id)init
{
  self = [super init];
  if (self) {
    self.clipToBounds = YES;
    self.transparency = YES;
    self.backgroundColor = [NSColor whiteColor];
    self.baseSize = 64;
    self.padding = 0;
    self.filetype = IFSVGFileType;
  }
  return self;
}

- (NSString *)windowNibName
{
  return @"IFExportPanel";
}

- (void)showPanelFor:(NSWindow *)window
{
  if(self.window==nil) [self loadWindow];
  
  [NSApp beginSheet:self.window
     modalForWindow:window
      modalDelegate:self
     didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
        contextInfo:nil];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
  [sheet orderOut:nil];
}

- (void)setFiletype:(NSInteger)filetype
{
  _filetype = filetype;
  switch (filetype) {
    case IFJPEGFileType:
      self.clipEnabled = YES;
      self.transparencyEnabled = NO;
      self.transparency = NO;
      self.sizeEnabled = YES;
      break;
    case IFPNGFileType:
    case IFTIFFFileType:
      self.clipEnabled = YES;
      self.transparencyEnabled = YES;
      self.sizeEnabled = YES;
      break;
    case IFSVGFileType:
      self.clipEnabled = NO;
      self.clipToBounds = YES;
      self.transparencyEnabled = YES;
      self.sizeEnabled = NO;
      break;
  }
}

- (void)panelAction:(id)sender
{
  if ([sender tag]==1) {
    [NSApp endSheet:self.window
         returnCode:NSFileHandlingPanelOKButton];
  }
  else {
    [NSApp endSheet:self.window
         returnCode:NSFileHandlingPanelCancelButton];
  }
}

@end
