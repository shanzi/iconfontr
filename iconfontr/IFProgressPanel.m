//
//  IFProgressPanel.m
//  iconfontr
//
//  Created by Chase Zhang on 5/3/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "IFProgressPanel.h"

@interface IFProgressPanel ()
{
  NSTextField *_titleField;
  NSProgressIndicator *_progressIndicator;
  NSButton *_cancelButton;
}

@end

@implementation IFProgressPanel

- (id)init
{
  self = [super init];
  if (self) {
    [[self contentView] setFlipped:YES];
    [self setFrame:NSMakeRect(0, 0, 320, 140) display:NO];
    [self setMaxSize:self.frame.size];
    [self setMinSize:self.frame.size];
    
    _titleField = [[NSTextField alloc] initWithFrame:NSMakeRect(17, 17, 320-17*2, 17)];
    [_titleField setDrawsBackground:NO];
    [_titleField setEditable:NO];
    [_titleField setSelectable:NO];
    [_titleField setBordered:NO];
    [_titleField setStringValue:@"Processing"];
    
    _progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(17, 45, 320-17*2, 22)];
    [_progressIndicator setMinValue:0];
    [_progressIndicator setMaxValue:100];
    [_progressIndicator setIndeterminate:NO];
    
    _cancelButton = [[NSButton alloc] initWithFrame:NSMakeRect(320-12-100, 80, 100, 24)];
    [_cancelButton setBezelStyle:NSRoundedBezelStyle];
    [_cancelButton setTitle:@"Cancel"];
    _cancelButton.target = self;
    _cancelButton.action = @selector(cancelOperation:);
    [_cancelButton setFocusRingType:NSFocusRingTypeDefault];
    [self setDefaultButtonCell:[_cancelButton cell]];
    
    [[self contentView] addSubview:_titleField];
    [[self contentView] addSubview:_progressIndicator];
    [[self contentView] addSubview:_cancelButton];
  }
  return self;
}

- (NSString *)title
{
  return _titleField.stringValue;
}

- (void)setTitle:(NSString *)title
{
  _titleField.stringValue = title;
}

- (NSString *)cancelButtonTitle
{
  return _cancelButton.title;
}

- (void)setCancelButtonTitle:(NSString *)cancelButtonTitle
{
  _cancelButton.title = cancelButtonTitle;
}

- (BOOL)cancelEnabled
{
  return _cancelButton.isEnabled;
}

- (void)setCancelEnabled:(BOOL)cancelEnabled
{
  [_cancelButton setEnabled:cancelEnabled];
}

- (double)value
{
  return [_progressIndicator doubleValue];
}

- (void)setValue:(double)value
{
  [_progressIndicator setDoubleValue:value];
}

- (void)cancelOperation:(id)sender
{
  _hasCanceled = YES;
}

@end
