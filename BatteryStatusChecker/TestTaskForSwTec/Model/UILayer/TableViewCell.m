//
//  TableViewCell.m
//  TestTaskForSwTec
//
//  Created by Eugeny Ulyankin on 10/28/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import "TableViewCell.h"
#import "NSString+Extension.h"

@interface TableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateTitle;
@property (weak, nonatomic) IBOutlet UILabel *levelTitle;
@property (weak, nonatomic) IBOutlet UILabel *stateTitle;
@property (weak, nonatomic) IBOutlet UILabel *cellBatteryLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellBatteryStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellBatteryDateUpdatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellGpsPositionLabel;

@end

@implementation TableViewCell

#pragma mark - Initializers
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setLayoutMargins:UIEdgeInsetsZero];
    [self setSeparatorInset:UIEdgeInsetsZero];
    
    [self setVisibleActualBatteryInfo:NO];
    [self setVisibleGpsCoordinates:NO];
    
    [self.cellGpsPositionLabel setText:@""];
    [self.cellBatteryStateLabel setText:@""];
    [self.cellBatteryLevelLabel setText:@""];
    [self.cellBatteryDateUpdatedLabel setText:@""];
}

#pragma mark - External Methods
- (void)cellWithBatteryLevel:(CGFloat)level state:(UIDeviceBatteryState)state timeStamp:(CGFloat)timeStamp location:(CLLocation *)location
{
    [self.cellGpsPositionLabel setText:[NSString stringWithFormat:@"%f/%f", [location coordinate].latitude, [location coordinate].longitude]];
    [self.cellBatteryLevelLabel setText:[NSString stringWithFormat:@"%d%%", (int)level]];
    [self.cellBatteryStateLabel setText:[NSString batteryStateAsString:state]];
    [self.cellBatteryDateUpdatedLabel setText:[NSString humanFriendlyDateAsStringByTimeStamp:timeStamp]];
}

- (void)setVisibleActualBatteryInfo:(BOOL)enabled
{
    if (enabled)
    {
        [self.dateTitle setTextColor:[UIColor blackColor]];
        [self.stateTitle setTextColor:[UIColor blackColor]];
        [self.levelTitle setTextColor:[UIColor blackColor]];
        [self.cellGpsPositionLabel setTextColor:[UIColor blackColor]];
        [self.cellBatteryStateLabel setTextColor:[UIColor blackColor]];
        [self.cellBatteryLevelLabel setTextColor:[UIColor blackColor]];
        [self.cellBatteryDateUpdatedLabel setTextColor:[UIColor blackColor]];
    }
    else
    {
        [self.dateTitle setTextColor:[UIColor clearColor]];
        [self.stateTitle setTextColor:[UIColor clearColor]];
        [self.levelTitle setTextColor:[UIColor clearColor]];
        [self.cellGpsPositionLabel setTextColor:[UIColor clearColor]];
        [self.cellBatteryStateLabel setTextColor:[UIColor clearColor]];
        [self.cellBatteryLevelLabel setTextColor:[UIColor clearColor]];
        [self.cellBatteryDateUpdatedLabel setTextColor:[UIColor clearColor]];
    }
}

- (void)setVisibleGpsCoordinates:(BOOL)enabled
{
    CLLocation *location = [[LocationManager sharedInstance] getLastLocation];
    if  ([location coordinate].latitude != 0 && [location coordinate].longitude != 0)
    {
        if (enabled)
        {
            [self.cellGpsPositionLabel setTextColor:[UIColor blackColor]];
        }
        else
        {
            [self.cellGpsPositionLabel setTextColor:[UIColor clearColor]];
        }
    }
    else
    {
        [self.cellGpsPositionLabel setTextColor:[UIColor clearColor]];
    }
}

@end
