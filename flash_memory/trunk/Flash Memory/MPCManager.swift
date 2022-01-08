//
//  MPCManager.swift
//  MPCRevisited
//
//  Created by Gabriel Theodoropoulos on 11/1/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import MultipeerConnectivity


protocol MPCManagerDelegate {
    func foundPeer()
    
    func lostPeer()
    
    func invitationWasReceived(fromPeer: String)
    
    func connectedWithPeer(peerID: MCPeerID)

    func disconnectedFromPeer()
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {

    var delegate: MPCManagerDelegate?
    
    var session: MCSession!
    
    var peer: MCPeerID!
    
    var browser: MCNearbyServiceBrowser!
    
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    
    var invitationHandler: ((Bool, MCSession!)->Void)!
    
    init(deviceName: String!) {
        super.init()
        
        if( deviceName != nil ){
            
            peer = MCPeerID(displayName: deviceName);
        }
        
        setupSession();
    }
    
    override init() {
        super.init()
        
        setupSession();
    }
    
    func setupSession(){

        if( peer == nil ){
            
            peer = MCPeerID(displayName: UIDevice.currentDevice().name);
        }
        
        session = MCSession(peer: peer)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "flashmemory-mpc")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "flashmemory-mpc")
        advertiser.delegate = self
    }
    
    func updatePeerName(peerName: String){
        
        self.peer = MCPeerID(displayName: peerName);
    }
    
    
    // MARK: MCNearbyServiceBrowserDelegate method implementation
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        foundPeers.append(peerID)
        
        delegate?.foundPeer()
    }
    
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        for (index, aPeer) in enumerate(foundPeers){
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        
        delegate?.lostPeer()
    }
    
    
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        println(error.localizedDescription)
    }
    
    
    // MARK: MCNearbyServiceAdvertiserDelegate method implementation
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        self.invitationHandler = invitationHandler
        
        delegate?.invitationWasReceived(peerID.displayName)
    }
    
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        println(error.localizedDescription)
    }
    
    
    // MARK: MCSessionDelegate method implementation
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        switch state{
        case MCSessionState.Connected:
//            println("Connected to session: \(session)")
            delegate?.connectedWithPeer(peerID)
            break;
        case MCSessionState.Connecting:
//            println("Connecting to session: \(session)")
            break;
        default:
//            println("Did not connect to session: \(session)")
            delegate?.disconnectedFromPeer()
        }
    }
    
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        let dictionary: [String: AnyObject] = ["data": data, "fromPeer": peerID]

//        appDelegate.timerViewController.handleIncomingMessage(dictionary);
        
//        dispatch_async(dispatch_get_main_queue(), ^{
        
//            });
        
        dispatch_async(dispatch_get_main_queue()!, { () -> Void in

            NSNotificationCenter.defaultCenter().postNotificationName("receivedMPCDataNotification", object: dictionary)
        })
    }
    
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) { }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) { }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) { }
    
    
    
    // MARK: Custom method implementation
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, AnyObject>, toPeer targetPeer: MCPeerID) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
        let peersArray = NSArray(object: targetPeer)
        var error: NSError?
        
        if !session.sendData(dataToSend, toPeers: peersArray as [AnyObject], withMode: MCSessionSendDataMode.Reliable, error: &error) {
            println(error?.localizedDescription)
            return false
        }
        
        return true
    }
    
}
