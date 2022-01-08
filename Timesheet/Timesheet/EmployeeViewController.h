//
//  EmployeeViewController.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-04.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface EmployeeViewController : UIViewController  <MBProgressHUDDelegate> {
    
    TimesheetAppDelegate *appDelegate;
    
    IBOutlet UIButton *btnCreateEmployee;
    
    IBOutlet UITextField *txtEmployeeName;
    IBOutlet UITextField *txtEmailAddress;
    IBOutlet UITextField *txtSyncCode;
    
    NSMutableData *webData;
    
    MBProgressHUD *HUD;
}

- (IBAction)dismissSwipeDown:(id)sender;
- (IBAction)btnCreateEmployeeClick:(id)sender;

@end
