//
//  SKBlock.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 24/03/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import SpriteKit
import Foundation

struct Block {
    static let baseAlpha : CGFloat = 0.65;
    static let activeAlpha : CGFloat = 0.95;
    static let blockSize : CGFloat = 32.0;
}

class SKBlock: SKSpriteNode {
    
    var index : Int!;
    var colorName : String = "black";
    var blinking : Bool = false;
    var blinkTimer : NSTimer!;
    
    func orangeColor(){
        
        changeColor("orange");
    }
    
    func yellowColor(){
        
        changeColor("yellow");
    }
    
    func greenColor(){
        
        changeColor("green");
    }
    
    func blackColor(){
        
        changeColor("black");
    }
    
    func changeColor(color: String){
        
        colorName = color;
//        self.texture = SKTexture(imageNamed: "square-\(color)");
        
        switch( colorName ){
        case "black":
            self.color = UIColor.blackColor();
            break;
        case "yellow":
            self.color = UIColor(red: 255/255, green: 192/255, blue: 0/255, alpha: 1);
            break;
        case "green":
            self.color = UIColor(red: 145/255, green: 217/255, blue: 38/255, alpha: 1);
            break;
        case "orange":
            self.color = UIColor(red: 217/255, green: 83/255, blue: 38/255, alpha: 1);
            break;
        case "red":
            self.color = UIColor.redColor();
            break;
        default:
            break;
        }
    }
    
    func startBlinking(){
        
        if( blinking ){
            
            return;
        }
        
        blinking   = true;
        blinkTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("blink"), userInfo: nil, repeats: true);
    }
    
    func stopBlinking(){
        
        if( !blinking ){
            
            return;
        }
        
        blinking = false;
        blinkTimer.invalidate();
    }
    
    func blink(){
        
        if( self.colorName == "black" ){
            
            self.alpha = Block.baseAlpha;
            self.yellowColor();
        }else{
            
            self.alpha = Block.baseAlpha;
            self.blackColor();
        }
    }
    
    func reset(){
        
        self.stopBlinking();
        self.blackColor();
        self.alpha = Block.baseAlpha
    }
}