//
//  ConfigViewController.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-14.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ConfigViewController : UITableViewController <MBProgressHUDDelegate> {
    
    TimesheetAppDelegate *appDelegate;
    
    IBOutlet UITextField *txtEmployeeName;
    IBOutlet UITextField *txtEmailAddress;
    IBOutlet UITextField *txtCompanyName;
    IBOutlet UILabel *lblCompanyName;
    IBOutlet UILabel *lblSyncCode;
    
    IBOutlet UISwitch *switchLockDeviceUDID;
    IBOutlet UISwitch *switchLunchTime;
    IBOutlet UITableViewCell *lunchTimeCell;
    
    IBOutlet UIImageView *imgInternetStatus;
    IBOutlet UILabel *lblInternetStatus;
    IBOutlet UILabel *lblEnableLocation;
    IBOutlet UILabel *lblLocationDistance;
    
    NSMutableData *webData;
    
    MBProgressHUD *HUD;
}

-(IBAction)btnUpdateInfoClick:(id)sender;
-(IBAction)btnCheckConnectionClick;

- (void)checkNetworkStatus:(NSNotification *)notice;

@end
