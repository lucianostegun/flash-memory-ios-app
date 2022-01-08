//
//  PlayersViewController.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 03/04/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import UIKit
import Foundation
import MultipeerConnectivity

class PlayersViewController: UITableViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    var parentPopover:UIPopoverController?
    
    @IBOutlet var btnStartOnlineSession : UIButton!;
    
    var multiplayerSessionStatus : String!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        if( appDelegate.mpcManager == nil ){
            
            appDelegate.enableMultipeerConnection();
        }
        
        if( appDelegate.multiplayerSession == nil ){
            
            appDelegate.multiplayerSession = MultiplayerSession(nickname: appDelegate.playerGKNickname);
        }
        
        if( Constants.IOS_VERSION >= 8.0 ){
            
            self.navigationController?.popoverPresentationController?.backgroundColor = UIColor(white: 0.15, alpha: 1)
        }
        
        self.navigationController?.navigationBar.barTintColor = UIColor(white: 0.15, alpha: 1);
        
        multiplayerSessionStatus        = "loading";
        appDelegate.multiplayerInstance = ""
        
        appDelegate.mpcManager.advertiser.startAdvertisingPeer();
        appDelegate.mpcManager.browser.startBrowsingForPeers();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("foundPeer:"), name: "MPCManagerFoundPeer", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("lostPeer:"), name: "MPCManagerLostPeer", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectedWithPeer:"), name: "MPCManagerConnectedWithPeer", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("disconnectedFromPeer:"), name: "MPCManagerDisconnectedFromPeer", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateDeviceSessionList:"), name: "updateDeviceSessionList", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("multiplayerStartSession"), name: "multiplayerStartSession", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("multiplayerStopSession"), name: "multiplayerStopSession", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateMultiplayerSessionStatus"), name: "multiplayerSessionStartFailure", object: nil);
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated);
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        appDelegate.multiplayerSession.startSession();
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated);
        
        if( appDelegate.multiplayerSession != nil && !appDelegate.multiplayerSession.isPlaying ){
            
            appDelegate.multiplayerSession.stopSession();
            appDelegate.multiplayerSession = nil;
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

//        if( appDelegate.multiplayerSession != nil && appDelegate.multiplayerSession.onlinePlayers > 0 ){
        
            return 2;
//        }
//        
//        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if( section == 0 ){
            
            return appDelegate.mpcManager.foundPeers.count;
        }else{
            
            return (multiplayerSessionStatus == "online" ? 1 : 0);
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell!
        
        if( indexPath.section == 0 ){
         
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "MULTIPEER_DEVICE_CELL");
            cell.textLabel?.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName;
        }else{

            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ONLINE_SESSION_CELL");
            cell.textLabel?.text = NSLocalizedString("Start online match", comment: "");
        }
        
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if( indexPath.section == 0 ){
            
            let selectedPeer = appDelegate.mpcManager.foundPeers[indexPath.row] as MCPeerID
            appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelegate.mpcManager.session, withContext: nil, timeout: 0);
            
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDModeIndeterminate
            loadingNotification.labelText = NSLocalizedString("Inviting ", comment: "")+selectedPeer.displayName;
            
            appDelegate.multiplayerInstance = "host";
        }else{

            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDModeIndeterminate
            loadingNotification.labelText = NSLocalizedString("Starting online match", comment: "");
            
            startOnlineGame();
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch(section){
        case 0:
            return NSLocalizedString("Local players", comment: "");
        case 1:
            return NSLocalizedString("Online session", comment: "");
        default:
            return "";
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {

        var devices : Int = 0;
        var pluralDevices : String = "";
        var warning : String = "";
        
        switch(section){
        case 0:
            
            devices = appDelegate.mpcManager.foundPeers.count;
                        
            if( devices == 0 ){
                
                return NSLocalizedString("No player visible", comment: "");
            }
            
            pluralDevices = devices == 1 ? NSLocalizedString("player", comment: "") : NSLocalizedString("players", comment: "");
            break;
        case 1:
            
            if( multiplayerSessionStatus == "loading" ){
                
                return NSLocalizedString("Starting online session. Connecting to server...", comment: "");
            }else if( multiplayerSessionStatus == "failure" ){
                
                return NSLocalizedString("Error connecting to server. Please try again later.", comment: "");
            }
            
            if( appDelegate.multiplayerSession == nil ){
                
                break;
            }
            
            devices = appDelegate.multiplayerSession.onlinePlayers
            
            var footer = "";
            
            if( devices == 0 ){
                
                footer = NSLocalizedString("No player visible", comment: "");
            }
            
            if( !appDelegate.pushNotificationEnabled ){
                
                warning = "\n\n" + NSLocalizedString("Online sessions work much better when push notifications are enable. Please consider enable Push Notification for a better online match experience.", comment: "")
            }
            
            pluralDevices = devices == 1 ? NSLocalizedString("online player", comment: "") : NSLocalizedString("online players", comment: "");
            break;
        default:
            break;
        }
        
        return "\(devices) \(pluralDevices)\(warning)";
    }
    
    @IBAction func dismissViewController(sender: AnyObject) {

        if( appDelegate.multiplayerSession != nil ){
            
            appDelegate.multiplayerSession.stopSession();
        }
        
        dismissViewController();
    }
    
    func dismissViewController(){
        
        if( Constants.IOS_VERSION < 8.0 ){
            
            parentPopover?.dismissPopoverAnimated(true);
        }else{
            
            self.dismissViewControllerAnimated(true, completion: nil);
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    func foundPeer(notification : NSNotification) {
        tableView.reloadData()
    }
    
    func lostPeer(notification : NSNotification) {
        tableView.reloadData()
    }
    
    func connectedWithPeer(notification : NSNotification) {
        
        let peerID = notification.object as! MCPeerID;
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true);
        
        self.dismissViewController();
        
        if( appDelegate.multiplayerInstance == "host" ){
            NSNotificationCenter.defaultCenter().postNotificationName("loadMultiplayerStoryboard", object: nil);
        }
    }
    
    func disconnectedFromPeer(notification : NSNotification){
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true);
        
        tableView.reloadData()
    }
    
    func updateDeviceSessionList(notification: NSNotification){
        
        multiplayerSessionStatus = "online";
        tableView.reloadData();
    }
    
    func updateMultiplayerSessionStatus(){

        multiplayerSessionStatus = "failure";
        tableView.reloadData();
    }
    
    
    
    
    
    
    
    
    
    func startOnlineGame(){
        
        appDelegate.multiplayerSession.requestMatch();
    }
    
    func multiplayerStartSession(){
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true);
        
        self.dismissViewController();
    }
    
    func multiplayerStopSession(){
//        
//        let alertView = UIAlertView(title: NSLocalizedString("SESSION CLOSED!", comment: ""), message: NSLocalizedString("Your online game request did not respond in a valid time.", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment: ""));
//        alertView.show()
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true);
    }
}