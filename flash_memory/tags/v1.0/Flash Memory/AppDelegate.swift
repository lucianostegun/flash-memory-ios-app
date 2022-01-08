//
//  AppDelegate.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 24/03/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import UIKit
import GameKit
import MultipeerConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MPCManagerDelegate, UIAlertViewDelegate, iRateDelegate {

    var window: UIWindow?
    var userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    let kSavedSettings              = "savedSettings";
    let kSettingsLastAppVersion     = "settings.lastAppVersion"
    let kSettingsPlayMusic          = "settings.playMusic"
    let kSettingsPracticeDifficulty = "settings.practiceDifficulty"
    let kSettingsSoundEffects       = "settings.soundEffects"
    let kSettingsCurrentLevel       = "settings.currentLevel"
    let kSettingsCurrentStage       = "settings.currentStage"
    let kSettingsBestMainScore      = "settings.bestMainScore"
    let kSettingsRegisteredToken    = "settings.registeredToken"
    
    var lastAppVersion : Double!;
    var playMusic : Bool = false;
    var practiceDifficulty : String = "Fish";
    var soundEffects : Bool = true;
    var currentLevel : Int!;
    var currentStage : Int!;
    var bestMainScore : Int!;
    var gameLevelList : Array<GameLevel>!;
    var language : String = "english";
    var registeredToken : Bool = false;
    var bannerType : String!;
    
    // ACHIEVEMENTS
    let kAchievementPerfectLevel    = "achievement.perfectLevel"
    let kAchievementPerfectGame     = "achievement.perfectGame"
    let kAchievementThreeStarsLevel = "achievement.trhreeStarsLevel"
    let kAchievementUnlocker        = "achievement.unlocker"

    var AchievementPerfectLevel : Bool = false;
    var AchievementPerfectGame : Bool = false;
    var AchievementThreeStarsLevel : Bool = false;
    var AchievementUnlocker : Bool = false;
    var mpcManager: MPCManager!
    var multipeerDisplayName : String = "";
    var multiplayerInstance : String = "";
    var playerGKNickname : String!
    var pushNotificationEnabled : Bool = false;
    
    var multiplayerSession : MultiplayerSession!;
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        var savedSettings = userDefaults.boolForKey(kSavedSettings);
        
        if( !savedSettings ){
        
            createUserDefaults();
        }
        
        loadSettings();
        
        gameLevelList = GameLevel.loadArchivedGameLevelList(true);
        gameLevelList[currentLevel].currentStage = currentStage;
        
        configurePushNotifications(application);
        
        iRate.sharedInstance().applicationBundleID = "com.stegun.Flash-Memory" + (Constants.LITE_VERSION ? "-Lite" : "");
        iRate.sharedInstance().onlyPromptIfLatestVersion = false
        iRate.sharedInstance().verboseLogging = false;
        
        //enable preview mode
        iRate.sharedInstance().previewMode = false
        
        bannerType = Int(arc4random_uniform(UInt32(10))) >= 5 ? "google" : "apple";
        
        return true
    }
    
    func configurePushNotifications(application: UIApplication){
        
        // Register for Push Notitications, if running iOS 8
        if( application.respondsToSelector("registerUserNotificationSettings:") ){
            
            let types:UIUserNotificationType = (.Alert | .Badge | .Sound)
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil);
            
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }else{
            
            // Register for Push Notifications before iOS 8
            application.registerForRemoteNotificationTypes(.Alert | .Badge | .Sound)
        }
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        if( !registeredToken ){
            
            var url = NSURL(string: "\(MultiplayerSession.SERVER_URL)/registerForPushNotification");
            
            let deviceIdentifier = UIDevice.currentDevice().identifierForVendor.UUIDString;
            let deviceName       = UIDevice.currentDevice().name;
            
            var request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15);
            
            request.HTTPMethod = "POST";
            let postString     = "deviceIdentifier=\(deviceIdentifier)&deviceName=\(deviceName)&deviceToken=\(deviceToken)&language=\(language)";
//            println("postString: \(postString)");
            request.HTTPBody   = postString.dataUsingEncoding(NSUTF8StringEncoding)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                
                if( error == nil ){
                    
                    self.registeredToken = true;
                    self.saveUserDefaults()
                }
            });
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("Failed to get token, error: \(error)");
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        var dictionary = userInfo as NSDictionary;
        var aps : NSDictionary = (dictionary["aps"] as! NSDictionary);
        var type = aps["type"] as! String;
        
        if( type == "multiplayerMessage" ){
            
            var message : Dictionary<String, AnyObject> = aps["message"] as! Dictionary<String, AnyObject>;
            
            NSNotificationCenter.defaultCenter().postNotificationName("MultiplayerSessionMessageReceived", object:message);
        }
        
        if( type == "multiplayerSessionUpdate" ){
            
            var gameSession : NSDictionary! = aps.objectForKey("message") as! NSDictionary;
            multiplayerSession.handleGameSessionChange(gameSession)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as! an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        (self.window?.rootViewController as! GameViewController).skView.paused = true;
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveUserDefaults()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as! part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        (self.window?.rootViewController as! GameViewController).skView.paused = false;
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveUserDefaults();
    }

    func createUserDefaults(){
        
        currentLevel    = 0;
        currentStage    = 0;
        bestMainScore   = 0;
        registeredToken = false;
        
        lastAppVersion = (NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! NSString).doubleValue;
        
        self.saveUserDefaults();
    }
    
    func loadSettings(){
        
        var appleLanguages : NSArray = NSUserDefaults.standardUserDefaults().objectForKey("AppleLanguages") as! NSArray;
        language = appleLanguages.objectAtIndex(0) as! String;
        
        lastAppVersion = (NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! NSString).doubleValue;
        
        currentStage    = userDefaults.integerForKey(kSettingsCurrentStage);
        currentLevel    = userDefaults.integerForKey(kSettingsCurrentLevel);
        bestMainScore   = userDefaults.integerForKey(kSettingsBestMainScore);
        playMusic       = userDefaults.boolForKey(kSettingsPlayMusic);
        soundEffects    = userDefaults.boolForKey(kSettingsSoundEffects);
        registeredToken = userDefaults.boolForKey(kSettingsRegisteredToken);
        
        practiceDifficulty = userDefaults.objectForKey(kSettingsPracticeDifficulty) as! String;
        
        AchievementPerfectLevel    = userDefaults.boolForKey(kAchievementPerfectLevel);
        AchievementPerfectGame     = userDefaults.boolForKey(kAchievementPerfectGame);
        AchievementThreeStarsLevel = userDefaults.boolForKey(kAchievementThreeStarsLevel);
        AchievementUnlocker        = userDefaults.boolForKey(kAchievementUnlocker);
        
        getPushNotificationSettings();
        
        userDefaults.synchronize();
    }
    
    func saveUserDefaults(){
        
        userDefaults.setBool(playMusic, forKey: kSettingsPlayMusic);
        userDefaults.setBool(soundEffects, forKey: kSettingsSoundEffects);

        userDefaults.setInteger(currentStage, forKey:kSettingsCurrentStage);
        userDefaults.setInteger(currentLevel, forKey:kSettingsCurrentLevel);
        userDefaults.setInteger(bestMainScore, forKey:kSettingsBestMainScore);
        userDefaults.setDouble(lastAppVersion, forKey: kSettingsLastAppVersion);
        
        userDefaults.setBool(AchievementPerfectLevel, forKey: kAchievementPerfectLevel);
        userDefaults.setBool(AchievementPerfectGame, forKey: kAchievementPerfectGame);
        userDefaults.setBool(AchievementThreeStarsLevel, forKey: kAchievementThreeStarsLevel);
        userDefaults.setBool(AchievementUnlocker, forKey: kAchievementUnlocker);
        
        userDefaults.setBool(registeredToken, forKey: kSettingsRegisteredToken);
        userDefaults.setBool(true, forKey: kSavedSettings);
        
        userDefaults.setObject(practiceDifficulty, forKey: kSettingsPracticeDifficulty);
        
        userDefaults.synchronize();
    }
    
    func getPushNotificationSettings(){
        
        if( UIApplication.sharedApplication().respondsToSelector(Selector("isRegisteredForRemoteNotifications")) ){
            // iOS 8.0+
            pushNotificationEnabled = UIApplication.sharedApplication().isRegisteredForRemoteNotifications();
            
        }else{
            
            let types : UIRemoteNotificationType = UIApplication.sharedApplication().enabledRemoteNotificationTypes();
            
            pushNotificationEnabled = (types != UIRemoteNotificationType.None);
        }
        
//        println("pushNotificationEnabled: \(pushNotificationEnabled)");
    }
    
    func getAchievements(localPlayer: GKLocalPlayer) -> Array<GKAchievement> {
        
        var perfectLevel : Bool    = false;
        var perfectGame : Bool     = true;
        var threeStarsLevel : Bool = false;
        var unlocker : Bool        = true;
        
        var achievements : Array<GKAchievement> = [];
        
        for gameLevel in gameLevelList {
            
            var perfectStage : Bool    = true;
            var threeStarsStage : Bool = true;
            
            for gameStage in gameLevel.gameStageList {
                
//                println("right: \(gameStage.bestRightBlocks), missed: \(gameStage.bestMissedBlocks), wrong: \(gameStage.bestWrongBlocks), stars: \(gameStage.stars)");
                if( gameStage.bestRightBlocks == 0 || gameStage.bestMissedBlocks > 0 || gameStage.bestWrongBlocks > 0 ){
                    
                    perfectStage = false;
                    perfectGame  = false;
                }
                
                if( gameStage.stars < 3 ){
                    
                    threeStarsStage = false;
                }
                
                if( gameStage.locked ){
                    
                    unlocker = false;
                }
            }
            
//            println("perfectStage: \(perfectStage)");
            
            if( !perfectLevel && perfectStage ){
                
                perfectLevel = true;
            }
            
//            println("threeStarsLevel: \(threeStarsLevel), threeStarsStage: \(threeStarsStage)");
            
            if( !threeStarsLevel && threeStarsStage ){
                threeStarsLevel = true;
            }
        }
        
        if( self.AchievementThreeStarsLevel || threeStarsLevel ){
            
            var achievementIdentifier = "grp.com.stegun.FlashMemory.Ranking.Achievement.ThreeStarsLevel";
            var threeStarsLevelAchievement : GKAchievement = GKAchievement(identifier: achievementIdentifier, player: localPlayer)
            threeStarsLevelAchievement.percentComplete = 100;
            achievements.append(threeStarsLevelAchievement);
            self.AchievementThreeStarsLevel = true;
        }
        
        if( self.AchievementPerfectLevel || perfectLevel ){
            
            println("perfect level");
            var achievementIdentifier = "grp.com.stegun.FlashMemory.Ranking.Achievement.PerfectLevel";
            var perfectLevelAchievement : GKAchievement = GKAchievement(identifier: achievementIdentifier, player: localPlayer)
            perfectLevelAchievement.percentComplete = 100;
            achievements.append(perfectLevelAchievement);
            self.AchievementPerfectLevel = true;
        }
        
        if( self.AchievementPerfectGame || perfectGame ){
            
            println("perfect game");
            var achievementIdentifier = "grp.com.stegun.FlashMemory.Ranking.Achievement.PerfectGame";
            var perfectGameAchievement : GKAchievement = GKAchievement(identifier: achievementIdentifier, player: localPlayer)
            perfectGameAchievement.percentComplete = 100;
            achievements.append(perfectGameAchievement);
            self.AchievementPerfectGame = true;
        }
        
        if( self.AchievementUnlocker || unlocker ){
            
            println("unlocker");
            var achievementIdentifier = "grp.com.stegun.FlashMemory.Ranking.Achievement.Unlocker";
            var unlockerAchievement : GKAchievement = GKAchievement(identifier: achievementIdentifier, player: localPlayer)
            unlockerAchievement.percentComplete = 100;
            achievements.append(unlockerAchievement);
            self.AchievementUnlocker = true;
        }
        
        return achievements;
    }
    
    
    
    
    
    
    
    
    func enableMultipeerConnection(){
        
        mpcManager = MPCManager(deviceName: playerGKNickname);
        mpcManager.delegate = self;
    }
    
    func disableMultipeerConnection(){
        
        mpcManager.advertiser.stopAdvertisingPeer();
    }
    
    func foundPeer() {
        
        dispatch_async(dispatch_get_main_queue()!, { () -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName("MPCManagerFoundPeer", object:nil);
        })
    }
    
    
    func lostPeer() {
        
        dispatch_async(dispatch_get_main_queue()!, { () -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName("MPCManagerLostPeer", object:nil);
        })
    }
    
    func invitationWasReceived(fromPeer: String) {
        
        if( multiplayerInstance != "" ){
            
            return;
        }
        
        multipeerDisplayName = fromPeer;
        var alertView = UIAlertView(title: NSLocalizedString("Multiplayer request", comment: ""), message: "\(fromPeer) "+NSLocalizedString("wants to play with you", comment:""), delegate: self, cancelButtonTitle: NSLocalizedString("Decline", comment: ""), otherButtonTitles: NSLocalizedString("Accept", comment: ""));
        
        alertView.show();
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if( buttonIndex == 1 && multiplayerInstance == "" ){
            
//            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.window?.rootViewController?.view, animated: true)
//            loadingNotification.mode = MBProgressHUDModeIndeterminate
//            loadingNotification.labelText = NSLocalizedString("Connecting to", comment: "")+selectedPeer.displayName;
            
            self.multiplayerInstance = "guest";
            NSNotificationCenter.defaultCenter().postNotificationName("loadMultiplayerStoryboard", object: nil);
        }else{
            
            self.mpcManager.invitationHandler(false, nil);
        }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        
        multipeerDisplayName = peerID.displayName;
        
        mpcManager.advertiser.stopAdvertisingPeer();
        
        dispatch_async(dispatch_get_main_queue()!, { () -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName("MPCManagerConnectedWithPeer", object:peerID);
        })
    }
    
    func disconnectedFromPeer(){
        
        multipeerDisplayName = "";
        multiplayerInstance = "";
        
        dispatch_async(dispatch_get_main_queue()!, { () -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName("MPCManagerDisconnectedFromPeer", object:nil);
        })
    }
}

