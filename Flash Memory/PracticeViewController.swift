//
//  PracticeViewController.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 02/04/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import UIKit
import SpriteKit
import iAd
import GameKit;

class PracticeViewController: UIViewController, ADBannerViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    var gameScene : GameScene!;
    var skView : SKView!;
    @IBOutlet var iAdBannerView: ADBannerView!
    @IBOutlet weak var btnStartGame: UIButton!
    @IBOutlet weak var btnShowMenu: UIButton!
    @IBOutlet weak var btnChangeDifficulty: UIButton!
    @IBOutlet weak var btnRestartStage: UIButton!
    @IBOutlet weak var vwMainMenu: UIView!
    @IBOutlet weak var vwScoreBoard: UIView!
    @IBOutlet weak var lblTotalBlocks: UILabel!
    @IBOutlet weak var lblRightBlocks: UILabel!
    @IBOutlet weak var lblWrongBlocks: UILabel!
    @IBOutlet weak var lblMissedBlocks: UILabel!
    @IBOutlet weak var lblTimeBonus: UILabel!
    
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
    
    var difficulty : String = "Fish";
    var minRandomBlocks : Int = 15;
    var maxRandomBlocks : Int = 20;
    var gameLevel : GameLevel!;
    var doubleDismiss : Bool = false;
    var bestMainScore : Int = 0;
    var skViewPauseTimer : NSTimer!;
    
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
        
        gameLevel = GameLevel();
        difficulty = appDelegate.practiceDifficulty;
        changeDifficulty();
        
        gameScene.mainScore = 0;
        gameScene.clearAllBlocks();
        
        vwScoreBoard.hidden = true;
        lblMainScore.format = "%07d";
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated);
        
        if( Constants.DeviceIdiom.IS_IPHONE ){
            
            vwMainMenu.frame.origin.x = (Util.getScreenWidth(self.view) / 2) - (vwMainMenu.frame.size.width / 2);
            vwMainMenu.frame.origin.y = (Util.getScreenHeight(self.view) / 2) - (vwMainMenu.frame.size.height / 2);
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated);
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
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.Portrait.rawValue)
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
    
    func invalidateSkViewPauseTimer(){
        
        if( skViewPauseTimer != nil ){
            
            skViewPauseTimer.invalidate();
        }
    }
    
    @IBAction func startGame(sender: AnyObject){
  
        hideScoreBoard();
        
        var randomBlocks : Int = 0;
        
        do{
        
            do{
            
                randomBlocks = Int(arc4random_uniform(UInt32(maxRandomBlocks)));
            }while( randomBlocks < minRandomBlocks )
            
            gameScene.gamePath = RandomGameStage.getRandomPath(randomBlocks, horizontalBlocks: gameScene.horizontalBlocks, verticalBlocks: gameScene.verticalBlocks, bounds: self.view.bounds);
        }while( gameScene.gamePath.count < randomBlocks );
        
        gameLevel.deleteAllStages();
        gameLevel.addStage(gameScene.gamePath);
        
        gameScene.gameLevel = gameLevel;
        gameScene.gameStage = gameLevel.getStage();
        gameScene.gameStage.setMinStars(gameLevel.timeDeduction);
        
        vwMainMenu.hidden = true;
        
        skView.paused = false;
        
        invalidateSkViewPauseTimer();

        NSTimer.scheduledTimerWithTimeInterval(1.0, target: gameScene, selector: Selector("startGame"), userInfo: nil, repeats: false);
    }
    
    @IBAction func restartStage(sender: AnyObject) {
        
        skView.paused = false;

        invalidateSkViewPauseTimer();
        
        gameScene.mainScore -= gameScene.gameStage.stageScore;
        
        gameScene.restartStage();
        
        hideScoreBoard();
        gameScene.clearAllBlocks();
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: gameScene, selector: Selector("startGame"), userInfo: nil, repeats: false);
    }
    
    @IBAction func showMainMenu(sender: AnyObject){
        
        if( doubleDismiss ){
            
            self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil);
//            self.parentViewController?.dismissViewControllerAnimated(true, completion: nil);
        }else{
            
            self.dismissViewControllerAnimated(true, completion: nil);
        }
    }
    
    @IBAction func changeDifficulty(sender: AnyObject) {
        
        switch( difficulty ){
        case "Fish":
            difficulty = "Dolphin";
            break;
        case "Dolphin":
            difficulty = "Human";
            break;
        case "Human":
            difficulty = "Elephant";
            break;
        case "Elephant":
            difficulty = "Fish";
            break;
        default:
            break;
        }
        
        changeDifficulty();
    }

    func changeDifficulty() {
        
        switch( difficulty ){
        case "Fish":
            gameLevel.flashDuration = 2.0;
            gameLevel.timeDeduction = 10;
            gameLevel.blinkFirst    = true;
            gameLevel.blinkLast     = true;
            
            minRandomBlocks = 15;
            maxRandomBlocks = 20;
            break;
        case "Dolphin":
            gameLevel.flashDuration = 1.5;
            gameLevel.timeDeduction = 20;
            gameLevel.blinkFirst    = true;
            gameLevel.blinkLast     = true;
            
            minRandomBlocks = 18;
            maxRandomBlocks = 24;
            break;
        case "Human":
            gameLevel.flashDuration = 1.0;
            gameLevel.timeDeduction = 30;
            gameLevel.blinkFirst    = true;
            gameLevel.blinkLast     = false;
            
            minRandomBlocks = 23;
            maxRandomBlocks = 26;
            break;
        case "Elephant":
            gameLevel.flashDuration = 0.5;
            gameLevel.timeDeduction = 50;
            gameLevel.blinkFirst    = false;
            gameLevel.blinkLast     = false;
            
            minRandomBlocks = 25;
            maxRandomBlocks = 35;
            break;
        default:
            break;
        }
        
        var difficultyLabel = NSLocalizedString("difficulty.\(difficulty)", comment: "");
        
        if( Constants.DeviceIdiom.IS_IPAD ){
            
            difficultyLabel = NSLocalizedString("Difficulty", comment: "") + ": " + difficultyLabel;
        }
        
        btnChangeDifficulty.setTitle(difficultyLabel, forState: UIControlState.Normal);
        
        appDelegate.practiceDifficulty = difficulty;
        appDelegate.saveUserDefaults();
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
        })
    }
    
    func hideScoreBoard(){
        
        if( vwScoreBoard.tag == 0 ){
            return;
        }
        
        vwScoreBoard.hidden = true;
        
        UIView.animateWithDuration(0.5, animations: {
            self.vwScoreBoard.alpha = 0.0
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
    
    func updateScoreBoard(){
        
        var gameLevel = gameScene.gameLevel;
        var gameStage = gameScene.gameStage;
        
        gameStage.timeBonus = gameStage.elapsedTime * gameLevel.timeDeduction * -1;
        
        gameStage.stageScore = (gameStage.rightBlocks * Score.RIGHT_BLOCK_SCORE - gameStage.wrongBlocks * Score.WRONG_BLOCK_SCORE - gameStage.missedBlocks * Score.MISSED_BLOCK_SCORE) + gameStage.timeBonus + gameStage.perfectBonus;
        gameStage.deductions = (gameStage.wrongBlocks * Score.WRONG_BLOCK_SCORE + gameStage.missedBlocks * Score.MISSED_BLOCK_SCORE) - gameStage.timeBonus;
        
        gameScene.mainScore += gameStage.stageScore;
        
        showScoreBoard();
        
        var showHighScore : Bool = false;
        
        if( gameStage.stageScore > gameStage.bestScore || gameStage.bestScore == 0 ){
            
            if( gameStage.bestScore != 0 ){
            
                showHighScore = true
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
        
//        if( gameScene.mainScore > bestMainScore ){
//            
//            bestMainScore = gameScene.mainScore
//            let leaderboardIdentifier : String = "com.stegun.FlashMemory.PracticeRanking.\(difficulty)";
//            
//            (appDelegate.window?.rootViewController as! GameViewController).updateGKScoreBoard(leaderboardIdentifier, score: gameScene.mainScore);
//        }
    }
    
    func pauseSkView(){
        
        skView.paused = true;
    }
}
