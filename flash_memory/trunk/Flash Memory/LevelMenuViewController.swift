//
//  LevelMenuViewController.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 29/03/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import UIKit
import SpriteKit

class LevelMenuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    @IBOutlet var collectionView : UICollectionView!;
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);

        self.collectionView.reloadData();
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return appDelegate.gameLevelList.count;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.gameLevelList[section].gameStageList.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GAME_LEVEL_STAGE", forIndexPath: indexPath) as! GameStageCell;
        
        cell.backgroundColor = UIColor.blackColor();
        
        var gameStage : GameStage = appDelegate.gameLevelList[indexPath.section].gameStageList[indexPath.item];
        
//        println("section: \(indexPath.section), item: \(indexPath.item), locked: \(gameStage.locked), gameStage: \(gameStage)");
        
        cell.gameLevel = indexPath.section
        cell.gameStage = indexPath.item;
        cell.backgroundColor = UIColor.clearColor();
        
        cell.btnLoadStage.gameLevel = indexPath.section;
        cell.btnLoadStage.gameStage = indexPath.item;
        
        if( gameStage.locked ){

            cell.lblStageNumber.hidden = true;
            cell.lblStageScore.hidden  = true;
            cell.imgStar1.hidden       = true;
            cell.imgStar2.hidden       = true;
            cell.imgStar3.hidden       = true;
            cell.imgLocked.hidden      = false;
//            cell.btnLoadStage.enabled  = false;
        }else{
//            cell.btnLoadStage.enabled   = true;
            
            cell.lblStageNumber.text = "\(indexPath.item+1)";
            cell.lblStageScore.text  = "\(gameStage.bestScore)";
            cell.imgStar1.alpha      = gameStage.stars < 1 ? 0.35 : 1.0;
            cell.imgStar2.alpha      = gameStage.stars < 2 ? 0.35 : 1.0;
            cell.imgStar3.alpha      = gameStage.stars < 3 ? 0.35 : 1.0;
            
            if( gameStage.stars == 0 && gameStage.bestScore == 0 ){
            
                cell.lblStageScore.text = "-";
            }
            
            cell.lblStageNumber.hidden = false;
            cell.lblStageScore.hidden  = false;
            cell.imgStar1.hidden       = false;
            cell.imgStar2.hidden       = false;
            cell.imgStar3.hidden       = false;
            cell.imgLocked.hidden      = true;
        }
        
        // Configure the cell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableview : UICollectionReusableView! = nil;
        
        if( kind == UICollectionElementKindSectionHeader ){
            
            var headerView : GameLevelHeader = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "GAME_LEVEL_HEADER", forIndexPath: indexPath) as! GameLevelHeader;
            
            headerView.lblHeader.text = String(format: NSLocalizedString("Level", comment: "") + " %02d", indexPath.section+1);
            
            reusableview = headerView;
        }
        
        return reusableview;
    }
    
    @IBAction func loadGameStage(sender: AnyObject){
        
        appDelegate.currentLevel = (sender as! UIGameLevelButton).gameLevel;
        appDelegate.currentStage = (sender as! UIGameLevelButton).gameStage;
        
        var gameViewController = (appDelegate.window?.rootViewController as! GameViewController);
        var gameLevel          = appDelegate.gameLevelList[appDelegate.currentLevel];
        gameLevel.currentStage = appDelegate.currentStage;
        
        if( appDelegate.currentStage > 5 && Constants.LITE_VERSION ){
            
            var alertView = UIAlertView(title: NSLocalizedString("Level unavailable", comment: ""), message: NSLocalizedString("This level is only available in the full version of the game.\nWould you like to upgrade?", comment:""), delegate: gameViewController, cancelButtonTitle: NSLocalizedString("Not now", comment: ""), otherButtonTitles: NSLocalizedString("Upgrade", comment: ""));
            
            alertView.show();
            return;
        }
        
        if( gameLevel.getStage().locked ){
            
            var alertView = UIAlertView(title: NSLocalizedString("Level locked", comment: ""), message: NSLocalizedString("This stage is currently locked.\nTo unlock it play all previous stages before.", comment:""), delegate: gameViewController, cancelButtonTitle: NSLocalizedString("OK", comment: ""));
            
            alertView.show();
            return;
        }
        
        (self.parentViewController as! GameViewController).hideLevelMenu(false);

        gameViewController.gameScene.loadStage(gameLevel, unlock: true);
        gameViewController.startGame(sender);
    }
    
    @IBAction func hideLevelMenu(sender: AnyObject) {
        
        (self.parentViewController as! GameViewController).hideLevelMenu(true);
    }
}
