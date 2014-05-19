//
//  IFDropFileButton.m
//  iconfontr
//
//  Created by Chase Zhang on 5/19/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFDropFileButton.h"


@implementation IFDropFileButton

- (void)awakeFromNib
{
  [super awakeFromNib];
  [self registerForDraggedTypes:@[NSURLPboardType]];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
  NSPasteboard *pboard = [sender draggingPasteboard];
  NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
  
  if ([[pboard types] containsObject:NSURLPboardType]) {
    if (sourceDragMask & NSDragOperationCopy) {
      NSURL *url = [NSURL URLFromPasteboard:pboard];
      if ([[url.path pathExtension] isEqualToString:@"zip"]) {
        [self.cell setHighlighted:YES];
        return NSDragOperationCopy;
      }
    }
  }
  return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
  [self.cell setHighlighted:NO];
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
  [self.cell setHighlighted:NO];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
  NSPasteboard *pboard = [sender draggingPasteboard];
  NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
  
  if ([[pboard types] containsObject:NSURLPboardType]) {
    if (sourceDragMask & NSDragOperationCopy) {
      NSURL *url = [NSURL URLFromPasteboard:pboard];
      if ([[url.path pathExtension] isEqualToString:@"zip"]) {
        _fileURL = url;
        return YES;
      }
    }
  }
  return NO;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
  [self sendAction:self.action to:self.target];
  return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
  _fileURL = nil;
}

@end
