//
//  Constants.swift
//  iRank Timer
//
//  Created by Luciano Stegun on 21/04/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import Foundation

struct Constants {
    
    static let LITE_VERSION : Bool = true;
    static let IOS_VERSION   = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue;
    static let APP_URL       = "https://itunes.apple.com/%@/app/flashmem/id980455544";
    static let kBannerUnitID = "ca-app-pub-0504466650636760/5333445750";
    
    
    struct DeviceIdiom {
        
        static let IS_IPAD : Bool = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad);
        static let IS_IPHONE : Bool = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone);
    }
    
    struct ScreenSize {
        
        static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
        static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
        static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCALE = UIScreen.mainScreen().scale;
    }
    
    struct DeviceType {
        
        static let IS_IPHONE_4_OR_LESS = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P        = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    }
}