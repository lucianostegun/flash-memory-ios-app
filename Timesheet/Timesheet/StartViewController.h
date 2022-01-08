//
//  StartViewController.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-03.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimesheetAppDelegate.h"

@interface StartViewController : UIViewController {
    
    TimesheetAppDelegate *appDelegate;
    IBOutlet UIButton *btnEmployeeMode;
    IBOutlet UIButton *btnCompanyMode;
}

@end
