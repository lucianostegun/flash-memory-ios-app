//
//  ControlViewController.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-03.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimesheetAppDelegate.h"

@interface ControlViewController : UIViewController <UIScrollViewDelegate> {
    
    IBOutlet UILabel *lblCurrentWeekday;
    IBOutlet UILabel *lblCurrentDate;
    IBOutlet UILabel *lblCurrentTime;
    TimesheetAppDelegate *appDelegate;
    
    IBOutlet UIImageView *imgSyncStatus;

    IBOutlet UILabel *lblSyncStatus;
    IBOutlet UILabel *lblLabel1;
    IBOutlet UILabel *lblLabel2;
    IBOutlet UILabel *lblLabel3;
    IBOutlet UILabel *lblLabel4;
    IBOutlet UILabel *lblValue1;
    IBOutlet UILabel *lblValue2;
    IBOutlet UILabel *lblValue3;
    IBOutlet UILabel *lblValue4;
    
    IBOutlet UIButton *btnRegister;
    
    NSMutableData *webData;
    
    NSString *appUrl;
    
}

-(IBAction)btnRegisterClick:(id)sender;
-(void)updateCurrentTime;

@end
