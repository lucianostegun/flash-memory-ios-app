//
//  InstructionsViewController.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 04/04/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit;

class InstructionsViewController: UIViewController {
    
    var gameScene : GameScene!;
    @IBOutlet var txtInstructions : UITextView!;
    @IBOutlet var btnNextStep : UIButton!;
    @IBOutlet var btnPreviousStep : UIButton!;
    @IBOutlet var btnMainMenu : UIButton!;
    @IBOutlet var vwInscructionsControls : UIView!;
    
    var currentStep : Int = 0;
    var gameLevel : GameLevel = GameLevel.getEmptyLevel(true);
    var gameStage : GameStage!;
    var stepTimer : NSTimer!;
    var soundEffects : Bool!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        gameScene = GameScene.unarchiveFromFile("GameScene") as? GameScene;
        gameScene.size = CGSizeMake(Util.getScreenWidth(self.view), Util.getScreenHeight(self.view));
        
        if gameScene != nil {
            // Configure the view.
            let skView = self.view as! SKView
            
            //            skView.showsFPS = true
            //            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            gameScene.scaleMode = .AspectFill
            gameScene.instructionsMode = true;
            
            skView.presentScene(gameScene)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateScoreBoard", name: "updateScoreBoard", object: nil);
        
        btnMainMenu.setTitle(NSLocalizedString("MAIN MENU", comment: ""), forState: UIControlState.Disabled)
        btnMainMenu.setTitle(NSLocalizedString("MAIN MENU", comment: ""), forState: UIControlState.Normal)
        btnPreviousStep.setTitle(NSLocalizedString("BACK", comment: ""), forState: UIControlState.Disabled)
        
        gameStage = gameLevel.getStage();
        gameScene.gameLevel    = gameLevel;
        gameScene.soundEffects = soundEffects;

        loadStep();
    }
    
    @IBAction func dismissViewController(sender: AnyObject){
     
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func loadNextStep(sender: AnyObject){
        
        currentStep++;
        loadStep();

        btnPreviousStep.enabled = true;
    }
    
    @IBAction func loadPreviousStep(sender: AnyObject){
        
        currentStep--;
        
        if( btnPreviousStep.titleLabel?.text == NSLocalizedString("TRY AGAIN", comment: "") ){
            
            currentStep = 6;
        }else if( btnPreviousStep.tag == 1 ){
            
            currentStep = 5;
        }
        
        loadStep();
        
        if( currentStep == 0 ){
            
            btnPreviousStep.enabled = false;
        }
    }
    
    func loadStep(){
        
        btnNextStep.setTitle(NSLocalizedString("GOT IT", comment: ""), forState: UIControlState.Normal);
        gameScene.instructionsMode = true;
        
        if( stepTimer != nil ){
            
            stepTimer.invalidate();
        }
        
        var clearBlocks = true;
        
        if( btnPreviousStep.tag == 1 ){
            
            btnPreviousStep.tag = 0;
            btnPreviousStep.setTitle(NSLocalizedString("BACK", comment: ""), forState: UIControlState.Normal);
        }else{
            
            btnPreviousStep.setTitle(NSLocalizedString("BACK", comment: ""), forState: UIControlState.Normal);
            btnPreviousStep.setTitle(NSLocalizedString("BACK", comment: ""), forState: UIControlState.Disabled);
        }
        
        if( btnNextStep.tag == 1 ){

            btnNextStep.tag = 0;
            btnNextStep.setTitle(NSLocalizedString("GOT IT", comment: ""), forState: UIControlState.Normal);
        }
        
        switch( currentStep ){
        case 0:
            loadStep0();
            break;
        case 1:
            loadStep1();
            break;
        case 2:
            loadStep2();
            break;
        case 3:
            loadStep3();
            break;
        case 4:
            loadStep4();
            break;
        case 5:
            btnNextStep.setTitle(NSLocalizedString("TRY IT", comment: ""), forState: UIControlState.Normal);
            loadStep5();
            break;
        case 6:
            gameScene.instructionsMode = false;
            loadStep6();
            break;
        case 7:
            clearBlocks = false;
            loadStep7();
            btnPreviousStep.tag = 1;
            break;
        case 8:
            clearBlocks = false;
            loadStep8();
            break;
        default:
            break;
        }
        
        if( clearBlocks ){
            
            gameScene.clearAllBlocks();
        }
    }
    
    func loadStep0(){
        
        txtInstructions.text = NSLocalizedString("instructions-step0", comment: "");
    }
    
    func loadStep1(){
        
        var gamePath = ["{336, 592}", "{336, 624}", "{336, 656}", "{368, 656}", "{400, 656}", "{432, 656}", "{464, 656}", "{464, 624}", "{464, 592}", "{496, 592}", "{528, 592}", "{560, 592}", "{592, 592}", "{624, 592}", "{656, 592}", "{688, 592}", "{688, 624}", "{688, 656}", "{656, 656}", "{624, 656}", "{592, 656}"];
        
        if( Constants.DeviceType.IS_IPHONE_4_OR_LESS ){
            
            gamePath = ["{48, 336}", "{48, 368}", "{48, 400}", "{48, 432}", "{80, 432}", "{112, 432}", "{112, 400}", "{112, 368}", "{112, 336}", "{144, 336}", "{176, 336}", "{208, 336}", "{240, 336}", "{272, 336}", "{272, 368}", "{272, 400}", "{272, 432}", "{240, 432}", "{208, 432}", "{176, 432}"];
        }else if( Constants.DeviceType.IS_IPHONE_5 ){
            
            gamePath = ["{48, 432}", "{48, 464}", "{48, 496}", "{80, 496}", "{112, 496}", "{112, 464}", "{112, 432}", "{144, 432}", "{176, 432}", "{208, 432}", "{240, 432}", "{272, 432}", "{272, 464}", "{272, 496}", "{240, 496}", "{208, 496}", "{176, 496}"];
        }else if( Constants.DeviceType.IS_IPHONE_6 ){
            
            gamePath = ["{48, 496}", "{48, 528}", "{48, 560}", "{48, 592}", "{80, 592}", "{112, 592}", "{144, 592}", "{144, 560}", "{144, 528}", "{144, 496}", "{176, 496}", "{208, 496}", "{240, 496}", "{272, 496}", "{304, 496}", "{336, 496}", "{336, 528}", "{336, 560}", "{336, 592}", "{304, 592}", "{272, 592}", "{240, 592}", "{208, 592}"];
        }else if( Constants.DeviceType.IS_IPHONE_6P ){
            
            gamePath = ["{48, 592}", "{48, 624}", "{48, 656}", "{48, 688}", "{80, 688}", "{112, 688}", "{144, 688}", "{144, 656}", "{144, 624}", "{144, 592}", "{176, 592}", "{208, 592}", "{240, 592}", "{272, 592}", "{304, 592}", "{336, 592}", "{368, 592}", "{368, 624}", "{368, 656}", "{368, 688}", "{336, 688}", "{304, 688}", "{272, 688}", "{240, 688}", "{208, 688}"];
        }
        
        gameStage.gamePath = gameStage.getPathFromArchive(gamePath);
        gameScene.gamePath = gameStage.gamePath;
        
        stepTimer = NSTimer.scheduledTimerWithTimeInterval(gameLevel.flashDuration + 1.5, target: self, selector: Selector("flashBlocksStep1"), userInfo: nil, repeats: false);
        
        txtInstructions.text = NSLocalizedString("instructions-step1", comment: "");
    }
    
    func loadStep2(){

        stepTimer = NSTimer.scheduledTimerWithTimeInterval(gameLevel.flashDuration + 1.5, target: self, selector: Selector("flashBlocksStep2"), userInfo: nil, repeats: false);

        txtInstructions.text = NSLocalizedString("instructions-step2", comment: "");
    }
    
    func loadStep3(){
        
        stepTimer = NSTimer.scheduledTimerWithTimeInterval(gameLevel.flashDuration + 1.5, target: self, selector: Selector("flashBlocksStep3"), userInfo: nil, repeats: false);
        
        txtInstructions.text = NSLocalizedString("instructions-step3", comment: "");
    }
    
    func loadStep4(){
        
        txtInstructions.text = NSLocalizedString("instructions-step4", comment: "");
    }
    
    func loadStep5(){
        
        txtInstructions.text = NSLocalizedString("instructions-step5", comment: "");
    }
    
    func loadStep6(){
        
        gameScene.gameStage = gameStage;
        
        gameScene.startGame();
    }
    
    func updateScoreBoard(){
        
        var gameLevel = gameScene.gameLevel;
        var gameStage = gameScene.gameStage;
        
        gameStage.timeBonus = gameStage.elapsedTime * gameLevel.timeDeduction * -1;
        
        gameStage.stageScore = (gameStage.rightBlocks * Score.RIGHT_BLOCK_SCORE - gameStage.wrongBlocks * Score.WRONG_BLOCK_SCORE - gameStage.missedBlocks * Score.MISSED_BLOCK_SCORE) + gameStage.timeBonus;
        gameStage.deductions = (gameStage.wrongBlocks * Score.WRONG_BLOCK_SCORE + gameStage.missedBlocks * Score.MISSED_BLOCK_SCORE) - gameStage.timeBonus;
        gameScene.mainScore = gameStage.stageScore;
        
        if( gameScene.mainScore < 0 ){

            txtInstructions.text = NSLocalizedString("Oh boy...", comment: "") + " " + NSLocalizedString("You score was", comment: "") + " \(gameScene.mainScore)! " + NSLocalizedString("How about trying again?", comment: "");
        }else if( gameScene.mainScore < 500 ){
            
            txtInstructions.text = NSLocalizedString("Not bad...", comment: "") + " " + NSLocalizedString("You score was", comment: "") + " \(gameScene.mainScore)! " + NSLocalizedString("But you can do better!", comment: "");
        }else if( gameScene.mainScore >= 500 && gameScene.mainScore < 800 ){
            
            txtInstructions.text = NSLocalizedString("Well done!", comment: "") + " " + NSLocalizedString("You score was", comment: "") + " \(gameScene.mainScore)! " + NSLocalizedString("But you do even better!", comment: "");
        }else if( gameScene.mainScore > 800 && gameStage.rightBlocks < gameStage.gamePath.count ){
            
            txtInstructions.text = NSLocalizedString("Great job!", comment: "") + " " + NSLocalizedString("You score was", comment: "") + " \(gameScene.mainScore)! " + NSLocalizedString("Now try again without missing a block.", comment: "");
        }else if( gameStage.rightBlocks == gameStage.gamePath.count && gameStage.wrongBlocks == 0 && gameStage.missedBlocks == 0 ){
            
            txtInstructions.text = NSLocalizedString("PERFECT!", comment: "") + " " + NSLocalizedString("You score was", comment: "") + " \(gameScene.mainScore)! " + NSLocalizedString("You really got talent!", comment: "");
        }
        
        let string1 = NSLocalizedString("\n\nEach right block worth", comment: "");
        let string2 = " \(Score.RIGHT_BLOCK_SCORE)pts";
        let string3 = NSLocalizedString("\nWrong blocks discount", comment: "");
        let string4 = " \(Score.WRONG_BLOCK_SCORE)pts";
        let string5 = NSLocalizedString("\nMissed blocks discount", comment: "");
        let string6 = " \(Score.MISSED_BLOCK_SCORE)pts";
        let string7 = NSLocalizedString("\n\nEach second count, so don't take much long or you lose points!\nYou also get 10% bonus if you don't miss a single block.", comment: "");
        
        txtInstructions.text = txtInstructions.text + "\(string1)\(string2)\(string3)\(string4)\(string5)\(string6)\(string7)"
        
        btnPreviousStep.tag = 1;
        btnPreviousStep.setTitle(NSLocalizedString("TRY AGAIN", comment: ""), forState: UIControlState.Normal);
        
        btnNextStep.tag = 0;
        btnNextStep.setTitle(NSLocalizedString("GOT IT", comment: ""), forState: UIControlState.Normal);
    }
    
    func loadStep7(){
        
        txtInstructions.text = NSLocalizedString("instructions-step7", comment: "");
        
        btnNextStep.tag = 1;
        btnNextStep.setTitle(NSLocalizedString("PRACTICE", comment: ""), forState: UIControlState.Normal);
    }
    
    func loadStep8(){
        
        var storyboardName = Constants.DeviceIdiom.IS_IPAD ? "Practice" : "Practice_iPhone";
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil);
        let vc         = storyboard.instantiateInitialViewController() as! PracticeViewController;
        
        vc.doubleDismiss = true;
        
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
    func flashBlocksStep1(){
        
        if( currentStep != 1 ){
            return;
        }
        
        gameScene.flashGameBlocks();
        
        NSTimer.scheduledTimerWithTimeInterval(gameLevel.flashDuration + 2.5, target: self, selector: Selector("flashBlocksStep1"), userInfo: nil, repeats: false);
    }
    
    func flashBlocksStep2(){
        
        gameScene.flashGameBlocks();
        
        NSTimer.scheduledTimerWithTimeInterval(gameLevel.flashDuration + 1.5, target: self, selector: Selector("startBlinkBlocksStep2"), userInfo: nil, repeats: false);
    }
    
    func startBlinkBlocksStep2(){
        
        var position : CGPoint = gameScene.gamePath[0];
        var block : SKBlock = gameScene.nodeAtPoint(position) as! SKBlock;
        
        block.yellowColor();
        block.alpha = Block.baseAlpha;
        block.startBlinking();
        
        position = gameScene.gamePath[gameScene.gamePath.count-1];
        block = gameScene.nodeAtPoint(position) as! SKBlock;
        
        block.yellowColor();
        block.alpha = Block.baseAlpha;
        block.startBlinking();
    }
    
    func flashBlocksStep3(){
        
        gameScene.flashGameBlocks();
        
        NSTimer.scheduledTimerWithTimeInterval(gameLevel.flashDuration + 1.5, target: self, selector: Selector("startBlinkBlocksStep3"), userInfo: nil, repeats: false);
    }
    
    func startBlinkBlocksStep3(){
        
        var position : CGPoint = gameScene.gamePath[0];
        var block : SKBlock = gameScene.nodeAtPoint(position) as! SKBlock;
        
        block.yellowColor();
        block.alpha = Block.baseAlpha;
        block.startBlinking();
    }
}
