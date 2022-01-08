//
//  GameStage.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 25/03/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import SpriteKit
import Foundation

class GameStage : NSObject, NSCoding {
    
    var gamePath : Array<CGPoint>!;
    var stageScore : Int = 0;
    var rightBlocks : Int = 0;
    var wrongBlocks : Int = 0;
    var missedBlocks : Int = 0;
    var perfectBonus : Int = 0;
    var timeBonus : Int = 0;
    var deductions : Int = 0;
    var elapsedTime : Int = 0;
    var min1Star : Int = 0;
    var min2Stars : Int = 0;
    var min3Stars : Int = 0;
    var stars : Int = 0;
    var locked : Bool = true;
    
    var bestScore : Int = 0;
    var bestRightBlocks : Int = 0;
    var bestWrongBlocks : Int = 0;
    var bestMissedBlocks : Int = 0;
    
    override init() {
        super.init();
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init();
        
        var path         = aDecoder.decodeObjectForKey("gamePath") as! Array<String>;
        stageScore       = Int(aDecoder.decodeIntForKey("stageScore"));
        rightBlocks      = Int(aDecoder.decodeIntForKey("rightBlocks"));
        wrongBlocks      = Int(aDecoder.decodeIntForKey("wrongBlocks"));
        missedBlocks     = Int(aDecoder.decodeIntForKey("missedBlocks"));
        perfectBonus     = Int(aDecoder.decodeIntForKey("perfectBonus"));
        timeBonus        = Int(aDecoder.decodeIntForKey("timeBonus"));
        deductions       = Int(aDecoder.decodeIntForKey("deductions"));
        elapsedTime      = Int(aDecoder.decodeIntForKey("elapsedTime"));
        min1Star         = Int(aDecoder.decodeIntForKey("min1Star"));
        min2Stars         = Int(aDecoder.decodeIntForKey("min2Stars"));
        min3Stars         = Int(aDecoder.decodeIntForKey("min3Stars"));
        stars            = Int(aDecoder.decodeIntForKey("stars"));
        locked           = aDecoder.decodeBoolForKey("locked");
        bestScore        = Int(aDecoder.decodeIntForKey("bestScore"));
        bestRightBlocks  = Int(aDecoder.decodeIntForKey("bestRightBlocks"));
        bestWrongBlocks  = Int(aDecoder.decodeIntForKey("bestWrongBlocks"));
        bestMissedBlocks = Int(aDecoder.decodeIntForKey("bestMissedBlocks"));
        
        gamePath = self.getPathFromArchive(path);
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(self.getPathToArchive(), forKey: "gamePath");
        aCoder.encodeInt(Int32(stageScore), forKey: "stageScore");
        aCoder.encodeInt(Int32(rightBlocks), forKey: "rightBlocks");
        aCoder.encodeInt(Int32(wrongBlocks), forKey: "wrongBlocks");
        aCoder.encodeInt(Int32(missedBlocks), forKey: "missedBlocks");
        aCoder.encodeInt(Int32(perfectBonus), forKey: "perfectBonus");
        aCoder.encodeInt(Int32(timeBonus), forKey: "timeBonus");
        aCoder.encodeInt(Int32(deductions), forKey: "deductions");
        aCoder.encodeInt(Int32(elapsedTime), forKey: "elapsedTime");
        aCoder.encodeInt(Int32(min1Star), forKey: "min1Star");
        aCoder.encodeInt(Int32(min2Stars), forKey: "min2Stars");
        aCoder.encodeInt(Int32(min3Stars), forKey: "min3Stars");
        aCoder.encodeInt(Int32(stars), forKey: "stars");
        aCoder.encodeBool(locked, forKey:"locked");
        aCoder.encodeInt(Int32(bestScore), forKey: "bestScore");
        aCoder.encodeInt(Int32(bestRightBlocks), forKey: "bestRightBlocks");
        aCoder.encodeInt(Int32(bestWrongBlocks), forKey: "bestMissedBlocks");
        aCoder.encodeInt(Int32(bestMissedBlocks), forKey: "bestWrongBlocks");
    }
    
    func setMinStars(timeDeduction: Int){
        
        var score        : Int = gamePath.count * Score.RIGHT_BLOCK_SCORE;
        var perfectBonus : Int = Int(Double(score) * 0.1);
        var deduction    : Int = Int(gamePath.count / 5 * timeDeduction);
        var maxScore     : Int = score + perfectBonus - deduction; // Esse é o máximo que o jogador pode conseguir
        
        min3Stars = Int(Double(maxScore) * 0.8);
        min2Stars = Int(min3Stars/2);
        min1Star = Int(min2Stars/4);
        
//        println("min3Stars: \(min3Stars), maxScore: \(maxScore)");
    }
    
    func getPathToArchive() -> Array<String>{
        
        var pathToArchive : Array<String> = [];
        
        for point in self.gamePath{
            
            pathToArchive.append(NSStringFromCGPoint(point));
        }
        
        return pathToArchive;
    }
    
    func getPathFromArchive(path: Array<String>) -> Array<CGPoint>{
        
        var pathFromArchive : Array<CGPoint> = [];
        
        for point in path {
            
            pathFromArchive.append(CGPointFromString(point));
        }
        
        return pathFromArchive;
    }
    
    func getDictionary() -> NSMutableDictionary {
        
        var dictionary : NSMutableDictionary = NSMutableDictionary();
        dictionary.setObject(NSNumber(integer: stageScore), forKey: "stageScore");
        dictionary.setObject(NSNumber(integer: rightBlocks), forKey: "rightBlocks");
        dictionary.setObject(NSNumber(integer: wrongBlocks), forKey: "wrongBlocks");
        dictionary.setObject(NSNumber(integer: missedBlocks), forKey: "missedBlocks");
        dictionary.setObject(NSNumber(integer: perfectBonus), forKey: "perfectBonus");
        dictionary.setObject(NSNumber(integer: timeBonus), forKey: "timeBonus");
        dictionary.setObject(NSNumber(integer: deductions), forKey: "deductions");
        dictionary.setObject(NSNumber(integer: elapsedTime), forKey: "elapsedTime");
        dictionary.setObject(NSNumber(integer: min1Star), forKey: "min1Star");
        dictionary.setObject(NSNumber(integer: min2Stars), forKey: "min2Stars");
        dictionary.setObject(NSNumber(integer: min3Stars), forKey: "min3Stars");
        dictionary.setObject(NSNumber(integer: stars), forKey: "stars");
        dictionary.setObject(NSNumber(integer: bestScore), forKey: "bestScore");
        dictionary.setObject(NSNumber(integer: bestRightBlocks), forKey: "bestRightBlocks");
        dictionary.setObject(NSNumber(integer: bestWrongBlocks), forKey: "bestWrongBlocks");
        dictionary.setObject(NSNumber(integer: bestMissedBlocks), forKey: "bestMissedBlocks");
        dictionary.setObject(getPathToArchive(), forKey: "gamePath");
        
        return dictionary;
    }
    
    class func loadFromDictionary(dictionary: NSDictionary) -> GameStage {
        
        var gameStage : GameStage = GameStage();
        gameStage.gamePath         = gameStage.getPathFromArchive(dictionary.objectForKey("gamePath") as! Array<String>);
        gameStage.stageScore       = (dictionary.objectForKey("stageScore") as! NSNumber).integerValue;
        gameStage.rightBlocks      = (dictionary.objectForKey("rightBlocks") as! NSNumber).integerValue;
        gameStage.wrongBlocks      = (dictionary.objectForKey("wrongBlocks") as! NSNumber).integerValue;
        gameStage.missedBlocks     = (dictionary.objectForKey("missedBlocks") as! NSNumber).integerValue;
        gameStage.perfectBonus     = (dictionary.objectForKey("perfectBonus") as! NSNumber).integerValue;
        gameStage.timeBonus        = (dictionary.objectForKey("timeBonus") as! NSNumber).integerValue;
        gameStage.deductions       = (dictionary.objectForKey("deductions") as! NSNumber).integerValue;
        gameStage.elapsedTime      = (dictionary.objectForKey("elapsedTime") as! NSNumber).integerValue;
        gameStage.min1Star         = (dictionary.objectForKey("min1Star") as! NSNumber).integerValue;
        gameStage.min2Stars        = (dictionary.objectForKey("min2Stars") as! NSNumber).integerValue;
        gameStage.min3Stars        = (dictionary.objectForKey("min3Stars") as! NSNumber).integerValue;
        gameStage.stars            = (dictionary.objectForKey("stars") as! NSNumber).integerValue;
        gameStage.bestScore        = (dictionary.objectForKey("bestScore") as! NSNumber).integerValue;
        gameStage.bestRightBlocks  = (dictionary.objectForKey("bestRightBlocks") as! NSNumber).integerValue;
        gameStage.bestWrongBlocks  = (dictionary.objectForKey("bestWrongBlocks") as! NSNumber).integerValue;
        gameStage.bestMissedBlocks = (dictionary.objectForKey("bestMissedBlocks") as! NSNumber).integerValue;
        
        return gameStage;
    }
    
    override var description : String {
        
        return "<GameStage: locked: \(locked), stageScore: \(stageScore), gamePath: \(gamePath.count)>";
    }
}