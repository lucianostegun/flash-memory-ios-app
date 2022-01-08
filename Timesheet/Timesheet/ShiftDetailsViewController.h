//
//  ShiftDetailsViewController.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-15.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShiftDetailsCell.h"
#import "Shift.h"

@interface ShiftDetailsViewController : UITableViewController {
    
    TimesheetAppDelegate *appDelegate;
}

@property(nonatomic, retain) Shift *shift;

@end
