//
//  Util.swift
//  iRank Timer
//
//  Created by Luciano Stegun on 08/02/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import SpriteKit
import Foundation

class Util {
    
    class func formatTimeString(var seconds:Float) -> NSString {
        
        var hours : Int   = Int(floor(seconds/3600));
        seconds    -= (Float(hours)*3600);
        var minutes : Int = Int(floor(seconds/60));
        seconds    -= (Float(minutes)*60);
        
        var seconds : Int = Int(seconds);
        
        return NSString(format: "%02d:%02d", minutes, seconds);
    }
    
    class func uniq<S : SequenceType, T : Hashable where S.Generator.Element == T>(source: S) -> [T] {
        var buffer = Array<T>()
        var addedDict = [T: Bool]()
        for elem in source {
            if addedDict[elem] == nil {
                addedDict[elem] = true
                buffer.append(elem)
            }
        }
        return buffer
    }
    
    class func getPlural(value : Int) -> String {
        
        if( value == 1 ){
            
            return "";
        }
        
        return "s";
    }
    
    class func getScreenWidth(view: UIView) -> CGFloat {
        
        var width  = view.frame.size.width;
        var height = view.frame.size.height;
        
        if( Constants.DeviceIdiom.IS_IPAD && height > width ||
            Constants.DeviceIdiom.IS_IPHONE && width > height ){
                
                width = height;
        }
        
        return width;
    }
    
    class func getScreenHeight(view: UIView) -> CGFloat {
        
        var width  = view.frame.size.width;
        var height = view.frame.size.height;
        
        if( Constants.DeviceIdiom.IS_IPAD && height > width ||
            Constants.DeviceIdiom.IS_IPHONE && width > height ){
                
                height = width;
        }
        
        return height;
    }
}

struct Direction {
    
    static let NONE  = 0;
    static let UP    = 1;
    static let RIGHT = 2;
    static let DOWN  = 3;
    static let LEFT  = 4;
    
    static let RIGHT_UP   = 5;
    static let RIGHT_DOWN = 6;
    static let LEFT_UP    = 7;
    static let LEFT_DOWN  = 8;
}

extension UIColor {
    class func defaultColor() -> UIColor {
        
        return UIColor(hue: 0.05, saturation: 0.82, brightness: 0.81, alpha: 1);
    }
}

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}