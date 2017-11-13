//
//  ViewController.m
//  TestTaskForSwTec
//
//  Created by Eugeny Ulyankin on 10/28/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import "ViewController.h"
#import "DeleteInfoAlertController.h"
#import "BatteryInfo.h"
#import "TableViewCell.h"
#import "global.h"
#import "LocationManager.h"
#import "NSString+Extension.h"
#import "CustomHeaderFooterView.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, CustomHeaderFooterViewDelegate>

@property (assign, nonatomic) BOOL isLocationDenied;
@property (assign, nonatomic) BOOL isStarted;
@property (strong, nonatomic) UIBarButtonItem *leftBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *rightBarButtonItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *statisticsViewBatteryLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *statisticsViewBatteryStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *statisticsViewDateAndTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statisticViewLatitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statisticsViewLongtitudeLabel;
@property (weak, nonatomic) IBOutlet CustomHeaderFooterView *gpsHeaderFooterView;
@property (strong, nonatomic) IBOutlet CustomHeaderFooterView *headerFooterView;
@property (strong, nonatomic) CustomHeaderFooterView *tableViewHeaderView;
@property (strong, nonatomic) BatteryInfo *lastBatteryInfo;
@property (strong, nonatomic) NSMutableArray *tableViewInfoArray;

@end

@implementation ViewController 

#pragma UINavigationBar settings

#pragma mark - UIViewController lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"TableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomHeaderFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"CustomHeaderFooterView"];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAuthorizationStatusDeniedAlert)
                                                 name:kCoreLocationAuthorizationStatusDenied
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timeRemain:)
                                                 name:kTimeLeft
                                               object:nil];
    
    [self.statisticViewLatitudeLabel setText:@""];
    [self.statisticsViewLongtitudeLabel setText:@""];
    [self.statisticsViewDateAndTimeLabel setText:@""];
    [self.statisticsViewBatteryLevelLabel setText:@""];
    [self.statisticsViewBatteryStateLabel setText:@""];
    
    [self setupNavigationBar];
    
    [self.headerFooterView headerFooterViewWithTitle:@"Last battery information" andServiceButtonEnabled:NO];
    [self.gpsHeaderFooterView headerFooterViewWithTitle:@"GPS position" andServiceButtonEnabled:NO];
    
    [[LocationManager sharedInstance] requestPermissions];
    [[BatteryInfoManager sharedInstance] addTotalBatteryInfoObserver:self];
    [[BatteryInfoManager sharedInstance] loadHistory];
    [[BatteryInfoManager sharedInstance] timerHandle];
    
    self.lastBatteryInfo = [self.tableViewInfoArray lastObject];
}

- (void)dealloc
{
    [[BatteryInfoManager sharedInstance] stopBatteryInfoMonitoring];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigationBar
{
    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Stop"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(onRightBarButtonItem:)];
    [self.rightBarButtonItem setTintColor:cLightBlueColor];
    [self.rightBarButtonItem setEnabled:NO];
    
    
    [self.navigationItem setRightBarButtonItem:self.rightBarButtonItem];
    [self.navigationItem setTitle:@"Battery State Checker"];
    
    self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(onLeftBarButtonItem:)];
    [self.leftBarButtonItem setTintColor:cLightBlueColor];
    [self.navigationItem setLeftBarButtonItem:self.leftBarButtonItem];
    
    [self setIsStarted:NO];
}


#pragma mark - UITableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self tableViewInfoArray].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
    BatteryInfo *batteryInfo = [self.tableViewInfoArray objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0)
    {
        [cell setHidden:YES];
    }
    
    [cell setVisibleActualBatteryInfo:YES];
    
    if ((batteryInfo.location.coordinate.latitude != 0 && batteryInfo.location.coordinate.longitude != 0))
    {
        [cell setVisibleGpsCoordinates:YES];
    }
    else
    {
        [cell setVisibleGpsCoordinates:NO];
    }
    [cell cellWithBatteryLevel:batteryInfo.level state:batteryInfo.state timeStamp:batteryInfo.timeStamp location:batteryInfo.location];
    return cell;
}

#pragma mark - UITableView delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            self.tableViewHeaderView = [[CustomHeaderFooterView alloc] initWithFrame:CGRectZero];
            [self.tableViewHeaderView headerFooterViewWithTitle:@"History" andServiceButtonEnabled:YES];
            [self.tableViewHeaderView setDelegate:self];
            return self.tableViewHeaderView;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle)
    {
        case UITableViewCellEditingStyleDelete:
        {
            BatteryInfo *info = [self.tableViewInfoArray objectAtIndex:indexPath.row];
            [[BatteryInfoManager sharedInstance] deleteBatteryInfo:info];
            
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView endUpdates];
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 0; //Make first cell hidden, because we are shown this info in main battery information view
    return kMainTableViewCellHeight;
}

#pragma mark - Notification handlers
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([change objectForKey:@"new"] && [[object valueForKeyPath:@"_totalBatteryInfo"] isKindOfClass:[NSArray class]])
    {
        NSArray *historyArray = [object valueForKeyPath:@"_totalBatteryInfo"];
        [self setTableViewInfoArray:[[[historyArray reverseObjectEnumerator] allObjects] mutableCopy]];
        
        [self setLastBatteryInfo:[historyArray lastObject]];
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self.statisticViewLatitudeLabel setText:[NSString stringWithFormat:@"%f", self.lastBatteryInfo.location.coordinate.latitude]];
                           [self.statisticsViewLongtitudeLabel setText:[NSString stringWithFormat:@"%f", self.lastBatteryInfo.location.coordinate.longitude]];
                           [self.statisticsViewDateAndTimeLabel setText:[NSString humanFriendlyDateAsStringByTimeStamp:self.lastBatteryInfo.timeStamp]];
                           [self.statisticsViewBatteryStateLabel setText:[NSString batteryStateAsString:self.lastBatteryInfo.state]];
                           [self.statisticsViewBatteryLevelLabel setText:[NSString stringWithFormat:@"%@%%", [NSString stringWithFormat:@"%ld", (long)self.lastBatteryInfo.level]]];
                           [self.tableView reloadData];
                       });
    }
    else if ([change objectForKey:@"old"])
    {
        
    }
    else if ([change objectForKey:@"kind"])
    {
        
    }
}

- (void)timeRemain:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSNumber class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self isStarted])
            {
                NSNumber *timeRemain = [notification object];
                [self.leftBarButtonItem setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)timeRemain.unsignedIntegerValue]];
                [self.leftBarButtonItem setEnabled:NO];
                [self.rightBarButtonItem setEnabled:YES];
            }
            else
            {
                [self.rightBarButtonItem setEnabled:NO];
            }
        });
    }
}
    
- (void)showAuthorizationStatusDeniedAlert
{
    [self setIsLocationDenied:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       UIAlertController *alert = [UIAlertController
                                                   alertControllerWithTitle:@"Error"
                                                   message:@"Location services are disabled. The app can't continues working on the background more than several minutes"
                                                   preferredStyle:UIAlertControllerStyleAlert];
                       
                       UIAlertAction *okButton = [UIAlertAction
                                                  actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleCancel
                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                  }];
                       [alert addAction:okButton];
                       
                       [self presentViewController:alert animated:YES completion:nil];
                   });
}

- (IBAction)onServiceButtonClicked:(id)sender
{
    DeleteAlertViewController *alert = [DeleteAlertViewController alertControllerWithTitle:@"Choose your delete options"
                                                                                   message:@"Delete battery information for:"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:^{}];
}

- (void)onRightBarButtonItem:(id)sender
{
    [[LocationManager sharedInstance] stopLocationUpdates];
    [[BatteryInfoManager sharedInstance] stopBatteryInfoMonitoring];
    
    [self.leftBarButtonItem setTitle:@"Start"];
    [self.leftBarButtonItem setEnabled:YES];
    [self.rightBarButtonItem setEnabled:NO];
    [self setIsStarted:NO];
}

- (void)onLeftBarButtonItem:(id)sender
{
    [[BatteryInfoManager sharedInstance] timerHandle];
    
    if ([self isStarted] == NO)
    {
        [[LocationManager sharedInstance] startLocationUpdates];
        [[BatteryInfoManager sharedInstance] startBatteryInfoMonitoring];
        
        [self.rightBarButtonItem setEnabled:YES];
        [self setIsStarted:YES];
    }
}
@end
