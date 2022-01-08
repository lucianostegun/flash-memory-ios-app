//
//  GameStageCell.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 29/03/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import UIKit
import Foundation

class GameStageCell : UICollectionViewCell {
    
    @IBOutlet var lblStageNumber : UILabel!;
    @IBOutlet var lblStageScore : UILabel!;
    @IBOutlet var imgBackground : UIImageView!;
    @IBOutlet var imgStar1 : UIImageView!;
    @IBOutlet var imgStar2 : UIImageView!;
    @IBOutlet var imgStar3 : UIImageView!;
    @IBOutlet var imgLocked : UIImageView!;
    @IBOutlet var btnLoadStage : UIGameLevelButton!;
    
    var gameLevel : Int!;
    var gameStage : Int!;
}

class UIGameLevelButton : UIButton {
    
    var gameLevel : Int!;
    var gameStage : Int!;
}