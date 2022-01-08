//
//  GameViewController.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 24/03/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import UIKit
import SpriteKit
import iAd
import GameKit;

class GameViewController: UIViewController, GKGameCenterControllerDelegate, ADBannerViewDelegate, UIAlertViewDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

    var gameScene : GameScene!;
    var skView : SKView!;
    @IBOutlet var iAdBannerView: ADBannerView!
    @IBOutlet weak var btnStartGame: UIButton!
    @IBOutlet weak var btnShowMenu: UIButton!
    @IBOutlet weak var btnCreator: UIButton!
    @IBOutlet weak var btnRestartStage: UIButton!
    @IBOutlet weak var btnSoundEffects: UIButton!
    @IBOutlet weak var btnNextStage: UIButton!
    @IBOutlet weak var btnMultiplayer: UIButton!
    @IBOutlet weak var btnPractice: UIButton!
    @IBOutlet weak var btnInstructions: UIButton!
    @IBOutlet weak var vwMainMenu: UIView!
    @IBOutlet weak var vwScoreBoard: UIView!
    @IBOutlet weak var lblTotalBlocks: UILabel!
    @IBOutlet weak var lblRightBlocks: UILabel!
    @IBOutlet weak var lblWrongBlocks: UILabel!
    @IBOutlet weak var lblMissedBlocks: UILabel!
    @IBOutlet weak var lblTimeBonus: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblStage: UILabel!
    
    @IBOutlet weak var lblCurrentStage: UILabel!
    @IBOutlet weak var lblCurrentLevel: UILabel!
    @IBOutlet weak var lblCurrentMainScore: UILabel!
    
    @IBOutlet weak var lblMainScore: UICountingLabel!
    @IBOutlet weak var lblStageScore: UICountingLabel!
    @IBOutlet weak var lblRightBlocksScore: UICountingLabel!
    @IBOutlet weak var lblWrongBlocksScore: UICountingLabel!
    @IBOutlet weak var lblMissedBlocksScore: UICountingLabel!
    @IBOutlet weak var lblPerfectBonus: UICountingLabel!
    @IBOutlet weak var lblTimeBonusScore: UICountingLabel!
    @IBOutlet weak var lblDeductions: UICountingLabel!
    
    @IBOutlet weak var imgBestScore: UIImageView!
    
    @IBOutlet weak var imgStar1: UIImageView!
    @IBOutlet weak var imgStar2: UIImageView!
    @IBOutlet weak var imgStar3: UIImageView!
    
    var gameCenterEnabled : Bool = false;
    var leaderboardIdentifier : String!;
    var localPlayer : GKLocalPlayer!;
    
    var observersSettedUp : Bool = false;
    var skViewPauseTimer : NSTimer!;
    
    @IBOutlet weak var levelMenuView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gameScene = GameScene.unarchiveFromFile("GameScene") as? GameScene;
        gameScene.size = CGSizeMake(Util.getScreenWidth(self.view), Util.getScreenHeight(self.view));
        
        if gameScene != nil {
            
            skView = self.view as! SKView

//            skView.showsFPS = true
//            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            gameScene.scaleMode = .AspectFill
            gameScene.loadStage(appDelegate.gameLevelList[appDelegate.currentLevel], unlock: true);
            gameScene.mainScore = GameLevel.getCurrentMainScore(appDelegate.gameLevelList);
            gameScene.soundEffects = appDelegate.soundEffects;

            skView.presentScene(gameScene)
            skView.paused = true;
        }
        
        authenticateLocalPlayer();
        
        vwScoreBoard.hidden = true;
        lblMainScore.format = "%07d";
        
        updateResumeInfo();
        
        lblMainScore.method         = UILabelCountingMethodLinear;
        lblRightBlocksScore.method  = UILabelCountingMethodLinear;
        lblWrongBlocksScore.method  = UILabelCountingMethodLinear;
        lblMissedBlocksScore.method = UILabelCountingMethodLinear;
        lblPerfectBonus.method      = UILabelCountingMethodLinear;
        lblTimeBonusScore.method    = UILabelCountingMethodLinear;
        lblDeductions.method        = UILabelCountingMethodLinear;
        lblStageScore.method        = UILabelCountingMethodLinear;
        
        btnSoundEffects.setTitle(NSLocalizedString("SOUND EFFECTS: ", comment: "") + (appDelegate.soundEffects ? NSLocalizedString("ON", comment: "") : NSLocalizedString("OFF", comment: "")), forState: UIControlState.Normal);
        btnSoundEffects.tag = (appDelegate.soundEffects ? 1 : 0);
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadMultiplayerStoryboard", name: "loadMultiplayerStoryboard", object: nil);
        
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
        
        if( Constants.DeviceIdiom.IS_IPHONE ){

            btnCreator.frame.origin.x = vwMainMenu.frame.origin.x;
            btnCreator.frame.origin.y = vwMainMenu.frame.origin.y + vwMainMenu.frame.size.height;
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        skView.paused = true;
        
        super.viewDidDisappear(animated);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateResumeInfo", object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateScoreBoard", object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "hideScoreBoard", object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "loadMultiplayerStoryboard", object: nil);
        
        observersSettedUp = false;
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.Landscape.rawValue)
        }
    }
    
//    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
//
//        if( motion == UIEventSubtype.MotionShake ){
//
//            btnCreator.hidden = false;
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func didFailToReceiveAdWithError(){
        
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if( (segue.identifier == "MultiplayerSegueLeft" || segue.identifier == "MultiplayerSegueUp") && Constants.IOS_VERSION < 8.0 ){
            
            let popoverSegue = segue as! UIStoryboardPopoverSegue;
            let mvc = (segue.destinationViewController as! UINavigationController).viewControllers.first as! PlayersViewController;
            mvc.parentPopover = popoverSegue.popoverController;
        }
    }
    
    func authenticateLocalPlayer() {
        
        localPlayer = GKLocalPlayer.localPlayer();
        
        if localPlayer.authenticateHandler == nil {
            localPlayer.authenticateHandler = { (gameCenterViewController: UIViewController?, gameCenterError: NSError?) in
                if let gameCenterError = gameCenterError {
//                    println("Game Center Error: \(gameCenterError.localizedDescription)")
                }
                
                if let gameCenterViewControllerToPresent = gameCenterViewController {
                    self.presentGameCenterController(gameCenterViewControllerToPresent)
                }
                else if self.localPlayer.authenticated {
                    // Enable GameKit features
                    
                    self.gameCenterEnabled = true;
                    self.appDelegate.playerGKNickname = self.localPlayer.alias;
                    
                    self.localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier: String!, error: NSError!) -> Void in
                        
                        if( error != nil ){
//                            println("GKError: \(error.description)");
                        }else{
                            self.leaderboardIdentifier = leaderboardIdentifier;
                        }
                    });
                    
//                    println("Player already authenticated")
                }
                else {
                    // Disable GameKit features
//                    println("Player not authenticated")
                }
            }
        }
        else {
//            println("Authentication Handler already set")
        }
    }
    
    func testForGameCenterDismissal() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC))), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            if let presentedViewController = self.presentedViewController {
//                println("Still presenting game center login")
                self.testForGameCenterDismissal()
            }
            else {
//                println("Done presenting, clean up")
                self.gameCenterViewControllerCleanUp()
            }
        }
    }
    
    func presentGameCenterController(viewController: UIViewController) {
        var testForGameCenterDismissalInBackground = true
        
        if let gameCenterViewController = viewController as? GKGameCenterViewController {
            gameCenterViewController.gameCenterDelegate = self
            testForGameCenterDismissalInBackground = false
        }
        
        presentViewController(viewController, animated: true) { () -> Void in
            if testForGameCenterDismissalInBackground {
                self.testForGameCenterDismissal()
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewControllerCleanUp()
    }
    
    func gameCenterViewControllerCleanUp() {
        
    }
    
    func updateGKScoreBoard(){
        
        if( !gameCenterEnabled || localPlayer == nil ){
        
            return;
        }
        
        if( localPlayer.authenticated ){
        
            if( gameScene.mainScore > appDelegate.bestMainScore ){
                
                appDelegate.bestMainScore = gameScene.mainScore;
                appDelegate.saveUserDefaults();
                
                // iOS 8.0+
//                let gkScore = GKScore(leaderboardIdentifier: self.leaderboardIdentifier, player: localPlayer)
                let gkScore = GKScore(leaderboardIdentifier: self.leaderboardIdentifier, forPlayer: localPlayer.playerID);
                gkScore.value  = Int64(gameScene.mainScore)
                
                gkScore.shouldSetDefaultLeaderboard = true
                
                GKScore.reportScores([gkScore], withCompletionHandler: ( {
                    (error: NSError!) -> Void in
                    
                    if( error != nil ){
                        
                    } else {
                        
                    }
                }));
            }
            
            self.updateGKAchievements();
        }
    }
    
    func updateGKScoreBoard(leaderboardIdentifier: String, score: Int){
        
        if( !gameCenterEnabled || localPlayer == nil ){
            
            return;
        }
        
        if( localPlayer.authenticated ){
            
            let gkScore   = GKScore(leaderboardIdentifier: self.leaderboardIdentifier, forPlayer: localPlayer.playerID);
            gkScore.value = Int64(score)
            
            gkScore.shouldSetDefaultLeaderboard = false;
            
            GKScore.reportScores([gkScore], withCompletionHandler: ( {
                (error: NSError!) -> Void in
                
                if( error != nil ){
                    
                } else {
                    
                }
            }));
        }
    }
    
    func updateGKAchievements(){
        
        var achievements = appDelegate.getAchievements(localPlayer);
        
        GKAchievement.reportAchievements(achievements, withCompletionHandler: { (error: NSError!) -> Void in
            if( error != nil ){
//                println("Erro ao registrar a conquista");
            }else{
//                println("Conquistas registradas!");
            }
        });
    }
    
    @IBAction func showMainMenu(sender: AnyObject) {
        
        updateResumeLabels();
        hideScoreBoard();
        hideLevelMenu(true);
    }
    
    @IBAction func showLevelMenu(sender: AnyObject) {
        
        hideScoreBoard();
        levelMenuView.hidden = false;

        btnCreator.hidden = true;
        vwMainMenu.hidden = true;

        self.view.addSubview(levelMenuView)
        
        if( Constants.DeviceIdiom.IS_IPHONE ){
            
            levelMenuView.frame.size.width  = 288;
            levelMenuView.frame.size.height = 420;
        }
        
        levelMenuView.frame.origin.x = (Util.getScreenWidth(self.view) / 2) - (levelMenuView.frame.size.width / 2);
        levelMenuView.frame.origin.y = (Util.getScreenHeight(self.view) / 2) - (levelMenuView.frame.size.height / 2);
    }
    
    
    func hideLevelMenu(showButtons: Bool) {
        
        levelMenuView.hidden = true;
        
        btnStartGame.enabled = showButtons;
        vwMainMenu.hidden    = !showButtons;
        
        levelMenuView.removeFromSuperview();
    }
    
    func setupObservers(){
        
        if( observersSettedUp ){
            
            return;
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateResumeInfo", name: "updateResumeInfo", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateScoreBoard", name: "updateScoreBoard", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideScoreBoard", name: "hideScoreBoard", object: nil);
            
        observersSettedUp = true;
    }
    
    func invalidateSkViewPauseTimer(){
        
        if( skViewPauseTimer != nil ){
            
            skViewPauseTimer.invalidate();
        }
    }
    
    @IBAction func startGame(sender: AnyObject) {

        skView.paused = false;
        
        invalidateSkViewPauseTimer();
        
        setupObservers();
        
        gameScene.startGame();
        btnStartGame.enabled = false;
        btnCreator.hidden    = true;
        vwMainMenu.hidden    = true;
    }
    
    @IBAction func restartStage(sender: AnyObject) {
        
        skView.paused = false;
        
        invalidateSkViewPauseTimer();
        
        setupObservers()
        
        gameScene.restartStage();
        updateResumeLabels()
        
        hideScoreBoard();
        gameScene.clearAllBlocks();
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: gameScene, selector: Selector("startGame"), userInfo: nil, repeats: false);
    }
    
    @IBAction func loadNextStage(sender: AnyObject) {
        
        invalidateSkViewPauseTimer();
        
        if( !hasNextStage() ){
            
            var mainAlertView : UIAlertView!;
            
            if( Constants.LITE_VERSION ){
             
                mainAlertView = UIAlertView(title: NSLocalizedString("CONTRATULATIONS!", comment: ""), message: NSLocalizedString("You've completed all stages of LITE VERSION.\nWould you like to upgrade to full version and unlock all levels?", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("Not now", comment: ""), otherButtonTitles: NSLocalizedString("Upgrade", comment: ""));
            }else{
                
                mainAlertView = UIAlertView(title: NSLocalizedString("CONTRATULATIONS!", comment: ""), message: NSLocalizedString("You've completed all stages. Try starting over reaching 3 stars in all levels.", comment: ""), delegate: self, cancelButtonTitle: "OK");
            }
            
            
            mainAlertView.show()
            return;
        }
        
        
        // -------- GAME SCENE ---------
        gameScene.clearAllBlocks();
        
        if( !gameScene.gameLevel.nextStage(Constants.LITE_VERSION) ){
            
            gameScene.gameLevel = appDelegate.gameLevelList[gameScene.gameLevel.levelNumber];
            gameScene.gameLevel.currentStage = 0;
            gameScene.gameLevel.getStage();
        }
        
        appDelegate.currentLevel = gameScene.gameLevel.levelNumber-1;
        appDelegate.currentStage = gameScene.gameLevel.currentStage;
        appDelegate.saveUserDefaults();
        
        gameScene.updateResumeInfo()
        gameScene.loadStage(appDelegate.gameLevelList[appDelegate.currentLevel], unlock: true);
        // -------- GAME SCENE ---------
        
        
        btnStartGame.enabled = false;
        btnCreator.hidden    = true;
        vwMainMenu.hidden    = true;
        
        skView.paused = false;
        
        setupObservers()
        
        gameScene.clearAllBlocks();
        hideScoreBoard()
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: gameScene, selector: Selector("startGame"), userInfo: nil, repeats: false);
    }
    
    @IBAction func loadMultiplayerMode(sender: AnyObject) {
        
//        if( appDelegate.LITE_VERSION ){
//            
//            var alertView = UIAlertView(title: NSLocalizedString("Feature unavailable", comment: ""), message: NSLocalizedString("Multiplayer mode is only available in the full version of the game.\nWould you like to upgrade?", comment:""), delegate: self, cancelButtonTitle: NSLocalizedString("Not now", comment: ""), otherButtonTitles: NSLocalizedString("Upgrade", comment: ""));
//            
//            alertView.show();
//            return;
//        }
        
        if( Constants.IOS_VERSION < 8.0 ){
            
            self.performSegueWithIdentifier("MultiplayerSegueLeft", sender: sender);
        }else{

            self.performSegueWithIdentifier("MultiplayerSegueUp", sender: sender);
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if( buttonIndex == 1 ){
            
            let appUrl = String(format: "\(Constants.APP_URL)", appDelegate.language);
            
            UIApplication.sharedApplication().openURL(NSURL(string: appUrl)!);
        }
    }
    
    @IBAction func loadLevelCreator(sender: AnyObject) {
        
        var storyboardName = Constants.DeviceIdiom.IS_IPAD ? "Creator" : "Creator_iPhone";
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil);
        let vc         = storyboard.instantiateInitialViewController() as! CreatorViewController;
        
        vc.isModal = true;
        
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
    @IBAction func loadPracticeMode(sender: AnyObject) {
        
        var storyboardName = Constants.DeviceIdiom.IS_IPAD ? "Practice" : "Practice_iPhone";
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil);
        let vc         = storyboard.instantiateInitialViewController() as! PracticeViewController;
        
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
    func loadMultiplayerStoryboard() {

        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        let storyboard = UIStoryboard(name: "Multiplayer", bundle: nil)
        let vc         = storyboard.instantiateInitialViewController() as! MultiplayerViewController;
        
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
    func loadMultiplayerOnlineStoryboard() {
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        var storyboardName = Constants.DeviceIdiom.IS_IPAD ? "MultiplayerOnline" : "MultiplayerOnline_iPhone";
        let storyboard     = UIStoryboard(name: storyboardName, bundle: nil)
        let vc             = storyboard.instantiateInitialViewController() as! MultiplayerOnlineViewController;
        
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
    @IBAction func loadInstructionsStoryboard(sender: AnyObject) {
        
        var storyboardName = Constants.DeviceIdiom.IS_IPAD ? "Instructions" : "Instructions_iPhone";
        let storyboard     = UIStoryboard(name: storyboardName, bundle: nil);
        let vc             = storyboard.instantiateInitialViewController() as! InstructionsViewController;
        
        vc.soundEffects = appDelegate.soundEffects;
        
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
    @IBAction func toggleSoundEffects(sender: AnyObject) {
        
        if( btnSoundEffects.tag == 1 ){
            
            appDelegate.soundEffects = false;
            btnSoundEffects.tag = 0;
            btnSoundEffects.setTitle(NSLocalizedString("SOUND EFFECTS: OFF", comment: ""), forState: UIControlState.Normal)
        }else{
            
            appDelegate.soundEffects = true;
            btnSoundEffects.tag = 1;
            btnSoundEffects.setTitle(NSLocalizedString("SOUND EFFECTS: ON", comment: ""), forState: UIControlState.Normal)
        }
        
        gameScene.soundEffects = appDelegate.soundEffects;
    }
    
    func hasNextStage() -> Bool {
        
        if( Constants.LITE_VERSION ){

            if( appDelegate.currentStage < 5 ){
                
                return true;
            }
            
            if( appDelegate.gameLevelList.count > appDelegate.currentLevel+1 &&
                appDelegate.gameLevelList[appDelegate.currentLevel+1].stages() > 0 ){
                    
                    return true;
            }
            
            return false;
        }
        
        if( gameScene.gameLevel.stages() > appDelegate.currentStage+1 ){
            
            return true;
        }
        
        if( appDelegate.gameLevelList.count > appDelegate.currentLevel+1 &&
            appDelegate.gameLevelList[appDelegate.currentLevel+1].stages() > 0 ){
                
                return true;
        }
        
        return false;
    }
    
    func showScoreBoard(){
        
        if( vwScoreBoard.tag == 0 ){
         
            vwScoreBoard.tag = 1;
            self.view.addSubview(vwScoreBoard);
            vwScoreBoard.frame.origin.x = (Util.getScreenWidth(self.view) / 2) - (vwScoreBoard.frame.width / 2);
            vwScoreBoard.frame.origin.y = (Util.getScreenHeight(self.view) / 2) - (vwScoreBoard.frame.height / 2) + ( Constants.DeviceType.IS_IPHONE_4_OR_LESS ? 25 : 0 );
        }
        
        vwScoreBoard.hidden = false;
        
        imgBestScore.hidden = true;
        
        imgStar1.hidden = true;
        imgStar2.hidden = true;
        imgStar3.hidden = true;
        imgBestScore.hidden = true;
        
        UIView.animateWithDuration(0.5, animations: {
            self.vwScoreBoard.alpha = 1.0
            
            self.lblCurrentMainScore.alpha = 0;
            self.lblCurrentLevel.alpha = 0;
            self.lblCurrentStage.alpha = 0;
        });
    }
    
    func hideScoreBoard(){
        
        if( vwScoreBoard.tag == 0 ){
            return;
        }
        
        vwScoreBoard.hidden = true;
        
        UIView.animateWithDuration(0.5, animations: {
            self.vwScoreBoard.alpha = 0.0
            self.lblCurrentMainScore.alpha = 1.0;
            self.lblCurrentLevel.alpha = 1.0;
            self.lblCurrentStage.alpha = 1.0;
            }, completion: { (flag: Bool) -> Void in
            
                self.vwScoreBoard.tag = 0;
                self.vwScoreBoard.removeFromSuperview();
        });
        
        gameScene.removeAllActions();
    }
    
    func showStars(star1: Bool, star2: Bool, star3: Bool, showHighScoreBadge: Bool){
        
        imgStar1.hidden = false;
        imgStar2.hidden = false;
        imgStar3.hidden = false;
        
        self.imgStar1.alpha = 0.0;
        self.imgStar2.alpha = 0.0;
        self.imgStar3.alpha = 0.0;
        
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
        
        if( showHighScoreBadge ){
            
            var delay : Double = (star3 ? 4.15 : (star2 ? 3.35 : (star1 ? 2.55 : 0)));
            self.showHighScoreBadge(delay);
        }
    }
    
    func showHighScoreBadge(delay: Double){
        
        var originalFrame = imgBestScore.frame;
        
        imgBestScore.hidden = false;
        imgBestScore.alpha  = 0.0;
        imgBestScore.frame.origin.x = imgBestScore.frame.origin.x + 100;
        imgBestScore.frame.origin.y = imgBestScore.frame.origin.y + 100;
        
        UIView.animateWithDuration(0.25, delay: delay, options: nil, animations: {
            self.imgBestScore.alpha = 1.0;
            self.imgBestScore.frame = originalFrame;
            }, completion: { (flag: Bool) -> Void in
                self.gameScene.playSound("best-score");
        });
    }
    
    func updateResumeInfo(){
        
        updateResumeLabels();
        hideScoreBoard();
    }
    
    func updateResumeLabels(){

        if( Constants.DeviceIdiom.IS_IPAD ){

            lblCurrentLevel.text = String(format: NSLocalizedString("Level", comment: "") + " %02d", gameScene.gameLevel.levelNumber);
            lblCurrentStage.text = String(format: NSLocalizedString("Stage", comment: "") + " %02d/%02d", gameScene.gameLevel.currentStage+1, gameScene.gameLevel.stages());
        }else{
            
            lblCurrentLevel.text = String(format: NSLocalizedString("Stage", comment: "") + " %02d %02d/%02d", gameScene.gameLevel.levelNumber, gameScene.gameLevel.currentStage+1, gameScene.gameLevel.stages());
        }
        
        lblCurrentMainScore.text = String(format: NSLocalizedString("Score", comment: "") + " %07d", gameScene.mainScore);
    }
    
    func unlockNextStage(){
        
        var gameStage : GameStage! = gameScene.gameLevel.getNextStage();
        if( gameStage == nil ){
            
            if( appDelegate.gameLevelList.count-1 > appDelegate.currentLevel && (!Constants.LITE_VERSION || gameScene.gameLevel.currentStage < 5) ){
                
                appDelegate.gameLevelList[appDelegate.currentLevel+1].gameStageList[0].locked = false;
            }
        }else if( !Constants.LITE_VERSION || gameScene.gameLevel.currentStage < 5 ){
            
            gameStage.locked = false
        }
    }
    
    func updateScoreBoard(){
        
        var gameLevel = gameScene.gameLevel;
        var gameStage = gameScene.gameStage;
        
        gameStage.timeBonus = gameStage.elapsedTime * gameLevel.timeDeduction * -1;
        
        gameStage.stageScore = (gameStage.rightBlocks * Score.RIGHT_BLOCK_SCORE - gameStage.wrongBlocks * Score.WRONG_BLOCK_SCORE - gameStage.missedBlocks * Score.MISSED_BLOCK_SCORE) + gameStage.timeBonus + gameStage.perfectBonus;
        gameStage.deductions = (gameStage.wrongBlocks * Score.WRONG_BLOCK_SCORE + gameStage.missedBlocks * Score.MISSED_BLOCK_SCORE) - gameStage.timeBonus;
        
        
        lblLevel.text = String(format: NSLocalizedString("Level", comment: "") + " %02d", gameLevel.levelNumber);
        lblStage.text = String(format: NSLocalizedString("Stage", comment: "") + " %02d/%02d", gameLevel.currentStage+1, gameLevel.stages());
        
        if( gameLevel.currentStage == gameLevel.stages()-1 && Constants.DeviceIdiom.IS_IPAD ){
            
            lblStage.text = NSLocalizedString("Stage clear", comment: "");
        }
        
        showScoreBoard();
        
        var showHighScore : Bool = false;
        
        if( gameStage.stageScore > gameStage.bestScore || gameStage.bestScore == 0 ){
            
            if( gameStage.bestScore != 0 ){
                
                showHighScore = true;
            }
            
            gameStage.bestScore = gameStage.stageScore;
        }
        
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
            
            showStars(star1, star2: star2, star3: star3, showHighScoreBadge: showHighScore);
        }else if( showHighScore ){
            
            showHighScoreBadge(2.0);
        }
        
        if( star1 || showHighScore ){
            
            skView.paused = false;
            let delay : Double = (star3 ? 4.15 : (star2 ? 3.35 : (star1 ? 2.55 : 0))) + (showHighScore ? 1.25 : 0);
            skViewPauseTimer = NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: Selector("pauseSkView"), userInfo: nil, repeats: false);
        }else{
            
            skView.paused = true;
        }
    
        gameScene.mainScore = GameLevel.getCurrentMainScore(appDelegate.gameLevelList);
        
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
        
        updateGKScoreBoard();
        
        unlockNextStage();
        
        appDelegate.gameLevelList[appDelegate.currentLevel].gameStageList[appDelegate.currentStage] = gameStage;
        GameLevel.archiveGameLevelList(appDelegate.gameLevelList);
        appDelegate.saveUserDefaults();
    }
    
    func pauseSkView(){
        
        skView.paused = true;
    }
}
