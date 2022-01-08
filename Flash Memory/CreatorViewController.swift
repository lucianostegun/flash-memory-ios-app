//
//  CreatorViewController.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 26/03/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import UIKit
import SpriteKit

class CreatorViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    var gameScene : GameScene!;
    
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblStage: UILabel!
    @IBOutlet weak var lblFlashDuration: UILabel!
    @IBOutlet weak var lblTimeDeduction: UILabel!
    @IBOutlet weak var lblBlocks: UILabel!
    @IBOutlet weak var lblRandomBlocks: UILabel!
    @IBOutlet weak var swcBlinkFirst: UISwitch!
    @IBOutlet weak var swcBlinkLast: UISwitch!
    @IBOutlet weak var btnDeleteStage: UIButton!
    @IBOutlet weak var stprGameLevel: UIStepper!
    @IBOutlet weak var stprGameStage: UIStepper!
    @IBOutlet weak var stprFlashDuration: UIStepper!
    @IBOutlet weak var stprTimeDeduction: UIStepper!
    @IBOutlet weak var stprRandomBlocks: UIStepper!
    
    @IBOutlet weak var vwScoreBoard: UIView!
    @IBOutlet weak var lblTotalBlocks: UILabel!
    @IBOutlet weak var lblRightBlocks: UILabel!
    @IBOutlet weak var lblWrongBlocks: UILabel!
    @IBOutlet weak var lblMissedBlocks: UILabel!
    @IBOutlet weak var lblTimeBonus: UILabel!
    @IBOutlet weak var lbl3Stars: UILabel!
    
    @IBOutlet weak var lblStageScore: UICountingLabel!
    @IBOutlet weak var lblRightBlocksScore: UICountingLabel!
    @IBOutlet weak var lblWrongBlocksScore: UICountingLabel!
    @IBOutlet weak var lblMissedBlocksScore: UICountingLabel!
    @IBOutlet weak var lblPerfectBonus: UICountingLabel!
    @IBOutlet weak var lblTimeBonusScore: UICountingLabel!
    @IBOutlet weak var lblDeductions: UICountingLabel!
    
    var currentLevel : Int = 0;
    var currentStage : Int = 0;
    var randomBlocks : Int = 15;
    var gameLevelList : Array<GameLevel>!;
    var isModal : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameScene = GameScene.unarchiveFromFile("GameScene") as? GameScene;
        gameScene.size = CGSizeMake(Util.getScreenWidth(self.view), Util.getScreenHeight(self.view));
        
        gameScene.touchesEnabled = true;
        gameScene.creatorMode = true;
        
        if gameScene != nil {
            // Configure the view.
            let skView = self.view as! SKView
            //            skView.showsFPS = true
            //            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            gameScene.scaleMode = .AspectFill
            
            skView.presentScene(gameScene)
        }
        
        gameLevelList = appDelegate.gameLevelList;
        gameLevelList[currentLevel].currentStage = currentStage;
        
        vwScoreBoard.hidden = true;
        gameScene.tryingMode = false;
        
        loadGameStage();
        updateLabels(true);
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateLabels", name: "updateResumeInfo", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateScoreBoard", name: "updateScoreBoard", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideScoreBoard", name: "hideScoreBoard", object: nil);
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        super.viewDidDisappear(animated);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateResumeInfo", object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateScoreBoard", object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "hideScoreBoard", object: nil);
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
    
    func updateLabels(){
        
        updateLabels(false);
    }
    
    func updateLabels(updateRandomBlocks: Bool){
        
        hideScoreBoard()
        
        var blocks : Int = gameScene.creatorPath.count;
        
        if( updateRandomBlocks ){
            
            randomBlocks = blocks;
        }
        
        lblLevel.text = String(format: "Level %02d/%02d", currentLevel+1, gameLevelList.count);
        lblStage.text = String(format: "Stage %02d/%02d", currentStage+1, gameLevelList[currentLevel].stages());
        lblFlashDuration.text = "Flash: \(gameLevelList[currentLevel].flashDuration)"
        lblTimeDeduction.text = "Deduction: \(gameLevelList[currentLevel].timeDeduction)"
        lblRandomBlocks.text  = "\(randomBlocks) blocks";
        lblBlocks.text = "\(blocks) block\(Util.getPlural(blocks))";
        swcBlinkFirst.on = gameLevelList[currentLevel].blinkFirst;
        swcBlinkLast.on  = gameLevelList[currentLevel].blinkLast;
        
        stprFlashDuration.value = Double(gameLevelList[currentLevel].flashDuration);
        stprTimeDeduction.value = Double(gameLevelList[currentLevel].timeDeduction);
        stprRandomBlocks.value  = Double(randomBlocks);
        
        gameScene.creatorMode = true;
    }
    
    func loadGameStage(){
        
        hideScoreBoard()
        
        gameScene.loadStage(gameLevelList[currentLevel], unlock: false);
        
        resetCreator(self);
        gameScene.creatorPath = Array(gameLevelList[currentLevel].getStage().gamePath) as Array<CGPoint>;

        gameScene.redrawCreatorPath(false);
        
        if( gameScene.creatorPath.count > 0 ){
         
            gameScene.lastTouchPosition = gameScene.creatorPath.last;
        }
        
        lbl3Stars.text = "\(gameLevelList[currentLevel].getStage().min3Stars)";
    }
    
    @IBAction func resetCreator(sender: AnyObject) {
        
        gameScene.creatorPath = [];
        gameScene.gamePath    = [];
        gameScene.clearAllBlocks();
        gameScene.resetControls();
        gameScene.tryingMode = false;
        
        hideScoreBoard();
        
        updateLabels(true);
    }
    
    @IBAction func tryStage(sender: AnyObject) {
        
        hideScoreBoard();
        
        gameScene.tryingMode = true;
        
        gameScene.gamePath = gameScene.creatorPath;
        gameScene.gameLevel = gameLevelList[currentLevel];
        gameScene.startGame();
        
        println("\(gameLevelList[currentLevel].getStage().getPathToArchive())");
    }
    
    @IBAction func redrawCreatorPath(sender: AnyObject) {
        
        hideScoreBoard();
        
        gameScene.redrawCreatorPath(true);
    }
    
    @IBAction func toggleBlinkFirst(sender: AnyObject) {
        
        gameLevelList[currentLevel].blinkFirst = swcBlinkFirst.on;
    }
    
    @IBAction func toggleBlinkLast(sender: AnyObject) {
        
        gameLevelList[currentLevel].blinkLast = swcBlinkLast.on;
    }
    
    @IBAction func changeValueFlashDuration(sender: AnyObject) {
        
        gameLevelList[currentLevel].flashDuration = (sender as! UIStepper).value;
        updateLabels(true);
    }
    
    @IBAction func changeValueTimeDeduction(sender: AnyObject) {
        gameLevelList[currentLevel].timeDeduction = Int((sender as! UIStepper).value);
        updateLabels(true);
    }
    
    @IBAction func changeValueRandomBlocks(sender: AnyObject) {

        randomBlocks = Int((sender as! UIStepper).value);
        updateLabels(false);
    }

    @IBAction func loadGameViewController(sender: AnyObject) {
        
        if( self.isModal ){
            
            self.dismissViewControllerAnimated(true, completion: nil);
            return;
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc         = storyboard.instantiateInitialViewController() as! UIViewController;
        
        gameScene.tryingMode = false;
        gameScene.creatorMode = false;
        
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
    @IBAction func undoCreation(sender: AnyObject) {
        loadGameStage();
    }
    
    @IBAction func changeGameLevel(sender: AnyObject) {
        
        self.saveGameStage(sender);
        
        if( currentStage > 0 && gameLevelList[currentLevel].getStage().gamePath.count == 0 ){
            
            deleteCurrentGameStage();
        }
        
        currentLevel        = Int((sender as! UIStepper).value);
        currentStage        = 0;
        stprGameStage.value = 0;
        
        if( currentLevel == gameLevelList.count ){
         
            var gameLevel : GameLevel = GameLevel();
            gameLevel.levelNumber   = currentLevel+1;
            gameLevel.flashDuration = gameLevelList[currentLevel-1].flashDuration;
            gameLevel.timeDeduction = gameLevelList[currentLevel-1].timeDeduction;
            gameLevel.blinkFirst    = gameLevelList[currentLevel-1].blinkFirst;
            gameLevel.blinkLast     = gameLevelList[currentLevel-1].blinkLast;
            
            var gamePath : Array<CGPoint> = [];
            gameLevel.addStage(gamePath);
            
            gameLevelList.append(gameLevel);
        }
        
        gameLevelList[currentLevel].currentStage = currentStage;
        println("gameLevelList.count: \(gameLevelList.count)")
        
        var gameStage      = gameLevelList[currentLevel].getStage();
        gameStage.gamePath = Array(gameLevelList[currentLevel].getStage().gamePath) as Array<CGPoint>;
        
        if( gameScene.creatorPath.count > 0 ){
            
            randomBlocks = gameScene.creatorPath.count;
        }
        
        loadGameStage();
        updateLabels(true);
        
        gameScene.tryingMode  = false;
        gameScene.creatorMode = true;
    }
    
    @IBAction func changeGameStage(sender: AnyObject) {
        
        self.saveGameStage(sender);
        
        var createNewStage = false;
        
        currentStage = Int((sender as! UIStepper).value);
        gameLevelList[currentLevel].currentStage = currentStage
        
        if( currentStage == gameLevelList[currentLevel].stages() ){
            
            var gamePath : Array<CGPoint> = [];
            gameLevelList[currentLevel].addStage(gamePath);
            gameLevelList[currentLevel].currentStage = currentStage
            createNewStage = true
        }
        
        var gameStage      = gameLevelList[currentLevel].getStage();
        gameStage.gamePath = Array(gameLevelList[currentLevel].getStage().gamePath) as Array<CGPoint>;
        
        loadGameStage();
        updateLabels(true);
        
        if( createNewStage ){
            
            self.createRandomLevel(sender);
        }
        
        gameScene.tryingMode = false;
        gameScene.creatorMode = true;
    }
    
    @IBAction func deleteGameStage(sender: AnyObject) {
        
        deleteCurrentGameStage();
        
        loadGameStage()
        updateLabels(true);
    }
    
    func deleteCurrentGameStage(){
        
        if( gameLevelList[currentLevel].stages() == 1 ){
            
            if( gameLevelList.count > 1 ){
             
                gameLevelList.removeAtIndex(currentLevel);
                currentLevel--;
                currentStage = 0;
                
                loadGameStage();
                updateLabels(true);
            }
        }else{
            
            gameLevelList[currentLevel].removeStage(currentStage);
            currentStage = gameLevelList[currentLevel].currentStage;
        }
    }
    
    @IBAction func saveGameStage(sender: AnyObject) {
        
        var gameStage = gameLevelList[currentLevel].getStage();
        
        gameStage.gamePath = Array(gameScene.creatorPath) as Array<CGPoint>;
        
        if( gameStage.min3Stars == 0 ){
            
            gameStage.min3Stars = Int(Double(gameStage.gamePath.count) * 100.0 * 0.9);
            gameStage.min2Stars = Int(gameStage.min3Stars/2);
            gameStage.min1Star  = Int(gameStage.min2Stars/4);
        }
        
        GameLevel.archiveGameLevelList(gameLevelList);
        
        appDelegate.gameLevelList = gameLevelList;
    }
    
    @IBAction func set3StarsScore(sender: AnyObject) {
        
        gameLevelList[currentLevel].getStage().setMinStars(gameLevelList[currentLevel].timeDeduction)
        
        lbl3Stars.text = lblStageScore.text;
    }
    
    func showScoreBoard(){
        
        vwScoreBoard.hidden = false;
        
        UIView.animateWithDuration(0.5, animations: {
            self.vwScoreBoard.alpha = 1.0
        })
    }
    
    func hideScoreBoard(){
        
        vwScoreBoard.hidden = true;
    }
    
    func updateScoreBoard(){
        
        showScoreBoard();
        
        var gameLevel = gameScene.gameLevel;
        var gameStage = gameScene.gameStage;
        
        gameStage.timeBonus = gameStage.elapsedTime * gameLevel.timeDeduction * -1;
        
        gameStage.stageScore = (gameStage.rightBlocks * Score.RIGHT_BLOCK_SCORE - gameStage.wrongBlocks * Score.WRONG_BLOCK_SCORE - gameStage.missedBlocks * Score.MISSED_BLOCK_SCORE) + gameStage.timeBonus;
        gameStage.deductions = (gameStage.wrongBlocks * Score.WRONG_BLOCK_SCORE + gameStage.missedBlocks * Score.MISSED_BLOCK_SCORE) - gameStage.timeBonus;
        gameScene.mainScore += gameStage.stageScore;
        gameScene.mainScore += gameStage.stageScore;
        
        lblTotalBlocks.text  = "\(gameStage.gamePath.count)";
        lblRightBlocks.text  = "\(gameStage.rightBlocks)";
        lblWrongBlocks.text  = "\(gameStage.wrongBlocks)";
        lblMissedBlocks.text = "\(gameStage.missedBlocks)";
        lblTimeBonus.text    = "\(Util.formatTimeString(Float(gameStage.elapsedTime)))";
        
        gameStage.wrongBlocks  *= -1;
        gameStage.missedBlocks *= -1;
        gameStage.deductions   *= -1;
        
        lblRightBlocksScore.countFrom(0, to: Float(gameStage.rightBlocks * Score.RIGHT_BLOCK_SCORE), withDuration: 1.5);
        lblWrongBlocksScore.countFrom(0, to: Float(gameStage.wrongBlocks * Score.WRONG_BLOCK_SCORE), withDuration: 1.5);
        lblMissedBlocksScore.countFrom(0, to: Float(gameStage.missedBlocks * Score.MISSED_BLOCK_SCORE), withDuration: 1.5);
        lblPerfectBonus.countFrom(0, to: Float(gameStage.perfectBonus), withDuration: 1.5);
        lblTimeBonusScore.countFrom(0, to: Float(gameStage.timeBonus), withDuration: 1.5);
        lblDeductions.countFrom(0, to: Float(gameStage.deductions), withDuration: 1.5);
        lblStageScore.countFrom(0, to: Float(gameStage.stageScore), withDuration: 1.5);
    }
    
    @IBAction func createRandomLevel(sender: AnyObject) {

        var randomPath : Array<CGPoint> = [];
        
        do{
            
            randomPath = RandomGameStage.getRandomPath(randomBlocks, horizontalBlocks: gameScene.horizontalBlocks, verticalBlocks: gameScene.verticalBlocks, bounds: self.view.bounds);
        }while( randomPath.count < randomBlocks );
        
        if( randomPath.count > 0 ){
            
            saveGameStage(sender);
            gameLevelList[currentLevel].getStage().gamePath = randomPath;
            loadGameStage()
            updateLabels(true);
        }
    }
}
