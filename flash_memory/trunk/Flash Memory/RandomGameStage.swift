//
//  RandomGameStage.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 02/04/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import Foundation

class RandomGameStage : NSObject {
    
    class func getRandomPath(randomBlocks: Int, horizontalBlocks: Int, verticalBlocks: Int, bounds: CGRect) -> Array<CGPoint> {
        
        //        self.resetCreator(sender);
        
        var startPositionX : CGFloat = CGFloat(arc4random_uniform(UInt32(horizontalBlocks)));
        var startPositionY : CGFloat = CGFloat(arc4random_uniform(UInt32(verticalBlocks)));
        
        var positionX: CGFloat = (startPositionX * Block.blockSize) + ((Block.blockSize-1.0)/2 + 0.5);
        var positionY: CGFloat = (startPositionY * Block.blockSize) + ((Block.blockSize-1.0)/2 + 0.5);
        
        var position : CGPoint = CGPointMake(positionX, positionY);
        
        var lastDirection : Int = Direction.NONE;
        var lastPosition : CGPoint = position;
        var randomPath : Array<CGPoint> = [];
        
        var boundsWidth  = bounds.width;
        var boundsHeight = bounds.height;
        
        if( boundsHeight > boundsWidth ){
            
            let boundsTmp = boundsHeight;
            boundsHeight  = boundsWidth;
            boundsWidth   = boundsTmp;
        }
        
        if( UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone && boundsHeight < boundsWidth ){
            
            let boundsTmp = boundsHeight;
            boundsHeight  = boundsWidth;
            boundsWidth   = boundsTmp;
        }
        
        var distance : Int = 0;
        
        for( var i : Int = 0; i < randomBlocks; i++ ){
            
            //            var color : String = (i == 0 ? "red" : (i%2 == 0 ? "green" : "yellow"));
            //            var block = gameScene.drawBlock(position, color: color);
            //            block.alpha = 1.0 - (0.05 * CGFloat(i));
            
            randomPath.append(position);
            
            // --------------- AQUI VAI CALCULAR A PRÓXIMA POSIÇÃO -----------------
            
            var direction : Int;
            var attemptBlock = 0;
            
            do{
                
                distance--;
                
                if( distance <= 0 ){
                    
                    do{
                        
                        direction = Int(arc4random_uniform(5));
                    }while( direction == lastDirection );
                }else{
                    
                    direction = lastDirection;
                }
                
                position = GameScene.getNextPosition(lastPosition, direction: direction);
                
                attemptBlock++;
                
                if( attemptBlock > 50 ){
                    
//                    println("Não conseguiu achar um bloco");
                    break;
                }
                
                if( direction == Direction.RIGHT && lastDirection == Direction.LEFT ||
                    direction == Direction.LEFT && lastDirection == Direction.RIGHT ||
                    direction == Direction.UP && lastDirection == Direction.DOWN ||
                    direction == Direction.DOWN && lastDirection == Direction.UP ||
                    direction == Direction.NONE ){
                        
                        continue;
                }
                
                if( position.x <= Block.blockSize || position.x >= boundsWidth-Block.blockSize || position.y <= (Block.blockSize * 2) || position.y >= boundsHeight-Block.blockSize ){
                    
                    continue;
                }
                
                
                if( contains(randomPath, position) ){
                    
                    continue;
                }
                
                var positionNorth     = GameScene.getNextPosition(position, direction: Direction.UP);
                var positionEast      = GameScene.getNextPosition(position, direction: Direction.RIGHT);
                var positionSouth     = GameScene.getNextPosition(position, direction: Direction.DOWN);
                var positionWest      = GameScene.getNextPosition(position, direction: Direction.LEFT);
                var positionNortheast = GameScene.getNextPosition(position, direction: Direction.RIGHT_UP);
                var positionSoutheast = GameScene.getNextPosition(position, direction: Direction.RIGHT_DOWN);
                var positionNorthwest = GameScene.getNextPosition(position, direction: Direction.LEFT_UP);
                var positionSouthwest = GameScene.getNextPosition(position, direction: Direction.LEFT_DOWN);
                
                var edges = 0;
                
                if( contains(randomPath, positionNorth) ){ edges++ }
                if( contains(randomPath, positionEast) ){ edges++ }
                if( contains(randomPath, positionSouth) ){ edges++ }
                if( contains(randomPath, positionWest) ){ edges++ }
                if( contains(randomPath, positionNortheast) ){ edges++ }
                if( contains(randomPath, positionSoutheast) ){ edges++ }
                if( contains(randomPath, positionNorthwest) ){ edges++ }
                if( contains(randomPath, positionSouthwest) ){ edges++ }
                
                if( edges >= 3 ){
                    
                    continue;
                }
                
//                println("direction: \(direction), lastDirection: \(lastDirection) = \(position), edges: \(edges), distance: \(distance)");
//                println("\(positionNorthwest.x),\(positionNorthwest.y) | \(positionNorth.x),\(positionNorth.y) | \(positionNortheast.x),\(positionNortheast.y) | ");
//                println("\(positionWest.x),\(positionWest.y) | \(position.x),\(position.y) | \(positionEast.x),\(positionEast.y) | ");
//                println("\(positionSouthwest.x),\(positionSouthwest.y) | \(positionSouth.x),\(positionSouth.y) | \(positionSoutheast.x),\(positionSoutheast.y) | ");
//                println("-------------------------------------------");
                
                lastDirection = direction;
                lastPosition  = position;
                
                if( distance <= 0 ){
                    
                    distance = Int(arc4random_uniform(UInt32(randomBlocks/4)));
                    distance = Int(arc4random_uniform(UInt32(7)));
                }
                
                break;
            }while( true );
            
            if( attemptBlock > 50 ){
                
                RandomGameStage.getRandomPath(randomBlocks, horizontalBlocks: horizontalBlocks, verticalBlocks: verticalBlocks, bounds: bounds);
                
                break;
            }
        }
        
        return randomPath;
    }
}
