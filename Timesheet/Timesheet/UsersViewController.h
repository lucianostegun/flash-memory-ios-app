//
//  UsersViewController.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-10.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "Employee.h"
 
@interface UsersViewController : UITableViewController<EGORefreshTableHeaderDelegate> {
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
    
    TimesheetAppDelegate *appDelegate;
    IBOutlet UIBarButtonItem *btnEdit;
    Employee *employee;
}

@property (nonatomic, retain) NSMutableArray *employeeList;

- (void)updateTimehseetList;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
- (IBAction)btnEditClick:(id)sender;

@end
