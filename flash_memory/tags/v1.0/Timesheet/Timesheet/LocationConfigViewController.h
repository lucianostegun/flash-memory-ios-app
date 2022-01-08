//
//  LocationConfigViewController.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-17.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LocationConfigViewController : UITableViewController <CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
    
    TimesheetAppDelegate *appDelegate;
    
    IBOutlet UISwitch *switchLocation;
    IBOutlet UIBarButtonItem *btnRedefineLocation;
    int distanceOptionIndex;
    
    IBOutlet UILabel *lblLatitude;
    IBOutlet UILabel *lblLongitude;
    
    CLLocationManager *locationManager;
    CLLocation *myLocation;
}

- (IBAction)changeSwitchLocation:(id)sender;
- (IBAction)btnRedefineLocationClick:(id)sender;

@end
