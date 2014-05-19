//
//  IFIconImportWindowController.m
//  iconfontr
//
//  Created by Chase Zhang on 5/19/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFIconImporterWindowController.h"
#import "IFDropFileButton.h"

@interface IFIconImporterWindowController ()

@end

@implementation IFIconImporterWindowController

- (NSString *)windowNibName
{
  return @"IFIconImporterWindowController";
}

- (void)loadWindow
{
  [super loadWindow];
  self.window.backgroundColor = [NSColor whiteColor];
  [self.window setLevel:NSFloatingWindowLevel];
}

- (void)droppedFile:(id)sender
{
  NSURL *url = [(IFDropFileButton *)sender fileURL];
  if (url) {
    [self extractFileContentsFromURL:url];
  }
  else {
    NSOpenPanel *openpanel = [NSOpenPanel openPanel];
    [openpanel setAllowedFileTypes:@[@"zip"]];
    if ([openpanel runModal] == NSOKButton) [self extractFileContentsFromURL:url];
  }
}

- (void)extractFileContentsFromURL:(NSURL *)url
{
  NSLog(@"%@", url.path);
}

@end
