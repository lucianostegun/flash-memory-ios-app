//
//  HistoryViewController.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-05.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShiftCell.h"
#import "Shift.h"
#import "EGORefreshTableHeaderView.h"

@interface HistoryViewController : UITableViewController <EGORefreshTableHeaderDelegate> {
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
    
    Shift *currentShift;
    TimesheetAppDelegate *appDelegate;
}

@property (nonatomic, readwrite) int employeeId;
@property (nonatomic, retain) NSMutableArray *shiftList;

- (void)updateShiftList;
- (void)updateShiftList:(BOOL)force;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
