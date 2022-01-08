//
//  MultiplayerSession.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 09/04/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import Foundation

class MultiplayerSession: NSObject {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    static let SERVER_URL = "http://ios.stegun.com/flashmem" + (Constants.LITE_VERSION ? "-lite" : "");
    static let CONNECTION_TIMEOUT : Double = 10;
    let SESSION_TIMER_INTERVAL_SHORT : Double = 2;
    let SESSION_TIMER_INTERVAL_LONG : Double = 30;

    var deviceIdentifier : String!;
    var mainScore : Int!;
    var deviceSessionId : Int!;
    var gameSessionId : Int!;
    var deviceName : String!;
    var nickname : String!;
    var deviceSessionList : [NSDictionary] = [];
    var onlinePlayers : Int = 0;
    var isPlaying : Bool = false;
    var sessionTimer : NSTimer!;
    var playerName : String!;
    var multiplayerInstance : String!
    var sessionStartAttempt : Int = 0;
    var requestMatchAttempt : Int = 0;
    var pushNotificationEnabled : Int!;
    
    init(nickname: String!){
    
        deviceIdentifier        = UIDevice.currentDevice().identifierForVendor.UUIDString;
        mainScore               = 0;
        isPlaying               = false;
        self.nickname           = nickname;
        deviceName              = (nickname != nil ? nickname : UIDevice.currentDevice().name);
        multiplayerInstance     = "";
        pushNotificationEnabled = (appDelegate.pushNotificationEnabled ? 1 : 0);
        sessionStartAttempt     = 0;
    }
    
    func startSession(){
        
//        println("startSession()");
        
        if( sessionTimer != nil ){
            
            sessionTimer.invalidate();
        }
        
        var url = NSURL(string: "\(MultiplayerSession.SERVER_URL)/startSession");

        var request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: MultiplayerSession.CONNECTION_TIMEOUT);
        
        request.HTTPMethod = "POST";
        let postString     = "deviceIdentifier=\(deviceIdentifier)&deviceName=\(deviceName)&pushNotificationEnabled=\(pushNotificationEnabled)";
        request.HTTPBody   = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        deviceSessionId     = nil;
        gameSessionId       = nil;
        deviceSessionList   = [];
        onlinePlayers       = 0;
        requestMatchAttempt = 0;
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if( error == nil ){
                
                var jsonResult: NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary;
                
                if( jsonResult != nil ){
                    
//                    println("jsonResult: \(jsonResult)");
                    var deviceSession : NSDictionary! = jsonResult?.objectForKey("deviceSession") as! NSDictionary;
                    self.deviceSessionId   = (deviceSession["id"] as! NSNumber).integerValue;
                    self.onlinePlayers     = (jsonResult?.objectForKey("onlinePlayers") as! NSNumber).integerValue;
                    self.deviceSessionList = jsonResult?.objectForKey("deviceSessionList") as! [NSDictionary];
                    self.notifySessionUpdate();
                    
                    if( self.sessionTimer == nil ){
                        
                        self.sessionTimer = NSTimer.scheduledTimerWithTimeInterval(self.SESSION_TIMER_INTERVAL_SHORT, target: self, selector: Selector("updateSession"), userInfo: nil, repeats: true);
                    }
                }else{
                    
                    self.retryStartSession();
                }
            }else{
                
                self.retryStartSession();
            }
        });
    }
    
    func retryStartSession(){
        
        sleep(3);
        
        sessionStartAttempt++;
        
        if( sessionStartAttempt == 5 ){
            
            NSNotificationCenter.defaultCenter().postNotificationName("multiplayerSessionStartFailure", object:nil);
        }else{
            
            startSession();
        }
    }
    
    func updateSession(){
        
        if( !validateSession() ){
            
            return;
        }
        
        var url = NSURL(string: "\(MultiplayerSession.SERVER_URL)/updateSession");
        
        var request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: MultiplayerSession.CONNECTION_TIMEOUT);
        
        request.HTTPMethod = "POST";
        let postString     = "deviceSessionId=\(deviceSessionId)&deviceIdentifier=\(deviceIdentifier)&deviceName=\(deviceName)&multiplayerInstance=\(multiplayerInstance)&pushNotificationEnabled=\(pushNotificationEnabled)";

        request.HTTPBody   = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if( error == nil ){
                
                self.handleSessionUpdate(data, from: "update");
            }
        })
    }
    
    func requestMatch(){
        
        if( !validateSession() ){
            
            return;
        }
        
        var url = NSURL(string: "\(MultiplayerSession.SERVER_URL)/requestMatch");
        
        var request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: MultiplayerSession.CONNECTION_TIMEOUT);
        
        request.HTTPMethod = "POST";
        let postString     = "deviceSessionId=\(deviceSessionId)&pushNotificationEnabled=\(pushNotificationEnabled)";
//        println("\(url?.description)?\(postString)");
        
        request.HTTPBody   = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if( error == nil ){
                
                self.handleSessionUpdate(data, from: "requestMatch");
            }else{
                
//                println("error: \(error)");
            }
        })
    }
    
    func handleSessionUpdate(data: NSData, from: String){
        
        if( deviceSessionId == nil ){
            
            return;
        }
        
        var jsonResult: NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary;
        
        if( jsonResult != nil ){
            
//            println("jsonResult: \(jsonResult)");
            var deviceSession : NSDictionary! = jsonResult?.objectForKey("deviceSession") as! NSDictionary;
            var deviceSessionId = (deviceSession["id"] as! NSNumber).integerValue;
            var sessionStatus   = deviceSession["sessionStatus"] as! String;
            
            if( from == "requestMatch" && (sessionStatus != "waiting" && sessionStatus != "playing") ){
            
                requestMatchAttempt++;
                
                if( requestMatchAttempt < 5 ){
                    
                    requestMatch()
//                    println("Reenviando a requisição de jogo");
                }else{
                    
                    stopSession();
                }
                return;
            }
            
            if( self.deviceSessionId != nil && self.deviceSessionId != deviceSessionId ){
                
//                println("parou a sessão porque o id é diferente");
                self.stopSession();
                return;
            }
            
            self.deviceSessionId = deviceSessionId;
            
            self.onlinePlayers     = (jsonResult?.objectForKey("onlinePlayers") as! NSNumber).integerValue;
            self.deviceSessionList = jsonResult?.objectForKey("deviceSessionList") as! [NSDictionary];
            

            var gameSession : NSDictionary! = jsonResult?.objectForKey("gameSession") as! NSDictionary;
            handleGameSessionChange(gameSession);
            
            if( from == "requestMatch" && appDelegate.pushNotificationEnabled ){
                
                if( sessionTimer != nil ){
                    
                    sessionTimer.invalidate();
                    self.sessionTimer = NSTimer.scheduledTimerWithTimeInterval(self.SESSION_TIMER_INTERVAL_LONG, target: self, selector: Selector("updateSession"), userInfo: nil, repeats: true);
                }
            }
            
            if( !appDelegate.pushNotificationEnabled && self.gameSessionId != nil ){
                
                var message : Dictionary! = gameSession["\(self.multiplayerInstance)Message"] as! Dictionary<String, AnyObject>;
                
                if( message.count > 0 ){
                 
                    NSNotificationCenter.defaultCenter().postNotificationName("MultiplayerSessionMessageReceived", object:message);
                }
            }
            
            self.notifySessionUpdate();
        }else{
            
            var result = NSString(data: data, encoding: NSUTF8StringEncoding);
//            println("result: \(result)");
            
            if( result == "CLOSED SESSION" || result == "INVALID SESSION" ){
                
//                println("parou a sessão porque o retorno do servidou invalidou");
                self.stopSession();
            }
        }
    }
    
    func handleGameSessionChange(gameSession: NSDictionary){
        
        var gameSessionId : Int! = (gameSession["id"] as! NSNumber).integerValue;
        
        if( self.gameSessionId == nil && gameSessionId > 0){
            
            var sessionStatus = gameSession["sessionStatus"] as! String;
            
            if( sessionStatus == "close" ){
                
                stopSession();
                return;
            }
            
            var deviceSessionIdHost : Int = (gameSession["deviceSessionIdHost"] as! NSNumber).integerValue;
            var deviceSessionIdGuest : Int = (gameSession["deviceSessionIdGuest"] as! NSNumber).integerValue;
            
            if( deviceSessionId == deviceSessionIdHost ){
                
                playerName = gameSession["playerNameGuest"] as! String;
                multiplayerInstance = "host";
            }else{
                
                playerName = gameSession["playerNameHost"] as! String
                multiplayerInstance = "guest";
            }
            
            self.gameSessionId = gameSessionId;
            
            if( !isPlaying ){
                
                isPlaying = true;
                loadMultiplayerStoryboard();
            }
        }
    }
    
    func sendMessage(message: Dictionary<String, AnyObject>, timeDeduction: Int){
        
        var err : NSError!;
        var jsonData : NSData = NSJSONSerialization.dataWithJSONObject(message, options: NSJSONWritingOptions.allZeros, error: nil)!;
        var jsonString : NSString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!;
        
        if( !validateSession() ){
            
            return;
        }
        
        var url = NSURL(string: "\(MultiplayerSession.SERVER_URL)/sendMessage");

        var request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: MultiplayerSession.CONNECTION_TIMEOUT);

        request.HTTPMethod = "POST";
        let postString = "gameSessionId=\(gameSessionId)&deviceSessionId=\(deviceSessionId)&deviceIdentifier=\(deviceIdentifier)&deviceName=\(deviceName)&multiplayerInstance=\(multiplayerInstance)&mainScore=\(mainScore)&timeDeduction=\(timeDeduction)&pushNotificationEnabled=\(pushNotificationEnabled)&message=\(jsonString)";
        
//        println(postString);

        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in

            if( error == nil ){

                self.handleSessionUpdate(data, from: "sendMessage");
            }
        })
    }
    
    func stopSession(){
        
        if( deviceSessionId == nil ){
            
            return;
        }
        
//        println("stopSession() -> \(deviceSessionId)");
        
        if( sessionTimer != nil ){
            
            sessionTimer.invalidate();
            sessionTimer = nil;
        }
        
        var url = NSURL(string: "\(MultiplayerSession.SERVER_URL)/stopSession");
        
        var request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: MultiplayerSession.CONNECTION_TIMEOUT);
        
        request.HTTPMethod = "POST";
        let postString     = "deviceSessionId=\(deviceSessionId)&pushNotificationEnabled=\(pushNotificationEnabled)";
        request.HTTPBody   = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
        });
        
        NSNotificationCenter.defaultCenter().postNotificationName("multiplayerStopSession", object:nil);
        
        if( gameSessionId != nil ){
            
            NSNotificationCenter.defaultCenter().postNotificationName("MultiplayerSessionClosed", object:nil);
        }
        
        deviceSessionId   = nil;
        gameSessionId     = nil;
        deviceSessionList = [];
        onlinePlayers     = 0;
        isPlaying         = false;
        notifySessionUpdate();
    }
    
    func validateSession() -> Bool {
        
        if( deviceSessionId != nil && deviceSessionId > 0 ){
            
            return true;
        }else{
            
            stopSession();
            return false;
        }
    }
    
    func notifySessionUpdate(){
        
        NSNotificationCenter.defaultCenter().postNotificationName("updateDeviceSessionList", object:nil);
    }
    
    func loadMultiplayerStoryboard(){
        
        NSNotificationCenter.defaultCenter().postNotificationName("multiplayerStartSession", object:nil);
        (appDelegate.window?.rootViewController as! GameViewController).loadMultiplayerOnlineStoryboard();
    }
}