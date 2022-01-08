//
//  CompanyViewController.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-04.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimesheetAppDelegate.h"
#import "MBProgressHUD.h"

@interface CompanyViewController : UIViewController  <MBProgressHUDDelegate> {
    
    TimesheetAppDelegate *appDelegate;
    IBOutlet UIButton *btnCreateCompany;
    
    IBOutlet UITextView *lblSyncCode;
    IBOutlet UITextView *lblAdminCode;
    
    IBOutlet UITextField *txtCompanyName;
    IBOutlet UITextField *txtPersonName;
    IBOutlet UITextField *txtEmailAddress;
    
    IBOutlet UISwipeGestureRecognizer *swipeRightCompany;
    IBOutlet UISwipeGestureRecognizer *swipeDownCompany;
    
    NSMutableData *webData;
    
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) UITextView *lblSyncCode;
@property (nonatomic, retain) UITextView *lblAdminCode;
@property (nonatomic, retain) NSString *syncCode;
@property (nonatomic, retain) NSString *adminCode;

- (IBAction)dismissSwipeDown:(id)sender;
- (IBAction)btnCreateCompanyClick:(id)sender;

@end
