//
//  TimesheetAppDelegate.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-03.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "TimesheetAppDelegate.h"
#import "Reachability.h"
#import "Constants.h"

@implementation TimesheetAppDelegate
@synthesize internetActive;
@synthesize wifiConnection; 
@synthesize hostActive;
@synthesize checkedHost;
@synthesize entranceDateTime;
@synthesize exitDateTime;
@synthesize lunchStartDateTime;
@synthesize lunchStopDateTime;
@synthesize lastExitDateTime;
@synthesize lastEntranceDateTime;
@synthesize pendingSync;
@synthesize deviceUDID;
@synthesize syncCode;
@synthesize userDefaults;
@synthesize appVersion;
@synthesize logged;
@synthesize companyName;
@synthesize employeeName;
@synthesize emailAddress;
@synthesize isAdmin;
@synthesize lockDeviceUDID;
@synthesize lunchTime;
@synthesize dictionary;
@synthesize versionChecked;
@synthesize enableLocation;
@synthesize locationDistanceIndex;
@synthesize workplaceLocation;
@synthesize workplaceAddress;
@synthesize lastLocationNotification;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    checkedHost    = NO;
    versionChecked = NO;
    enableLocation = NO;
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    deviceUDID   = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    appVersion   = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
    
    entranceDateTime      = @"";
    exitDateTime          = @"";
    lunchStartDateTime    = @"";
    lunchStopDateTime     = @"";
    lastEntranceDateTime  = @"";
    lastExitDateTime      = @"";
    pendingSync           = NO;
    locationDistanceIndex = 0;
    workplaceLocation     = @"0,0";
    workplaceAddress      = @"";

    lastLocationNotification = @"";
    
    dictionary = [userDefaults objectForKey:@"userInfo"];
    syncCode   = [dictionary objectForKey:kSyncCodeKey];
    
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
//    [self logout]; // Descomentar para limpar as configurações
    
    if( syncCode != NULL ){
        
        entranceDateTime      = [dictionary objectForKey: kEntranceDateTimeKey];
        exitDateTime          = [dictionary objectForKey: kExitDateTimeKey];
        lunchStartDateTime    = [dictionary objectForKey: kLunchStartDateTimeKey];
        lunchStopDateTime     = [dictionary objectForKey: kLunchStopDateTimeKey];
        lastEntranceDateTime  = [dictionary objectForKey: kLastEntranceDateTimeKey];
        lastExitDateTime      = [dictionary objectForKey: kLastExitDateTimeKey];
        pendingSync           = [[dictionary objectForKey: kPendingSyncKey] boolValue];
        enableLocation        = [[dictionary objectForKey: kEnableLocationKey] boolValue];
        locationDistanceIndex = [[dictionary objectForKey: kLocationDistanceIndexKey] intValue];
        workplaceLocation     = [dictionary objectForKey: kWorkplaceLocationKey];
        workplaceAddress      = [dictionary objectForKey: kWorkplaceAddressKey];
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController* initialView = [storyboard instantiateViewControllerWithIdentifier:@"mainTabBarVC"];
        
        [self.window setRootViewController:initialView];
    }
    
    [self updateUserInfo];
    
    // Override point for customization after application launch.
    return YES;
}

-(void)switchStoryboard:(NSString *)storyboardName {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController* initialView = [storyboard instantiateInitialViewController];
    
    [self.window setRootViewController:initialView];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    

    if( enableLocation ){
     
        bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
        
        localNotification = [[UILocalNotification alloc] init];
        
//        [locationManager stopUpdatingLocation];
//        [locationManager stopMonitoringSignificantLocationChanges];
//        locationManager = nil;
        
        if( locationCount == 0 || locationCount >= 10 )
            timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(findLocation) userInfo:nil repeats:YES];

        locationCount = 0;
        
        NSLog(@"applicationDidEnterBackground");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    [self checkNetwork];
    
    [locationManager stopUpdatingLocation];
    [timer invalidate];
    
    localNotification.applicationIconBadgeNumber = 0;
    [application setApplicationIconBadgeNumber:0];
    
    [self performSelector:@selector(checkVersion) withObject:nil afterDelay:0.1];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) checkNetwork {
    
    //    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostname: serverAddress];
    
    [hostReachable startNotifier];
}

- (void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    
    checkedHost = YES;
    
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch( internetStatus ){
        case NotReachable:
            
//            NSLog(@"The internet is down.");
            internetActive = NO;
            wifiConnection = NO;
            break;
        case ReachableViaWiFi:
            
//            NSLog(@"The internet is working via WIFI.");
            internetActive = YES;
            wifiConnection = YES;
            break;
        case ReachableViaWWAN:
            
//            NSLog(@"The internet is working via WWAN.");
            internetActive = YES;
            wifiConnection = NO;
            break;
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch( hostStatus ){
        case NotReachable:
            
//            NSLog(@"A gateway to the host server is down.");
            hostActive = NO;
            break;
        case ReachableViaWiFi:
            
//            NSLog(@"A gateway to the host server is working via WIFI.");
            hostActive = YES;
            break;
        case ReachableViaWWAN:
            
//            NSLog(@"A gateway to the host server is working via WWAN.");
            hostActive = YES;
            break;
    }
}

-(void)showAlert:(NSString *)title message:(NSString *)message {
    
    //    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    });
}

-(BOOL)updateUserInfo:(NSMutableDictionary *)aDictionary {
    
    dictionary = aDictionary;
    
    [self setSyncCode: [dictionary objectForKey:kSyncCodeKey]];
    [self setCompanyId: [[dictionary objectForKey:kCompanyIdKey] intValue]];
    [self setEmployeeId:[[dictionary objectForKey:kEmployeeIdKey] intValue]];
    [self setEmployeeName: [dictionary objectForKey:kEmployeeNameKey]];
    [self setCompanyName: [dictionary objectForKey:kCompanyNameKey]];
    [self setEmailAddress: [dictionary objectForKey:kEmailAddressKey]];
    [self setIsAdmin: [[dictionary objectForKey:kIsAdminKey] boolValue]];
    [self setLockDeviceUDID: [[dictionary objectForKey:kLockDeviceUDIDKey] boolValue]];
    [self setLunchTime: [[dictionary objectForKey:kLunchTimeKey] boolValue]];
    [self setEmployeeId:[[dictionary objectForKey:kEmployeeIdKey] intValue]];
//    [self setLocationDistanceIndex:[[dictionary objectForKey:kLocationDistanceKey] intValue]];
//    [self setEnableLocation:[[dictionary objectForKey:kEnableLocationKey] boolValue]];
    
//    float latitude  = [[dictionary objectForKey:kLatitudeKey] floatValue];
//    float longitude = [[dictionary objectForKey:kLongitudeKey] floatValue];
//    [self setWorkplaceLocation: [NSString stringWithFormat:@"%f,%f", latitude, longitude]];
    
//    [dictionary setObject:[NSNumber numberWithFloat:self.latitude] forKey:kLatitudeKey];
//    [dictionary setObject:[NSNumber numberWithFloat:self.longitude] forKey:kLongitudeKey];
    NSLog(@"%@", entranceDateTime);
    [dictionary setObject:entranceDateTime forKey:kEntranceDateTimeKey];
    [dictionary setObject:exitDateTime forKey:kExitDateTimeKey];
    [dictionary setObject:lunchStartDateTime forKey:kLunchStartDateTimeKey];
    [dictionary setObject:lunchStopDateTime forKey:kLunchStopDateTimeKey];
    [dictionary setObject:lastEntranceDateTime forKey:kLastEntranceDateTimeKey];
    [dictionary setObject:lastExitDateTime forKey:kLastExitDateTimeKey];
//    [dictionary setObject:[NSNumber numberWithBool:enableLocation] forKey:kEnableLocationKey];
    
//    [dictionary setObject:[NSNumber numberWithBool:pendingSync] forKey:kPendingSyncKey];
    [dictionary setObject:[NSNumber numberWithBool:enableLocation] forKey:kEnableLocationKey];
//    [dictionary setObject:[NSNumber numberWithInt:locationDistanceIndex] forKey:kLocationDistanceIndexKey];
    [dictionary setObject:workplaceLocation forKey:kWorkplaceLocationKey];
    [dictionary setObject:workplaceAddress forKey:kWorkplaceAddressKey];
    
    NSLog(@"dictionary: %@", dictionary);
    
    [[self userDefaults] setObject:dictionary forKey:@"userInfo"];
    [[self userDefaults] synchronize];
    
    return YES;
}

-(void)checkVersion {
    
    if( versionChecked )
        return;
    
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@/timesheet/currentVersion", serverAddress]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if( error == nil) {
            
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *status           = [jsonResponse objectForKey:@"status"];
            
            NSLog(@"url: %@", url);
            
            NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"result: %@", result);
            
            if( [status isEqualToString:@"success"] ){
                
                float currentVersion  = [[jsonResponse objectForKey:@"version"] floatValue];
                
                if( currentVersion > appVersion ){
                    
                    double delayInSeconds = 0.1;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        appUrl = [jsonResponse objectForKey:@"url"];
                        
                        [[[UIAlertView alloc] initWithTitle:@"Nova versão" message:@"Já está disponível uma nova versão do aplicativo Meu Controle na AppStore. Deseja atualizar o aplicativo agora?" delegate:self cancelButtonTitle:@"Mais tarde" otherButtonTitles:@"Atualizar", nil] show];
                    });
                }else{
                    
                }
            }
        }

    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    versionChecked = YES;
    
	if (buttonIndex == 0) {
		
        
	}else{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: appUrl]];
        NSLog(@"Escolheu atualizar: %@", appUrl);
	}
}

-(BOOL)updateUserInfo {

    return [self updateUserInfo: dictionary];
}

-(void)logout {
    
    entranceDateTime      = @"";
    exitDateTime          = @"";
    lastEntranceDateTime  = @"";
    lastExitDateTime      = @"";
    pendingSync           = NO;
    enableLocation        = NO;
    locationDistanceIndex = 0;
    workplaceLocation     = @"0,0";
    workplaceAddress      = @"";

    lastLocationNotification = @"";
    
    [self setCompanyId: 0];
    [self setEmployeeId: 0];
    [self setSyncCode: NULL];
    [[self userDefaults] removeObjectForKey:@"userInfo"];
    [[self userDefaults] synchronize];
}












#pragma Serviços de localização
-(void)findLocation {
    
    if( locationManager != nil ){

        [locationManager startUpdatingLocation];
        return;
    }
    
    // Cria um objeto location manager
    locationManager = [[CLLocationManager alloc] init];
    
    // Define a classe WhereamiAppDelegate como o delegate do objeto criado
    // isso vai enviar as chamadas para o WhereamiAppDelegate
    [locationManager setDelegate:self];
    
    // distanceFilter define a distancia que o aparelho deve percorrer
    // antes de notificar o delegate
    // Nos queremos todos os resultados do location manager
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    
    // E nos queremos que seja o mais preciso possivel
    // independente de quanto tempo/bateria isso consuma
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    //    NSArray *location = [appDelegate.workplaceLocation componentsSeparatedByString:@","];
    //    float latitude    = [[location objectAtIndex:0] floatValue];
    //    float longitude   = [[location objectAtIndex:1] floatValue];
    //
    //    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
    //    CLRegion *region = [[CLRegion alloc]initCircularRegionWithCenter:coord radius:10.0 identifier:@"SF"];
    
    // Diz ao manager para iniciar a procura pela localização imediatamente
    //    [locationManager startMonitoringForRegion:region];
    [locationManager startUpdatingLocation];
    
    NSLog(@"findLocation");
}

-(void)foundLocation {
    
    if( myLocation!=nil ){
        
        NSArray *location = [self.workplaceLocation componentsSeparatedByString:@","];
        float latitude    = [[location objectAtIndex:0] floatValue];
        float longitude   = [[location objectAtIndex:1] floatValue];
        
        CLLocation *workplace = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        float distance = [myLocation distanceFromLocation: workplace];
        
        int radius = [self radius];
        
        NSString *currentLocationNotification;
        
//        NSLog(@"entrada: %@\nalmoco: %@\nretorno: %@\nsaida: %@", entranceDateTime, lunchStartDateTime, lunchStopDateTime, exitDateTime);
        
        // Se não registrou nem a entrada ainda, notifica apenas se ENTRAR no raio de notificação
        if( [entranceDateTime isEqualToString:@""] || entranceDateTime == nil )
            currentLocationNotification = @"near";
        else if( lunchTime ){ // Aqui é apenas se o almoço estiver habilitado (e se já registrou entrada)
            
            if( [lunchStartDateTime isEqualToString:@""] || lunchStartDateTime == nil )
                currentLocationNotification = @"far"; // Se a saída do almoço ainda não foi registrada, notifica quando SAIR do raio de notificação
            else if( [lunchStopDateTime isEqualToString:@""] || lunchStopDateTime == nil )
                currentLocationNotification = @"near"; // Se a saída do almoço foi registrada mas o retorno não, notifica quando ENTRAR no raio de notificação
            else
                currentLocationNotification = @"far"; // Se a saída E o retorno do almoço foram registrados, notifica quando SAIR do raio de notificação (para registro de saída)
        }else{
            
            currentLocationNotification = @"far"; // Vai cair aqui apenas quando tiver registrado a entrada e o horario de almoço estiver desabilitado
        }
        
//        NSLog(@"current: %@, last: %@", currentLocationNotification, lastLocationNotification);
        
        if( (![currentLocationNotification isEqualToString:lastLocationNotification] || [lastLocationNotification isEqualToString:@""]) &&
            (([currentLocationNotification isEqualToString:@"near"] && distance < radius) || ([currentLocationNotification isEqualToString:@"far"] && distance > radius)) ){
        
            [timer invalidate];
            
            [[UIApplication sharedApplication]cancelAllLocalNotifications];
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
            localNotification.alertAction = nil;
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.applicationIconBadgeNumber = 1;
            localNotification.repeatInterval=0;
            localNotification.alertAction = @"notification";
            
            if( [currentLocationNotification isEqualToString:@"near"] ){
               
                localNotification.alertBody = @"Você se aproximou do seu local de trabalho! Não se esqueça de registrar sua chegada!";
//                lastLocationNotification = @"far";
            }else{

                localNotification.alertBody = @"Você se afastou do seu local de trabalho! Não se esqueça de registrar sua saída!";
                
//                lastLocationNotification = @"near";
            }
            
            NSLog(@"alertBody: %@", localNotification.alertBody);
                
            lastLocationNotification = currentLocationNotification;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }else{
            
//            if( [currentLocationNotification isEqualToString:lastLocationNotification] )
//                [timer invalidate];
        }
        
//        NSLog(@"Distancia entre myLocation: %@ e workplace: %@ = %f", myLocation, workplace, distance);
        NSLog(@"Distancia: %f", distance);
    }
    
    [locationManager stopUpdatingLocation];
    [locationManager stopMonitoringSignificantLocationChanges];
    
    locationCount = 0;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    myLocation = newLocation;
    
    locationCount++;
    
    NSLog(@"myLocation: %@", myLocation);
    
    if( locationCount > 10 )
        [self foundLocation];
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif
{
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
    app.applicationIconBadgeNumber = notif.applicationIconBadgeNumber -1;
    
    notif.soundName = UILocalNotificationDefaultSoundName;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"Could not find location: %@", error);
    
    locationCount = 0;
}

-(int)radius {
    
    int radius;
    switch( locationDistanceIndex ){
        case 1:
            radius = 5;
            break;
        case 2:
            radius = 10;
            break;
        case 3:
            radius = 20;
            break;
        case 4:
            radius = 30;
            break;
        case 5:
            radius = 50;
            break;
        case 6:
            radius = 100;
            break;
        case 7:
            radius = 500;
            break;
    }
    
    return radius;
}

- (float)latitude {

    NSArray *location = [self.workplaceLocation componentsSeparatedByString:@","];
    return [[location objectAtIndex:0] floatValue];
}

- (float)longitude {
    
    NSArray *location = [self.workplaceLocation componentsSeparatedByString:@","];
    return [[location objectAtIndex:1] floatValue];
}

@end
