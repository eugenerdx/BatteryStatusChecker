//
//  AlertViewControllerWithTableView.m
//  Utils
//
//  Created by Eugeny Ulyankin on 08/08/15.
//  Copyright © 2015 eugenerdx. All rights reserved.
//

#import "DeleteInfoAlertController.h"
#import "BatteryInfoManager.h"
#import "DatabaseWrapper.h"
#import "global.h"

@interface DeleteAlertViewController ()

@property (weak, nonatomic) IBOutlet UILabel *tableViewCellLabel;
@property (strong, nonatomic) NSMutableArray *tableViewCells;
@property (strong, nonatomic) UITableView *alertTableView;
@property (strong, nonatomic) UIViewController *controller;

@end

@implementation DeleteAlertViewController

#pragma mark - UIViewLifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableViewCells = [[NSMutableArray alloc] init];
    self.tableViewCells = [@[@"First 10 items", @"Last 10 items", @"Last minute", @"Last 5 Minutes", @"Delete all"] mutableCopy];
    
    self.alertTableView = [[UITableView alloc]initWithFrame:CGRectZero];
    [self.alertTableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    [self.alertTableView setDelegate:self];
    [self.alertTableView setDataSource:self];
    
    self.controller = [[UIViewController alloc]init];
    [self.controller setPreferredContentSize:CGSizeZero];
    [self.controller.view addSubview:self.alertTableView];
    [self.controller.view bringSubviewToFront:self.alertTableView];
    [self setValue:self.controller forKey:@"contentViewController"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){}];
    [self addAction:cancelAction];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect newRect = CGRectMake(.0f, .0f, self.controller.view.bounds.size.width, kDeleteTableViewCellHeight * self.tableViewCells.count);
    [self.controller setPreferredContentSize:newRect.size];
    [self.alertTableView setFrame:newRect];
}

#pragma mark - UITableViewDataSource
- (DeleteAlertTableViewCell *)selectableDeviceCellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    DeleteAlertTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"DeleteAlertTableViewCell"
                                                                    owner:self
                                                                  options:nil] objectAtIndex:0];
    if ([[BatteryInfoManager sharedInstance] totalBatteryInfo].count == 0)
    {
        [cell setEnabled:NO];
    }
    
    [cell setTitleText:[[self tableViewCells]objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self tableViewCells].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self selectableDeviceCellForTableView:tableView indexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kDeleteTableViewCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    switch (indexPath.row)
    {
        case 0:
            [[BatteryInfoManager sharedInstance] deleteNitems:10 withOptions:EditOptionsDeleteFirstInfo];
            break;
        case 1:
            [[BatteryInfoManager sharedInstance] deleteNitems:10 withOptions:EditOptionsDeleteLastInfo];
            break;
        case 2:
            [[BatteryInfoManager sharedInstance] deleteBatteryInfoSomeMinutesAgo:kOneMinute withOptions:EditOptionsDeleteSomeMinutesAgo];
            break;
        case 3:
            [[BatteryInfoManager sharedInstance] deleteBatteryInfoSomeMinutesAgo:kFiveMinutes withOptions:EditOptionsDeleteSomeMinutesAgo];
        case 4:
            [[BatteryInfoManager sharedInstance] deleteNitems:0 withOptions:EditOptionsDeleteAll];
            break;
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self dismissViewControllerAnimated:YES completion:nil];
                   });
}
@end
