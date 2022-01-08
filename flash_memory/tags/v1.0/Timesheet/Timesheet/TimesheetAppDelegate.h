//
//  TimesheetAppDelegate.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-03.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"

@interface TimesheetAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate> {
    
    Reachability* internetReachable;
    Reachability* hostReachable;
    
    CLLocationManager *locationManager;
    CLLocation *myLocation;
    
    NSString *appUrl;
    
    UIBackgroundTaskIdentifier *bgTask;
    NSTimer *timer;
    UILocalNotification *localNotification;
    int locationCount;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readwrite) NSUserDefaults *userDefaults;
@property (nonatomic, readonly) BOOL internetActive;
@property (nonatomic, readonly) BOOL wifiConnection;
@property (nonatomic, readonly) BOOL hostActive;
@property (nonatomic, readonly) BOOL checkedHost;
@property (nonatomic, readwrite) BOOL pendingSync;
@property (nonatomic, readwrite) int companyId;
@property (nonatomic, readwrite) int employeeId;
@property (nonatomic, readwrite) BOOL isAdmin;
@property (nonatomic, readwrite) BOOL lockDeviceUDID;
@property (nonatomic, readwrite) BOOL lunchTime;
@property (nonatomic, readwrite) NSString *employeeName;
@property (nonatomic, readwrite) NSString *companyName;
@property (nonatomic, readwrite) NSString *emailAddress;
@property (nonatomic, readwrite) NSString *syncCode;
@property (nonatomic, readonly) float appVersion;
@property (nonatomic, readwrite) BOOL logged; // Armazena Sim caso ao abrir o app o usuário já esteja logado
@property (nonatomic, readwrite) BOOL versionChecked; // Verifica se a versão já foi checada e alertada
@property (nonatomic, readwrite) BOOL enableLocation;
@property (nonatomic, readwrite) int locationDistanceIndex;

@property (nonatomic, readwrite) NSString *entranceDateTime;
@property (nonatomic, readwrite) NSString *exitDateTime;
@property (nonatomic, readwrite) NSString *lunchStartDateTime;
@property (nonatomic, readwrite) NSString *lunchStopDateTime;
@property (nonatomic, readwrite) NSString *lastExitDateTime;
@property (nonatomic, readwrite) NSString *lastEntranceDateTime;

@property (nonatomic, readwrite) NSString *lastLocationNotification;

@property (nonatomic, readonly, retain) NSString *deviceUDID;
@property (nonatomic, readonly, retain) NSMutableDictionary *dictionary;
@property (nonatomic, retain) NSString *workplaceLocation;
@property (nonatomic, retain) NSString *workplaceAddress;

- (void)switchStoryboard:(NSString *)storyboardName;
- (void)checkNetworkStatus:(NSNotification *)notice;
- (void)checkNetwork;
- (void)showAlert:(NSString *)title message:(NSString *)message;
- (BOOL)updateUserInfo:(NSMutableDictionary *)dictionary;
- (BOOL)updateUserInfo;
- (void)logout;
- (int)radius;
- (float)latitude;
- (float)longitude;
- (int)locationDistanceIndex;
@end
