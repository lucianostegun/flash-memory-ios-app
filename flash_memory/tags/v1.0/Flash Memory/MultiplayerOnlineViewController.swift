//
//  MultiplayerOnlineViewController.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 10/04/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

class MultiplayerOnlineViewController: UIViewController, UIAlertViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    var gameScene : GameScene!;
    var skView : SKView!;
    @IBOutlet var iAdBannerView: ADBannerView!
    @IBOutlet weak var btnShowMenu: UIButton!
    @IBOutlet weak var vwScoreBoard: UIView!
    @IBOutlet weak var vwMainMenu: UIView!
    @IBOutlet weak var lblLoading: UILabel!
    @IBOutlet weak var lblCurrentScore: UILabel!
    @IBOutlet weak var lblCurrentScoreOpponent: UILabel!
    @IBOutlet weak var lblDifficulty: UILabel!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var lblMainScore: UICountingLabel!
    @IBOutlet weak var lblStageScore: UICountingLabel!
    @IBOutlet weak var lblRightBlocksScore: UICountingLabel!
    @IBOutlet weak var lblWrongBlocksScore: UICountingLabel!
    @IBOutlet weak var lblMissedBlocksScore: UICountingLabel!
    @IBOutlet weak var lblPerfectBonus: UICountingLabel!
    @IBOutlet weak var lblTimeBonusScore: UICountingLabel!
    @IBOutlet weak var lblDeductions: UICountingLabel!
    @IBOutlet weak var lblTotalBlocks: UILabel!
    @IBOutlet weak var lblRightBlocks: UILabel!
    @IBOutlet weak var lblWrongBlocks: UILabel!
    @IBOutlet weak var lblMissedBlocks: UILabel!
    @IBOutlet weak var lblTimeBonus: UILabel!
    @IBOutlet weak var imgStar1: UIImageView!
    @IBOutlet weak var imgStar2: UIImageView!
    @IBOutlet weak var imgStar3: UIImageView!
    
    
    @IBOutlet weak var lblOpponentDeviceName: UILabel!
    @IBOutlet weak var lblMainScoreOpponent: UICountingLabel!
    @IBOutlet weak var lblStageScoreOpponent: UICountingLabel!
    @IBOutlet weak var lblRightBlocksScoreOpponent: UICountingLabel!
    @IBOutlet weak var lblWrongBlocksScoreOpponent: UICountingLabel!
    @IBOutlet weak var lblMissedBlocksScoreOpponent: UICountingLabel!
    @IBOutlet weak var lblPerfectBonusOpponent: UICountingLabel!
    @IBOutlet weak var lblTimeBonusScoreOpponent: UICountingLabel!
    @IBOutlet weak var lblDeductionsOpponent: UICountingLabel!
    @IBOutlet weak var lblTotalBlocksOpponent: UILabel!
    @IBOutlet weak var lblRightBlocksOpponent: UILabel!
    @IBOutlet weak var lblWrongBlocksOpponent: UILabel!
    @IBOutlet weak var lblMissedBlocksOpponent: UILabel!
    @IBOutlet weak var lblTimeBonusOpponent: UILabel!
    @IBOutlet weak var imgStar1Opponent: UIImageView!
    @IBOutlet weak var imgStar2Opponent: UIImageView!
    @IBOutlet weak var imgStar3Opponent: UIImageView!
    
    var playedGames = 0;
    var difficulty : String = "Fish";
    var minRandomBlocks : Int = 15;
    var maxRandomBlocks : Int = 20;
    var gameLevel : GameLevel!;
    var gameReady : Bool = false;
    var hostReady : Bool = false;
    var guestReady : Bool = false;
    var imReady : Bool = false;
    var gameStageOpponent : GameStage!;
    var pendingLevelChange = false;
    var bestMainScore : Int = 0;
    var skViewPauseTimer : NSTimer!;
    
    var mainScoreOpponent : Int = 0;
    
    let leaderboardIdentifier : String = "com.stegun.FlashMemory.MultiplayerRanking";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameScene = GameScene.unarchiveFromFile("GameScene") as? GameScene;
        gameScene.size = CGSizeMake(Util.getScreenWidth(self.view), Util.getScreenHeight(self.view));
        
        if gameScene != nil {
            // Configure the view.
            skView = self.view as! SKView
            
            //            skView.showsFPS = true
            //            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            gameScene.scaleMode = .AspectFill
            gameScene.soundEffects = appDelegate.soundEffects;
            
            skView.presentScene(gameScene);
            skView.paused = true;
        }
        
        gameScene.mainScore = 0;
        gameScene.clearAllBlocks();
        
        vwScoreBoard.hidden = true;
        lblMainScore.format = "%07d";
        lblMainScoreOpponent.format = "%07d";
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleMultiplayerSessionIncomingMessage:", name: "MultiplayerSessionMessageReceived", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("stopMultiplayerGame"), name: "MultiplayerSessionClosed", object: nil);
        
        gameLevel = GameLevel();
        gameLevel.deleteAllStages();
        
        gameLevel.levelNumber   = 1;
        gameLevel.flashDuration = 2.0;
        gameLevel.timeDeduction = 10;
        gameLevel.blinkFirst    = true;
        gameLevel.blinkLast     = true;
        
        imReady = true;
        
        if( appDelegate.multiplayerSession.multiplayerInstance == "host" ){
            
            hostReady = true;
            
            createRandomPath();
            sendMessageToOtherPlayer("gamePath", message: gameLevel.getStage().getPathToArchive());
            handleStartGame()
        }else{
            
            guestReady = true;
        }
        
        lblOpponentDeviceName.text = appDelegate.multiplayerSession.playerName;
        updateResumeInfo()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateResumeInfo", name: "updateResumeInfo", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateScoreBoard", name: "updateScoreBoard", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideScoreBoard", name: "hideScoreBoard", object: nil);
        
        if( Constants.LITE_VERSION ){
            
            if( appDelegate.bannerType == "apple" ){
                
                if( Constants.DeviceIdiom.IS_IPAD ){
                    
                    iAdBannerView.frame  = CGRectMake(0, 702, 1024, 60);
                }else{
                    
                    iAdBannerView.frame  = CGRectMake(0, 0, 320, 50);
                }
                
                iAdBannerView.contentMode = UIViewContentMode.Center;
                iAdBannerView.frame.origin.y = Util.getScreenHeight(self.view) - iAdBannerView.frame.size.height;
                iAdBannerView.hidden = false;
                self.view.addSubview(iAdBannerView);
            }else{
                
                var bannerView_ : GADBannerView!;
                var adSize = kGADAdSizeBanner;
                
                if( Constants.DeviceIdiom.IS_IPAD ){
                    
                    adSize = kGADAdSizeSmartBannerLandscape;
                }
                
                bannerView_ = GADBannerView(adSize: adSize);
                bannerView_.adUnitID = "ca-app-pub-0504466650636760/9001922550";
                bannerView_.rootViewController = self;
                self.view.addSubview(bannerView_);
                bannerView_.loadRequest(GADRequest());
                
                bannerView_.frame.origin.y = self.view.frame.size.height - bannerView_.frame.size.height;
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        skView.paused = true;
        super.viewDidDisappear(animated);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateScoreBoard", object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "hideScoreBoard", object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateResumeInfo", object: nil);
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func createRandomPath(){
        
        if( playedGames > 0 && playedGames % 10 == 0 ){
            
            changeDifficulty()
        }
        
        var randomBlocks : Int = 0;
        
        do{
            
            do{
                
                randomBlocks = Int(arc4random_uniform(UInt32(maxRandomBlocks)));
            }while( randomBlocks < minRandomBlocks )
            
            gameScene.gamePath = RandomGameStage.getRandomPath(randomBlocks, horizontalBlocks: gameScene.horizontalBlocks, verticalBlocks: gameScene.verticalBlocks, bounds: self.view.bounds);
        }while( gameScene.gamePath.count < randomBlocks );
        
        gameLevel.addStage(gameScene.gamePath);
        gameLevel.currentStage = gameLevel.stages()-1;
        
        gameReady = true;
    }
    
    func invalidateSkViewPauseTimer(){
        
        if( skViewPauseTimer != nil ){
            
            skViewPauseTimer.invalidate();
        }
    }
    
    @IBAction func startGame(){

        invalidateSkViewPauseTimer();
        
        gameLevel.currentStage = gameLevel.stages()-1;
        
        gameScene.gameLevel = gameLevel;
        gameScene.gameStage = gameLevel.getStage();
        gameScene.gamePath  = gameLevel.getStage().gamePath;
        
        gameScene.gameStage.setMinStars(gameLevel.timeDeduction);
        
        hideScoreBoard();
        
        lblLoading.hidden = true;
        loadingActivityIndicator.hidden = true;
        btnShowMenu.hidden = true;
        
        hostReady  = false;
        guestReady = false;
        imReady    = false;
        gameReady  = false;
        
        playedGames++
        updateResumeLabels();
        
        skView.paused = false;
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: gameScene, selector: Selector("startGame"), userInfo: nil, repeats: false);
    }
    
    @IBAction func setReady(){
        
        hideScoreBoard();
        gameScene.clearAllBlocks();
        
        lblLoading.hidden = false;
        loadingActivityIndicator.hidden = false;
        btnShowMenu.hidden = true;
        imReady = true;
        
        if( appDelegate.multiplayerSession.multiplayerInstance == "host" ){
            
            createRandomPath();
            sendMessageToOtherPlayer("gamePath", message: gameLevel.getStage().getPathToArchive());
            
            hostReady = true;
        }else{
            
            guestReady = true;
            sendMessageToOtherPlayer("message", message: "guestReady");
            handleStartGame()
        }
    }
    
    @IBAction func restartStage(sender: AnyObject) {
        
        gameScene.restartStage();
        
        hideScoreBoard();
        gameScene.clearAllBlocks();
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: gameScene, selector: Selector("startGame"), userInfo: nil, repeats: false);
    }
    
    @IBAction func showMainMenu(sender: AnyObject){
        
        stopMultiplayerGame();
    }
    
    func changeDifficulty() {
        
        switch( difficulty ){
        case "Fish":
            difficulty = "Dolphin";
            gameLevel.flashDuration = 1.5;
            gameLevel.timeDeduction = 20;
            gameLevel.blinkFirst    = true;
            gameLevel.blinkLast     = true;
            
            minRandomBlocks = 18;
            maxRandomBlocks = 24;
            break;
        case "Dolphin":
            difficulty = "Human";
            gameLevel.flashDuration = 1.0;
            gameLevel.timeDeduction = 30;
            gameLevel.blinkFirst    = true;
            gameLevel.blinkLast     = false;
            
            minRandomBlocks = 23;
            maxRandomBlocks = 26;
            break;
        case "Human":
            difficulty = "Elephant";
            gameLevel.flashDuration = 0.5;
            gameLevel.timeDeduction = 50;
            gameLevel.blinkFirst    = false;
            gameLevel.blinkLast     = false;
            
            minRandomBlocks = 25;
            maxRandomBlocks = 35;
            break;
        case "Elephant":
            difficulty = "Fish";
            gameLevel.flashDuration = 2.0;
            gameLevel.timeDeduction = 10;
            gameLevel.blinkFirst    = true;
            gameLevel.blinkLast     = true;
            
            minRandomBlocks = 15;
            maxRandomBlocks = 20;
            break;
        default:
            break;
        }
        
        if( appDelegate.multiplayerSession.multiplayerInstance == "host" ){
            
            sendMessageToOtherPlayer("levelChange", message: difficulty);
        }
    }
    
    func updateResumeInfo(){
        
        hideScoreBoard()
        updateResumeLabels();
    }
    
    func updateResumeLabels(){
        
        var difficultyLocalized = NSLocalizedString("difficulty.\(difficulty)", comment: "")
        
        lblDifficulty.text = String(format: NSLocalizedString("Level", comment: "") + " " + difficultyLocalized + " (%02d)", playedGames);
        lblCurrentScore.text = String(format: NSLocalizedString("Me", comment: "") + " %07d", gameScene.mainScore);
        lblCurrentScoreOpponent.text = String(format: "\(appDelegate.multiplayerSession.playerName) %07d", mainScoreOpponent);
    }
    
    
    
    
    
    
    func stopMultiplayerGame(){
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "MultiplayerSessionClosed", object: nil);
        
        sendMessageToOtherPlayer("message", message: "_end_game_");
        appDelegate.multiplayerSession.stopSession();
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func showScoreBoard(){
        
        skView.paused = true;
        
        if( vwScoreBoard.tag == 0 ){
            
            vwScoreBoard.tag = 1;
            self.view.addSubview(vwScoreBoard);
            vwScoreBoard.frame = CGRectMake(62, 121, 900, 525);
        }
        
        vwScoreBoard.hidden = false;
        
        UIView.animateWithDuration(0.5, animations: {
            self.vwScoreBoard.alpha = 1.0
            self.lblDifficulty.alpha = 0;
            self.lblCurrentScore.alpha = 0;
            self.lblCurrentScoreOpponent.alpha = 0;
        })
    }
    
    func hideScoreBoard(){
        
        if( vwScoreBoard.tag == 0 ){
            return;
        }
        
        imgStar1.hidden     = true;
        imgStar2.hidden     = true;
        imgStar3.hidden     = true;
        
        imgStar1Opponent.hidden     = true;
        imgStar2Opponent.hidden     = true;
        imgStar3Opponent.hidden     = true;
        
        vwScoreBoard.hidden = true;
        
        UIView.animateWithDuration(0.5, animations: {
            self.vwScoreBoard.alpha = 0.0
            }, completion: { (flag: Bool) -> Void in
                
                self.vwScoreBoard.tag = 0;
                self.vwScoreBoard.removeFromSuperview();
                
                self.lblDifficulty.alpha           = 1.0;
                self.lblCurrentScore.alpha         = 1.0;
                self.lblCurrentScoreOpponent.alpha = 1.0;
        });
        
        lblTotalBlocksOpponent.text  = "-";
        lblRightBlocksOpponent.text  = "-";
        lblWrongBlocksOpponent.text  = "-";
        lblMissedBlocksOpponent.text = "-";
        lblTimeBonusOpponent.text    = "-";
        
        lblRightBlocksScoreOpponent.text  = "-";
        lblWrongBlocksScoreOpponent.text  = "-";
        lblMissedBlocksScoreOpponent.text = "-";
        lblPerfectBonusOpponent.text      = "-";
        lblTimeBonusScoreOpponent.text    = "-";
        lblDeductionsOpponent.text        = "-";
        lblStageScoreOpponent.text        = "-";
        
        gameScene.removeAllActions();
    }
    
    func showStars(star1: Bool, star2: Bool, star3: Bool){
        
        imgStar1.hidden = false;
        imgStar2.hidden = false;
        imgStar3.hidden = false;
        
        imgStar1.alpha = 0.0;
        imgStar2.alpha = 0.0;
        imgStar3.alpha = 0.0;
        
        if( star1 ){
            
            UIView.animateWithDuration(0.5, delay: 1.75, options: nil, animations: {
                self.imgStar1.alpha = 1.0;
                }, completion: nil);
            
            self.gameScene.playSound("star-1", delay: 1.75);
        }
        
        if( star2 ){
            
            UIView.animateWithDuration(0.5, delay: 2.55, options: nil, animations: {
                self.imgStar2.alpha = 1.0;
                }, completion: nil);
            
            self.gameScene.playSound("star-2", delay: 2.55);
        }
        
        if( star3 ){
            
            UIView.animateWithDuration(0.5, delay: 3.35, options: nil, animations: {
                self.imgStar3.alpha = 1.0;
                }, completion: nil);
            
            self.gameScene.playSound("star-3", delay: 3.35);
        }
    }
    
    func showStarsOpponent(star1: Bool, star2: Bool, star3: Bool){
        
        imgStar1Opponent.hidden = false;
        imgStar2Opponent.hidden = false;
        imgStar3Opponent.hidden = false;
        
        imgStar1Opponent.alpha = 0.0;
        imgStar2Opponent.alpha = 0.0;
        imgStar3Opponent.alpha = 0.0;
        
        if( star1 ){
            
            UIView.animateWithDuration(0.5, delay: 1.75, options: nil, animations: {
                self.imgStar1Opponent.alpha = 1.0;
                }, completion: nil);
        }
        
        if( star2 ){
            
            UIView.animateWithDuration(0.5, delay: 2.55, options: nil, animations: {
                self.imgStar2Opponent.alpha = 1.0;
                }, completion: nil);
        }
        
        if( star3 ){
            
            UIView.animateWithDuration(0.5, delay: 3.35, options: nil, animations: {
                self.imgStar3Opponent.alpha = 1.0;
                }, completion: nil);
        }
    }
    
    func updateScoreBoard(){
        
        var gameLevel = gameScene.gameLevel;
        var gameStage = gameScene.gameStage;
        
        gameStage.timeBonus = gameStage.elapsedTime * gameLevel.timeDeduction * -1;
        
        gameStage.stageScore = (gameStage.rightBlocks * Score.RIGHT_BLOCK_SCORE - gameStage.wrongBlocks * Score.WRONG_BLOCK_SCORE - gameStage.missedBlocks * Score.MISSED_BLOCK_SCORE) + gameStage.timeBonus + gameStage.perfectBonus;
        gameStage.deductions = (gameStage.wrongBlocks * Score.WRONG_BLOCK_SCORE + gameStage.missedBlocks * Score.MISSED_BLOCK_SCORE) - gameStage.timeBonus;

        gameScene.mainScore += gameStage.stageScore;
        
        showScoreBoard();
        
        var newScoreBlocks : Int = gameStage.rightBlocks - gameStage.wrongBlocks - gameStage.missedBlocks;
        var oldScoreBlocks : Int = gameStage.bestRightBlocks - gameStage.bestWrongBlocks - gameStage.bestMissedBlocks;
        
        if( newScoreBlocks > oldScoreBlocks ){
            
            gameStage.bestRightBlocks  = gameStage.rightBlocks;
            gameStage.bestWrongBlocks  = gameStage.wrongBlocks;
            gameStage.bestMissedBlocks = gameStage.missedBlocks;
        }
        
        var star1: Bool = gameStage.stageScore >= gameStage.min1Star;
        var star2: Bool = gameStage.stageScore >= gameStage.min2Stars;
        var star3: Bool = gameStage.stageScore >= gameStage.min3Stars;
        var stars: Int  = (star3 ? 3 : (star2 ? 2 : (star1 ? 1 : 0)));
        
        if( stars > gameStage.stars ){
            
            gameStage.stars = stars;
        }
        
        if( star1 ){
            
            showStars(star1, star2: star2, star3: star3);
            
            skView.paused = false;
            let delay : Double = (star3 ? 4.15 : (star2 ? 3.35 : (star1 ? 2.55 : 0)));
            skViewPauseTimer = NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: Selector("pauseSkView"), userInfo: nil, repeats: false);
        }else{
            
            skView.paused = true;
        }
        
        lblTotalBlocks.text  = "\(gameStage.gamePath.count)";
        lblRightBlocks.text  = "\(gameStage.rightBlocks)";
        lblWrongBlocks.text  = "\(gameStage.wrongBlocks)";
        lblMissedBlocks.text = "\(gameStage.missedBlocks)";
        lblTimeBonus.text    = "\(Util.formatTimeString(Float(gameStage.elapsedTime)))";
        
        lblMainScore.countFromCurrentValueTo(Float(gameScene.mainScore), withDuration: 1.5);
        lblRightBlocksScore.countFrom(0, to: Float(gameStage.rightBlocks * Score.RIGHT_BLOCK_SCORE), withDuration: 1.5);
        lblWrongBlocksScore.countFrom(0, to: Float(gameStage.wrongBlocks * -Score.WRONG_BLOCK_SCORE), withDuration: 1.5);
        lblMissedBlocksScore.countFrom(0, to: Float(gameStage.missedBlocks * -Score.MISSED_BLOCK_SCORE), withDuration: 1.5);
        lblPerfectBonus.countFrom(0, to: Float(gameStage.perfectBonus), withDuration: 1.5);
        lblTimeBonusScore.countFrom(0, to: Float(gameStage.timeBonus), withDuration: 1.5);
        lblDeductions.countFrom(0, to: Float(gameStage.deductions), withDuration: 1.5);
        lblStageScore.countFrom(0, to: Float(gameStage.stageScore), withDuration: 1.5);
        
        if( gameScene.mainScore > bestMainScore ){
            
            bestMainScore = gameScene.mainScore
            (appDelegate.window?.rootViewController as! GameViewController).updateGKScoreBoard(self.leaderboardIdentifier, score: gameScene.mainScore);
        }
        
        sendMessageToOtherPlayer("updateScore", message: gameLevel.getStage().getDictionary());
        updateResumeLabels()
    }
    
    func pauseSkView(){
        
        skView.paused = true;
    }
    
    func updateScoreBoardOpponent(){
        
        var gameStage = gameStageOpponent;
        
        mainScoreOpponent += gameStage.stageScore;
        
        var newScoreBlocks : Int = gameStage.rightBlocks - gameStage.wrongBlocks - gameStage.missedBlocks;
        var oldScoreBlocks : Int = gameStage.bestRightBlocks - gameStage.bestWrongBlocks - gameStage.bestMissedBlocks;
        
        if( newScoreBlocks > oldScoreBlocks ){
            
            gameStage.bestRightBlocks  = gameStage.rightBlocks;
            gameStage.bestWrongBlocks  = gameStage.wrongBlocks;
            gameStage.bestMissedBlocks = gameStage.missedBlocks;
        }
        
        var star1: Bool = gameStage.stageScore >= gameStage.min1Star;
        var star2: Bool = gameStage.stageScore >= gameStage.min2Stars;
        var star3: Bool = gameStage.stageScore >= gameStage.min3Stars;
        var stars: Int  = (star3 ? 3 : (star2 ? 2 : (star1 ? 1 : 0)));
        
        if( stars > gameStage.stars ){
            
            gameStage.stars = stars;
        }
        
        if( star1 ){
            
            showStarsOpponent(star1, star2: star2, star3: star3);
        }
        
        lblTotalBlocksOpponent.text  = "\(gameStage.gamePath.count)";
        lblRightBlocksOpponent.text  = "\(gameStage.rightBlocks)";
        lblWrongBlocksOpponent.text  = "\(gameStage.wrongBlocks)";
        lblMissedBlocksOpponent.text = "\(gameStage.missedBlocks)";
        lblTimeBonusOpponent.text    = "\(Util.formatTimeString(Float(gameStage.elapsedTime)))";
        
        lblMainScoreOpponent.countFromCurrentValueTo(Float(mainScoreOpponent), withDuration: 1.5);
        lblRightBlocksScoreOpponent.countFrom(0, to: Float(gameStage.rightBlocks * Score.RIGHT_BLOCK_SCORE), withDuration: 1.5);
        lblWrongBlocksScoreOpponent.countFrom(0, to: Float(gameStage.wrongBlocks * -Score.WRONG_BLOCK_SCORE), withDuration: 1.5);
        lblMissedBlocksScoreOpponent.countFrom(0, to: Float(gameStage.missedBlocks * -Score.MISSED_BLOCK_SCORE), withDuration: 1.5);
        lblPerfectBonusOpponent.countFrom(0, to: Float(gameStage.perfectBonus), withDuration: 1.5);
        lblTimeBonusScoreOpponent.countFrom(0, to: Float(gameStage.timeBonus), withDuration: 1.5);
        lblDeductionsOpponent.countFrom(0, to: Float(gameStage.deductions), withDuration: 1.5);
        lblStageScoreOpponent.countFrom(0, to: Float(gameStage.stageScore), withDuration: 1.5);
        
        updateResumeLabels()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func sendMessageToOtherPlayer(key: String, message: AnyObject) {
        
        appDelegate.multiplayerSession.mainScore = gameScene.mainScore;
        
        let messageDictionary = ["key": key, "message": message];
        appDelegate.multiplayerSession.sendMessage(messageDictionary, timeDeduction: gameLevel.timeDeduction);
    }
    
    func handleMultiplayerSessionIncomingMessage(notification: NSNotification) {
        
        // Get the dictionary containing the data and the source peer from the notification.
        let dataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        let key : String! = dataDictionary["key"] as! String;
        
        // Check if there's an entry with the "message" key.
        if( key != nil ){
            // Make sure that the message is other than "_end_chat_".
            
            if( key == "message" ){
                
                let message : String! = dataDictionary["message"] as! String!;
                
                if( message == "_end_game_" ){
                    
                    self.stopMultiplayerGame();

                    var alertView = UIAlertView(title: NSLocalizedString("Multiplayer closed", comment: ""), message: "\(appDelegate.multiplayerSession.playerName) "+NSLocalizedString("closed multiplayer session.", comment:""), delegate: self, cancelButtonTitle: NSLocalizedString("No", comment: ""));
                    
                    alertView.show();
                    
                    return;
                }
                
                switch( message ){
                case "guestReady":
//                    println("message: guestReady");
                    guestReady = true;
                    handleStartGame();
                    break;
                default:
                    break;
                }
            }else if( key == "gamePath" ){
                
//                println("message: gamePath");
                
                var gameStage = GameStage();
                
                let message : Array<String>! = dataDictionary["message"] as! Array<String>;
                let gamePath : Array<CGPoint> = gameStage.getPathFromArchive(message);
                
                gameLevel.addStage(gamePath);
                
                hostReady = true;
                gameReady = true;
                
                if( imReady ){
                    
                    sendMessageToOtherPlayer("message", message: "guestReady");
                    handleStartGame()
                }
            }else if( key == "updateScore" ){
                
                gameStageOpponent = GameStage.loadFromDictionary(dataDictionary["message"] as! NSDictionary);
                
//                println("RECEIVING: updateScore: \(gameStageOpponent)");
                
                updateScoreBoardOpponent()
            }else if( key == "levelChange" ){
                
//                println("message: levelChange");
                
                if( !imReady ){
                    
                    // Coloquei isos aqui para o caso de o jogador HOST iniciar um novo jogo trocando o nível e o GUEST ainda está jogando o nível anterior
                    // para evitar que se calcule os pontos com base no novo nível quando deveria calcular com base nos parametros do nível anterior (atual do guest)
                    pendingLevelChange = true;
                }else{
                    
                    changeDifficulty();
                    updateResumeLabels();
                }
            }
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    }
    
    func handleStartGame(){
        
//        println("imReady: \(imReady) && hostReady: \(hostReady) && guestReady: \(guestReady) && gameReady: \(gameReady)");
        
        if( imReady && hostReady && guestReady && gameReady ){
            
            if( pendingLevelChange ){
                
                pendingLevelChange = false;
                changeDifficulty();
                updateResumeLabels();
            }
            
            startGame();
//            println("--------------------\nSTART GAME\n--------------------");
        }
    }
}
