//
//  SelectablePhonesCell.m
//  Utils
//
//  Created by Eugeny Ulyankin on 08/08/15.
//  Copyright © 2015 eugenerdx. All rights reserved.
//

#import "DeleteAlertTableViewCell.h"
#import "global.h"

@interface DeleteAlertTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DeleteAlertTableViewCell

#pragma mark - Initializers
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setLayoutMargins:UIEdgeInsetsZero];
    [self setSeparatorInset:UIEdgeInsetsZero];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _titleLabel.textColor = cLightBlueColor;
    }
    return self;
}

#pragma mark - External Methods
- (void)setTitleText:(NSString *)titleText
{
    [self.titleLabel setText:titleText];
}

- (void)setEnabled:(BOOL)enabled;
{
    if (!enabled)
    {
        [self setUserInteractionEnabled:NO];
        [self.titleLabel setTextColor:cDisabledButtonTitleColor];
    }
    else
    {
        [self setUserInteractionEnabled:YES];
        [self.titleLabel setTextColor:cLightBlueColor];
    }
}
@end
