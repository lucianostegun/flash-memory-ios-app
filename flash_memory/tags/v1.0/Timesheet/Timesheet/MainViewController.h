//
//  MainViewController.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-10.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UITabBarController {
    TimesheetAppDelegate *appDelegate;
}

- (void)switchStoryboard;

@end
