//
//  GameLevel.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 25/03/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import SpriteKit
import Foundation

struct Score {
    static let RIGHT_BLOCK_SCORE = 100;
    static let WRONG_BLOCK_SCORE = 100;
    static let MISSED_BLOCK_SCORE = 50;
}

class GameLevel : NSObject, NSCoding {
    
    var levelNumber : Int!;
    var currentStage : Int = 0;
    var timeDeduction : Int = 0;
    var flashDuration : Double = 0;
    var blinkFirst : Bool = true;
    var blinkLast : Bool = true;
    var gameStageList : Array<GameStage> = [];
    
    override init(){
        super.init();
    }
    
    required init(coder aDecoder: NSCoder) {
        
        self.levelNumber   = Int(aDecoder.decodeIntForKey("levelNumber"));
        self.currentStage  = Int(aDecoder.decodeIntForKey("currentStage"));
        self.timeDeduction = Int(aDecoder.decodeIntForKey("timeDeduction"));
        self.blinkFirst    = aDecoder.decodeBoolForKey("blinkFirst");
        self.blinkLast     = aDecoder.decodeBoolForKey("blinkLast");
        self.flashDuration = aDecoder.decodeDoubleForKey("flashDuration");
        self.gameStageList = aDecoder.decodeObjectForKey("gameStageList") as! Array<GameStage>;
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeInt(Int32(self.levelNumber), forKey:"levelNumber");
        aCoder.encodeInt(Int32(self.currentStage), forKey:"currentStage");
        aCoder.encodeInt(Int32(self.timeDeduction), forKey:"timeDeduction");
        aCoder.encodeBool(self.blinkFirst, forKey:"blinkFirst");
        aCoder.encodeBool(self.blinkLast, forKey:"blinkLast");
        aCoder.encodeDouble(self.flashDuration, forKey:"flashDuration");
        aCoder.encodeObject(self.gameStageList, forKey:"gameStageList");
    }
    
    func addStage(gamePath: Array<CGPoint>){
        
        self.addStage(gamePath, setAsCurrent: false);
    }
    
    func addStage(gamePath: Array<CGPoint>, setAsCurrent: Bool){
        
        var gameStage = GameStage();
        gameStage.gamePath = gamePath;
        
        self.gameStageList.append(gameStage);
        
        if( setAsCurrent ){
            
            self.currentStage = self.gameStageList.count-1;
        }
    }
    
    func removeStage(index: Int){
        
        gameStageList.removeAtIndex(index);
        
        if( currentStage > 0 ){
            
            currentStage -= 1;
        }
    }
    
    func getStage() -> GameStage {
        
        return self.gameStageList[currentStage];
    }
    
    func nextStage(liteVersion: Bool) -> Bool {
        
        currentStage++;
        
        if( currentStage >= self.stages() && !liteVersion ||
            currentStage >= 6 && liteVersion ){

            currentStage = self.stages()-1;
            return false;
        }else{
            
            return true;
        }
    }
    
    func getNextStage() -> GameStage! {
        
        if( currentStage+1 >= self.stages() ){
            
            return nil;
        }else{
            
            return self.gameStageList[currentStage+1];
        }
    }
    
    func stages() -> Int {
        
        return self.gameStageList.count;
    }
    
    class func archiveGameLevelList(gameLevelList : Array<GameLevel>){
        
        var gameLevelListPath = GameLevel.getGameLevelArchivePath();
        var success : Bool = NSKeyedArchiver.archiveRootObject(gameLevelList, toFile: gameLevelListPath);
    }
    
    class func loadArchivedGameLevelList(archive : Bool) -> Array<GameLevel> {
        
        var gameLevelListPath : String = GameLevel.getGameLevelArchivePath();
        
        var gameLevelList : Array<GameLevel> = [];
        var manager : NSFileManager = NSFileManager.defaultManager();
        var fileExists = manager.fileExistsAtPath(gameLevelListPath);
        
        if( fileExists ){
            
            gameLevelList = NSKeyedUnarchiver.unarchiveObjectWithFile(gameLevelListPath) as! Array<GameLevel>;
//            gameLevelList = GameLevel.getClean(gameLevelList);

        }else{
            
            var fileName = GameLevel.getStarterFileName();
            gameLevelListPath = NSBundle.mainBundle().pathForResource(fileName, ofType: "data")!;
            gameLevelList = NSKeyedUnarchiver.unarchiveObjectWithFile(gameLevelListPath) as! Array<GameLevel>;
//            gameLevelList = [GameLevel.getEmptyLevel(true)];
            
//            println("gameLevelList: \(gameLevelList)");
            
            gameLevelList = GameLevel.getClean(gameLevelList)
            
            if( archive ){
                
                GameLevel.archiveGameLevelList(gameLevelList);
            }
        }
        
        return gameLevelList;
    }
    
    class func getStarterFileName() -> String {
        
        if( DeviceType.IS_IPHONE_4_OR_LESS ){
            
            return "starterGameLevelList-iphone4";
        }else if( DeviceType.IS_IPHONE_5 ){
            
            return "starterGameLevelList-iphone5";
        }else if( DeviceType.IS_IPHONE_6 ){
            
            return "starterGameLevelList-iphone6";
        }else if( DeviceType.IS_IPHONE_6P ){
            
            return "starterGameLevelList-iphone6p";
        }
        
        return "starterGameLevelList-ipad";
    }
    
    class func getClean(gameLevelList: Array<GameLevel>) -> Array<GameLevel>{
        
        for gameLevel in gameLevelList {
            
            gameLevel.currentStage = 0;
            
            for gameStage in gameLevel.gameStageList {
                
                gameStage.setMinStars(gameLevel.timeDeduction);
                
                gameStage.stars            = 0;
                gameStage.locked           = true;
                gameStage.stageScore       = 0;
                gameStage.bestScore        = 0;
                gameStage.rightBlocks      = 0;
                gameStage.wrongBlocks      = 0;
                gameStage.missedBlocks     = 0;
                gameStage.bestRightBlocks  = 0;
                gameStage.bestWrongBlocks  = 0;
                gameStage.bestMissedBlocks = 0;
                gameStage.perfectBonus     = 0;
                gameStage.timeBonus        = 0;
                gameStage.deductions       = 0;
                gameStage.elapsedTime      = 0;
            }
        }
        
        return gameLevelList;
    }
    
    class func getEmptyLevel(withFirstStage: Bool) -> GameLevel {
        
        var gameLevel : GameLevel = GameLevel();
        gameLevel.levelNumber   = 1;
        gameLevel.flashDuration = 2.0;
        gameLevel.timeDeduction = 10;
        gameLevel.blinkFirst    = true;
        gameLevel.blinkLast     = true;
        
        if( withFirstStage ){
            
            var gamePath : Array<CGPoint> = [];
            gameLevel.addStage(gamePath);
        }
        
        return gameLevel;
    }
    
    class func getGameLevelArchivePath() -> String {
        
        var paths : Array = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as Array;
        var documentsDirectory : String = paths[0] as! String;
        
//        println("\(documentsDirectory)");
        
        return "\(documentsDirectory)/archivedGameLevelList.data";
    }
    
    class func getCurrentMainScore(gameLevelList: Array<GameLevel>) -> Int {
        
        var mainScore = 0;
        
        for gameLevel in gameLevelList {
            
            for gameStage in gameLevel.gameStageList {
                
                mainScore += gameStage.bestScore;
            }
        }
        
        return mainScore;
    }
    
    func deleteAllStages(){
        
        gameStageList = [];
    }
    
    func getDictionary() -> NSDictionary {
        
        var dictionary : NSDictionary = NSDictionary();
        dictionary.setValue(NSNumber(integer: levelNumber), forKey: "levelNumber");
        dictionary.setValue(NSNumber(integer: currentStage), forKey: "currentStage");
        dictionary.setValue(NSNumber(integer: timeDeduction), forKey: "timeDeduction");
        dictionary.setValue(gameStageList, forKey: "gameStageList");
        
        return dictionary;
    }
    
    class func loadFromDictionary(dictionary: NSDictionary) -> GameLevel {
        
        var gameLevel : GameLevel = GameLevel();
        gameLevel.levelNumber   = (dictionary.objectForKey("levelNumber") as! NSNumber).integerValue;
        gameLevel.currentStage  = (dictionary.objectForKey("currentStage") as! NSNumber).integerValue;
        gameLevel.timeDeduction = (dictionary.objectForKey("timeDeduction") as! NSNumber).integerValue;
        gameLevel.gameStageList = dictionary.objectForKey("gameStageList") as! Array<GameStage>;
        
        return gameLevel;
    }
    
    override var description : String {
        
        return "<GameLevel: levelNumber: \(levelNumber), stages: \(stages()), currentStage: \(currentStage), \n\tgameStageList: \(gameStageList)>";
    }
}
