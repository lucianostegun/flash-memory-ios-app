//
//  AgainstTimeViewController.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 23/04/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import UIKit
import SpriteKit
import iAd
import GameKit;

class AgainstTimeViewController: UIViewController, ADBannerViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    var gameScene : GameScene!;
    var skView : SKView!;
    @IBOutlet var iAdBannerView: ADBannerView!
    @IBOutlet weak var btnStartGame: UIButton!
    @IBOutlet weak var btnShowMenu: UIButton!
    @IBOutlet weak var btnRestartStage: UIButton!
    @IBOutlet weak var vwMainMenu: UIView!
    @IBOutlet weak var vwScoreBoard: UIView!
    @IBOutlet weak var lblTotalBlocks: UILabel!
    @IBOutlet weak var lblRightBlocks: UILabel!
    @IBOutlet weak var lblWrongBlocks: UILabel!
    @IBOutlet weak var lblMissedBlocks: UILabel!
    @IBOutlet weak var lblTimeBonus: UILabel!
    @IBOutlet weak var lblTimeRemain: UILabel!
    
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
    
    @IBOutlet weak var lblPlus5s: UILabel!
    
    var minRandomBlocks : Int = 18;
    var maxRandomBlocks : Int = 25;
    var gameLevel : GameLevel!;
    var bestMainScore : Int = 0;
    var skViewPauseTimer : NSTimer!;
    
    var remainingTime : Int = 90;
    var countdownTimer : NSTimer!;
    
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
        
        gameLevel = GameLevel.getEmptyLevel(false);
        
        gameScene.mainScore = 0;
        gameScene.clearAllBlocks();
        
        gameScene.nextSpecialBlockNumber = 10;
        
        vwScoreBoard.hidden = true;
        lblMainScore.format = "%07d";
        
        if( Constants.LITE_VERSION ){
            
            iAdBannerView.removeFromSuperview();
        }
        
        lblPlus5s.hidden = true;
        
        updateCountdownLabel();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSpecialBlock:", name: "touchedSpecialBlock", object: nil);
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated);
        
        if( DeviceIdiom.IS_IPHONE ){
            
            vwMainMenu.frame.origin.x = (Util.getScreenWidth(self.view) / 2) - (vwMainMenu.frame.size.width / 2);
            vwMainMenu.frame.origin.y = (Util.getScreenHeight(self.view) / 2) - (vwMainMenu.frame.size.height / 2);
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateScoreBoard", name: "updateScoreBoard", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideScoreBoard", name: "hideScoreBoard", object: nil);
        
        if( Constants.LITE_VERSION ){
         
            if( DeviceIdiom.IS_IPAD ){
                
                iAdBannerView.frame  = CGRectMake(0, 702, 1024, 768);
                iAdBannerView.contentMode = UIViewContentMode.Center;
                self.view.addSubview(iAdBannerView);
            }else{
                
                iAdBannerView.hidden = false;
                iAdBannerView.frame  = CGRectMake(0, 0, 320, 50);
                
                iAdBannerView.frame.origin.y = Util.getScreenHeight(self.view) - iAdBannerView.frame.size.height;
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
        
        gameLevel.addStage(gameScene.gamePath, setAsCurrent: true);
        
        gameScene.gameLevel = gameLevel;
        gameScene.gameStage = gameLevel.getStage();
        gameScene.gameStage.setMinStars(gameLevel.timeDeduction);
        
        vwMainMenu.hidden = true;
        
        skView.paused = false;
        
        invalidateSkViewPauseTimer();

        NSTimer.scheduledTimerWithTimeInterval(1.0, target: gameScene, selector: Selector("startGame"), userInfo: nil, repeats: false);
        
        if( countdownTimer == nil ){
            
            countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("runTimer"), userInfo: nil, repeats: true);
        }
        
    }
    
    @IBAction func showMainMenu(sender: AnyObject){
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func showScoreBoard(){
        
        if( vwScoreBoard.tag == 0 ){
            
            vwScoreBoard.tag = 1;
            self.view.addSubview(vwScoreBoard);
            vwScoreBoard.frame.origin.x = (Util.getScreenWidth(self.view) / 2) - (vwScoreBoard.frame.width / 2);
            vwScoreBoard.frame.origin.y = (Util.getScreenHeight(self.view) / 2) - (vwScoreBoard.frame.height / 2) + ( DeviceType.IS_IPHONE_4_OR_LESS ? 25 : 0 );
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
    
    func updateScoreBoard(){
        
        var gameLevel = gameScene.gameLevel;
        var gameStage = gameScene.gameStage;
        
        gameStage.timeBonus = gameStage.elapsedTime * gameLevel.timeDeduction * -1;
        
        gameStage.stageScore = (gameStage.rightBlocks * Score.RIGHT_BLOCK_SCORE - gameStage.wrongBlocks * Score.WRONG_BLOCK_SCORE - gameStage.missedBlocks * Score.MISSED_BLOCK_SCORE) + gameStage.timeBonus + gameStage.perfectBonus;
        gameStage.deductions = (gameStage.wrongBlocks * Score.WRONG_BLOCK_SCORE + gameStage.missedBlocks * Score.MISSED_BLOCK_SCORE) - gameStage.timeBonus;
        
        gameScene.mainScore += gameStage.stageScore;
        
        startGame(self);
        
        var showHighScore : Bool = false;
        
    }
    
    func pauseSkView(){
        
        skView.paused = true;
    }
    
    func runTimer(){
        
//        if( !gameScene.touchesEnabled ){
//            
//            return;
//        }
        
        if( remainingTime == 0 ){
            
            updateCountdownLabel();
            countdownTimer.invalidate();
            return;
        }
        
        remainingTime--;
        
        updateCountdownLabel()
    }
    
    func updateCountdownLabel(){
        
        lblTimeRemain.text = "\(Util.formatTimeString(Float(remainingTime)))";
    }
    
    func handleSpecialBlock(notification: NSNotification){
        
        var block : SKBlock = notification.object as! SKBlock;
        println("handleSpecialBlock -> block: \(block)");
        
        lblPlus5s.hidden = false;
        lblPlus5s.alpha  = 1;
//        lblPlus5s.frame.origin.x = self.view.bounds.size.width - block.position.x;
//        lblPlus5s.frame.origin.y = self.view.bounds.size.height - block.position.y;
        
        self.lblPlus5s.frame.origin.x = block.position.x;
        self.lblPlus5s.frame.origin.y = block.position.y;
        
        remainingTime += 5;
        updateCountdownLabel();
        
        UIView.animateWithDuration(1.3, animations: {
//            self.lblPlus5s.frame.origin.y = self.lblPlus5s.frame.origin.y - 40;
            self.lblPlus5s.frame.origin.x = block.position.x;
            self.lblPlus5s.frame.origin.y = block.position.y - 30;
            self.lblPlus5s.alpha = 0;
        })
    }
}
