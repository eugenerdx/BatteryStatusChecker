//
//  CustomHeaderFooterView.m
//  TestTaskForSwTec
//
//  Created by Eugeny on 11/5/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import "CustomHeaderFooterView.h"
#import "DeleteAlertTableViewCell.h"
#import "global.h"

@interface CustomHeaderFooterView ()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (assign, nonatomic) BOOL serviceButtonEnabled;
@property (strong, nonatomic) NSString *title;

@end
@implementation CustomHeaderFooterView


- (void)headerFooterViewWithTitle:(NSString *)title andServiceButtonEnabled:(BOOL)enabled
{
    [self setServiceButtonEnabled:enabled];
    [self setTitle:title];
    [self loadNib];
}

- (IBAction)onServiceButtonClicked:(id)sender
{
    [self.delegate onServiceButtonClicked:sender];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self loadNib];
    [self setServiceButtonEnabled:NO];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self loadNib];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self loadNib];
    }
    return self;
}

- (void)serviceButtonEnabled:(BOOL)serviceButtonEnabled
{
    _serviceButtonEnabled = serviceButtonEnabled;
}


- (void)loadNib
{
    [[[NSBundle mainBundle] loadNibNamed:@"CustomHeaderFooterView"
                                   owner:self
                                 options:nil] objectAtIndex:0];
    
    [self.headerFooterTextLabel setText:self.title];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       if (self.serviceButtonEnabled == YES)
                       {
                           [self.cleanSettingsButton setHidden:NO];
                           [self.cleanSettingsButton setUserInteractionEnabled:YES];
                           [self.cleanSettingsButton.titleLabel setTextColor:cLightBlueColor];
                       }
                       else
                       {
                           [self.cleanSettingsButton setHidden:YES];
                           [self.cleanSettingsButton setUserInteractionEnabled:NO];
                           [self.cleanSettingsButton.titleLabel setTextColor:cClearColor];
                       }
                   });
    
    [self addSubview:self.view];
    [self.view setFrame:self.bounds];
    [self.view setBackgroundColor:cTableViewSectionHeaderBackgroundColor];
}
@end
