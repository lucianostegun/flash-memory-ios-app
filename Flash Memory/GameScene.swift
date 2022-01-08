
//  GameScene.swift
//  Flash Memory
//
//  Created by Luciano Stegun on 24/03/15.
//  Copyright (c) 2015 Stegun.com. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    var soundEffects : Bool = false;
    var touchesEnabled : Bool = false;
    var creatorMode : Bool = false;
    var tryingMode : Bool = false;
    var movingMode : Bool = false;
    var instructionsMode : Bool = false;
    
    var lastTouchPosition : CGPoint!;
    var lastTouchMovePosition : CGPoint!;
    var gamePath : Array<CGPoint> = [];
    var drawedPath : Array<CGPoint> = [];
    var creatorPath : Array<CGPoint> = [];
    
    var gameLevel : GameLevel!;
    var gameStage : GameStage!;
    
    var blockSoundList : Array<SKAction> = [];
    
    var mainScore : Int = 0;
    var countingTimer : NSTimer!;
    
    var horizontalBlocks : Int = 0;
    var verticalBlocks : Int   = 0;
    
    var blockNumber : Int             = 0;
    var nextSpecialBlockNumber : Int! = nil;
    
    override func didMoveToView(view: SKView) {
        
        drawBackground(view);
        drawBaseBlocks(view);
        
        blockSoundList.append(SKAction.playSoundFileNamed("touch-1.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-2.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-3.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-4.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-5.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-6.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-7.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-8.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-9.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-10.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-11.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-12.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-13.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-14.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-15.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-16.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-17.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-18.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-19.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-20.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-21.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-22.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-23.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-24.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-25.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-26.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-27.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-28.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-29.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-30.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-31.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-32.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-33.mp3", waitForCompletion: false));
        blockSoundList.append(SKAction.playSoundFileNamed("touch-34.mp3", waitForCompletion: false));
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        // Habilita o toque duplo para mover o caminho no modo Criação
        self.userInteractionEnabled = false;
        
        self.touchesMoved(touches, withEvent: event);
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if( !touchesEnabled ){
            
            return;
        }
        
        for touch: AnyObject in touches {
            
            var touchLocation : CGPoint = touch.locationInNode(self);
//            var touchedNode : SKNode! = self.nodeAtPoint(touchLocation);
            var touchedNodes : Array<SKNode>! = self.nodesAtPoint(touchLocation) as! Array<SKNode>
            
            var block : SKBlock!;
            
            for touchedNode in touchedNodes {

                if( touchedNode.name == "base-block" ){
                    
                    block = (touchedNode as! SKBlock);
                    break;
                }
            }
            
            if( block == nil ){
                
                return;
            }
            
//            println("block.alpha: \(block.alpha), block.blinking: \(block.blinking), block.colorName: \(block.colorName), Block.baseAlpha: \(Block.baseAlpha), Block.activeAlpha: \(Block.activeAlpha)");
            
            // Verifica se está tocando longe do último bloco
            if( creatorMode && !tryingMode && !movingMode ){
                
                var lastTouchPositionTmp = lastTouchPosition;
                var distance             = getTouchDistance(block.position, touchPosition: lastTouchPositionTmp);
                
                if( distance > Block.blockSize ){
                    
                    movingMode = true;
                }
            }
            
            if( movingMode ){

                handleMovingMode(block);
                break;
            }
            
            // Verifica se o usuário está desenhando o caminho do jogo
            if( (block.colorName == "black" || block.colorName == "orange" || block.blinking) && block.position != lastTouchPosition ){
                
                // Verifica se existe algum block vermelho apagando e remove
                
                var touchedNodes : Array<SKNode>! = self.nodesAtPoint(touchLocation) as! Array<SKNode>
                for touchedNode in touchedNodes {
                    
                    if( touchedNode.name == "orange-block" ){
                        
                        touchedNode.removeFromParent();
                        break;
                    }
                }
                
                block.removeAllActions();
                updateDrawedPath(block);
            }
            
            // Verifica se o jogador está voltando o caminho
            if( block.colorName == "yellow" && block.alpha >= Block.baseAlpha && !block.blinking ){
                
                undrawPath(block);
            }
            
            if( creatorMode ){
                
                updateResumeInfo();
            }
            
            break; // Permite apenas o primeiro toque
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if( touchesEnabled && (!creatorMode || tryingMode) ){
         
            comparePaths();
        }
        
        movingMode = false;
        lastTouchMovePosition = nil;
        self.userInteractionEnabled = true;
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func addPointToPath(position: CGPoint){
        
        if( creatorMode && !tryingMode ){
            
            creatorPath.append(position);
        }else{
            
            drawedPath.append(position);
            
            if( drawedPath.count <= 34 ){
                
                playCachedSound(drawedPath.count);
            }
        }
    }
    
    func updateDrawedPath(block: SKBlock){
        
        var distance  = getTouchDistance(block.position, touchPosition: lastTouchPosition);
        var direction = getTouchDirection(block.position, touchPosition: &lastTouchPosition);
        
        if( distance > Block.blockSize ){
            
            if( block.blinking ){
                
                return;
            }
            
            drawFlashingBlock(block.position, color: "orange", waitDuration: 0, duration: 0.5);
            return;
        }
        
        if( drawedPath.count > Int(Double(gamePath.count)*1.1) && !tryingMode ){
            
            if( block.blinking ){
                
                return;
            }
            
            drawFlashingBlock(block.position, color: "orange", waitDuration: 0, duration: 0.5);
            return;
        }
        
        if( block.blinking ){
            
            block.stopBlinking();
        }
        
        if( creatorMode ){
            
            if( direction > Direction.RIGHT_UP ){
                
                drawFlashingBlock(block.position, color: "orange", waitDuration: 0, duration: 0.5);
                return;
            }
            
            addPointToPath(block.position)
        }else{
            
            addPointToPath(block.position);
        }
        
        if( block.isSpecial ){
            
            NSNotificationCenter.defaultCenter().postNotificationName("touchedSpecialBlock", object:block);
        }
        
        lastTouchPosition = block.position;
        block.yellowColor();
        block.alpha = Block.activeAlpha;
    }
    
    func undrawPath(block: SKBlock){
        
        var path : Array<CGPoint> = (creatorMode && !tryingMode ? creatorPath : drawedPath);
        
        if( path.count > 1 && block.position == path[path.count-2] ){
            
            var blockTmp : SKBlock = self.nodeAtPoint(lastTouchPosition) as! SKBlock;
            
            blockTmp.blackColor();
            blockTmp.alpha = Block.baseAlpha;
            path.removeLast();
            lastTouchPosition = block.position;
            
            if( !creatorMode && path.count > 0 && path.count <= 34 ){
                
                playCachedSound(path.count);
            }
            
            if( creatorMode && !tryingMode ){
                
                creatorPath = path;
            }else{
                
                drawedPath = path;
            }
        }
    }
    
    func handleMovingMode(block: SKBlock){
        
        var directionMove = getTouchDirection(block.position, touchPosition: &lastTouchMovePosition);
        var distanceMove  = getTouchDistance(block.position, touchPosition: lastTouchMovePosition);
        
        if( distanceMove > 0 ){
            
            movePath(directionMove)
            lastTouchMovePosition = block.position;
        }
    }
    
    func movePath(direction: Int){
        
        var movedPath : Array<CGPoint> = [];
        
        for position in creatorPath {
            
            movedPath.append(GameScene.getNextPosition(position, direction: direction));
        }
        
        creatorPath = [];
        clearAllBlocks();
        resetControls();
        
        lastTouchPosition = movedPath.last;
        
        creatorPath = movedPath;
        redrawCreatorPath(false);
    }
    
    func loadStage(gameLevel: GameLevel, unlock: Bool){

        self.gameLevel = gameLevel;
        self.gameStage = gameLevel.getStage();
        
        gamePath = gameStage.gamePath;

        // Fiz assim para que quando carregar pelo modo CRIAÇÃO não rebloquear a fase
        if( unlock ){
            
            self.gameStage.locked = false;
        }
        
        if( !creatorMode ){
            
            updateResumeInfo()
        }
    }
    
    func updateResumeInfo(){
        
        NSNotificationCenter.defaultCenter().postNotificationName("updateResumeInfo", object:nil);
    }
    
    func getTouchDirection(location: CGPoint, inout touchPosition: CGPoint!) -> Int {
        
        var direction : Int = Direction.NONE;
        
        if( touchPosition == nil ){
            
            touchPosition = location;
        }else{
            
            if( location.x < touchPosition.x ){
                
                if( location.y > touchPosition.y ){
                    direction = Direction.LEFT_UP;
                }else if( location.y < touchPosition.y ){
                    direction = Direction.LEFT_DOWN;
                }else{
                    direction = Direction.LEFT;
                }
            }
            
            if( location.x > touchPosition.x ){
                
                if( location.y > touchPosition.y ){
                    direction = Direction.RIGHT_UP;
                }else if( location.y < touchPosition.y ){
                    direction = Direction.RIGHT_DOWN;
                }else{
                    direction = Direction.RIGHT;
                }
            }
            
            if( location.y > touchPosition.y ){
                
                if( location.x < touchPosition.x ){
                    direction = Direction.LEFT_UP;
                }else if( location.x > touchPosition.x ){
                    direction = Direction.RIGHT_UP;
                }else{
                    direction = Direction.UP;
                }
            }
            
            if( location.y < touchPosition.y ){
                
                if( location.x < touchPosition.x ){
                    direction = Direction.LEFT_DOWN;
                }else if( location.x > touchPosition.x ){
                    direction = Direction.RIGHT_DOWN;
                }else{
                    direction = Direction.DOWN;
                }
            }
        }
        
        return direction;
    }
    
    func getTouchDistance(location: CGPoint, touchPosition: CGPoint!) -> CGFloat {
        
        var distance : CGFloat = 0;
        
        if( touchPosition != nil ){
            
            let xDist : CGFloat = (location.x - touchPosition.x);
            let yDist : CGFloat = (location.y - touchPosition.y);
            distance = sqrt((xDist * xDist) + (yDist * yDist));
        }
        
        return distance;
    }
    
    func drawBackground(view: SKView){
     
        // Quando quiser colocar uma imagem no fundo, descomentar essas linhas
        var background : SKSpriteNode = SKSpriteNode(imageNamed: "stars-bg");
        background.color = UIColor.redColor();
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        self.addChild(background)
    }
    
    func drawBaseBlocks(view: SKView){
        
        var boundsWidth  = view.frame.size.width;
        var boundsHeight = view.frame.size.height;
        
        if( UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad && boundsHeight > boundsWidth ){
            
            let boundsTmp = boundsHeight;
            boundsHeight  = boundsWidth;
            boundsWidth   = boundsTmp;
        }
        
        if( UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone && boundsHeight < boundsWidth ){

            let boundsTmp = boundsHeight;
            boundsHeight  = boundsWidth;
            boundsWidth   = boundsTmp;
        }
        
        horizontalBlocks = Int(ceil(boundsWidth / Block.blockSize));
        verticalBlocks   = Int(ceil(boundsHeight / Block.blockSize));
        
        var positionX: CGFloat = (Block.blockSize-1.0)/2 + 0.5;
        var positionY: CGFloat = (Block.blockSize-1.0)/2 + 0.5;
        var position           = CGPoint(x: positionX, y: positionY);
        
        var baseBlock: SKBlock = SKBlock();
        baseBlock.size = CGSizeMake(Block.blockSize-1.0, Block.blockSize-1.0);
        baseBlock.name = "base-block";
        baseBlock.alpha = Block.baseAlpha;
        baseBlock.zPosition = 1
        baseBlock.blackColor();
        
        var index : Int = 0;
        
        for( var line: Int = 0; line < verticalBlocks; line++ ){
            
            for( var column : Int = 0; column < horizontalBlocks; column++){
                
                var block : SKBlock = baseBlock.copy() as! SKBlock;
                block.position = position;
                block.index    = index++;
                
                self.addChild(block);
                
                position = GameScene.getNextPosition(position, direction: Direction.RIGHT);
            }
            
            positionX = (Block.blockSize-1.0)/2 + 0.5;
            position  = CGPoint(x: positionX, y: position.y);
            
            position = GameScene.getNextPosition(position, direction: Direction.UP);
        }
    }
    
    func drawFlashingBlock(position: CGPoint, color: String, waitDuration: Double, duration: Double) -> SKBlock {
        
        var block: SKBlock = SKBlock();
        block.size = CGSizeMake(Block.blockSize-1.0, Block.blockSize-1.0);
        block.name = "\(color)-block";
        block.alpha = Block.activeAlpha;
        block.position = position;
        block.zPosition = 1
        block.changeColor(color);
        
        self.addChild(block);
        
        let waitAction = SKAction.waitForDuration(waitDuration)
        let fadeAction = SKAction.fadeOutWithDuration(duration)
        let removeAction = SKAction.removeFromParent()
        let sequence = [waitAction, fadeAction, removeAction];
        
        block.runAction(SKAction.sequence(sequence));
        
        return block;
    }
    
    func redrawCreatorPath(animated: Bool){
        
        clearAllBlocks();
        
        if( animated ){
            
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("redrawCreatorBlock:"), userInfo: NSNumber(integer: 0), repeats: false);
        }else{
            
            for position in creatorPath {

                var block : SKBlock = self.nodeAtPoint(position) as! SKBlock;
                block.yellowColor();
                block.alpha = Block.activeAlpha;
            }
        }
    }
    
    func redrawCreatorBlock(timer: NSTimer){
        
        var index : Int = (timer.userInfo as! NSNumber).integerValue;
        
        var position : CGPoint = creatorPath[index];
        var block : SKBlock = self.nodeAtPoint(position) as! SKBlock;
        block.yellowColor();
        
        index++;
        
        if( index < creatorPath.count ){
            
            
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("redrawCreatorBlock:"), userInfo: NSNumber(integer: index), repeats: false);
        }
    }
    
    class func getNextPosition(position: CGPoint, direction: Int) -> CGPoint {
        
        var x = position.x;
        var y = position.y;
        
        switch( direction ){
        case Direction.UP:
            y += Block.blockSize;
            break;
        case Direction.RIGHT:
            x += Block.blockSize;
            break;
        case Direction.DOWN:
            y -= Block.blockSize;
            break;
        case Direction.LEFT:
            x -= Block.blockSize;
            break;
            
            
        case Direction.RIGHT_UP:
            x += Block.blockSize;
            y += Block.blockSize;
            break;
        case Direction.RIGHT_DOWN:
            x += Block.blockSize;
            y -= Block.blockSize;
            break;
        case Direction.LEFT_UP:
            x -= Block.blockSize;
            y += Block.blockSize;
            break;
        case Direction.LEFT_DOWN:
            x -= Block.blockSize;
            y -= Block.blockSize;
            break;
        default:break;
        }
        
        return CGPoint(x: x, y: y);
    }
    
    func comparePaths(){
        
        touchesEnabled = false;
        gameStage.stageScore = 0;
        
        if( countingTimer != nil ){
            
            countingTimer.invalidate();
        }
        
        var block : SKBlock;
        
        block = self.nodeAtPoint(gamePath[0]) as! SKBlock;
        
        if( block.blinking ){
            block.reset();
        }
        
        block = self.nodeAtPoint(gamePath[gamePath.count-1]) as! SKBlock;
        
        if( block.blinking ){
            block.reset();
        }
        
        NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("redrawCompareBlock:"), userInfo: NSNumber(integer: 0), repeats: false);
    }
    
    func redrawCompareBlock(timer: NSTimer){
        
        var index : Int = (timer.userInfo as! NSNumber).integerValue;
        var allClear : Bool = true;
        
        var position : CGPoint = gamePath[index];
        var nodeList : Array<SKNode>! = self.nodesAtPoint(position) as! Array<SKNode>

        
        for node in nodeList {
            
            // Se estiver olhando para um bloco vermelho que está piscando por ter sido tocado errado
            if( node.name != "base-block" ){
                
                continue;
            }

            var block : SKBlock = node as! SKBlock;
            
            if( block.colorName == "yellow" && !block.blinking ){
                
                gameStage.rightBlocks++;
                
                block.greenColor();
                block.alpha = Block.activeAlpha;
            }else if( block.colorName == "black" ){
                
                gameStage.missedBlocks++;
                
                block.yellowColor();
                block.alpha = Block.activeAlpha;
                allClear = false;
            }
        }
        
        index++;
        
        if( index < gamePath.count ){
            
            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("redrawCompareBlock:"), userInfo: NSNumber(integer: index), repeats: false);
        }else{
            
            for position in drawedPath {
                
                var block : SKBlock = self.nodeAtPoint(position) as! SKBlock;
                
                if( block.colorName != "green" ){
                    
                    gameStage.wrongBlocks++;
                    
                    block.orangeColor();
                    block.alpha = Block.baseAlpha;
                    allClear = false;
                }
            }
            
            if( allClear ){
                
                gameStage.perfectBonus = Int((gameStage.rightBlocks * Score.RIGHT_BLOCK_SCORE)/10);
            }
            
            updateScoreBoard();
        }
    }
    
    
    
    
    
    
    func clearAllBlocks(){
        
        for node in (self.children as! Array<SKNode>){
            
            if( node.name == "base-block" ){
                
                node.removeAllActions();
                (node as! SKBlock).blackColor();
                (node as! SKBlock).stopBlinking();
                (node as! SKBlock).isSpecial = false;
                node.alpha = Block.baseAlpha;
            }
        }
    }
    
    func resetGame(){
        
        touchesEnabled = false;
        
        gamePath    = [];
        creatorPath = [];
        drawedPath  = [];
        
        clearAllBlocks();
        
        gameLevel.currentStage = 0;
        
        mainScore = 0;
        NSNotificationCenter.defaultCenter().postNotificationName("hideScoreBoard", object:nil);
        
        if( countingTimer != nil ){
            
            countingTimer.invalidate();
        }
    }
    
    func resetControls(){
        
        drawedPath        = [];
        lastTouchPosition = nil;
        
        touchesEnabled = creatorMode;
        
        gameStage.rightBlocks  = 0;
        gameStage.wrongBlocks  = 0;
        gameStage.missedBlocks = 0;
        gameStage.perfectBonus = 0;
        gameStage.timeBonus    = 0;
        gameStage.deductions   = 0;
        gameStage.stageScore   = 0;
        gameStage.elapsedTime  = 0;
    }
    
    func startGame(){
    
        if( gamePath.count == 0 ){
            
            return;
        }
        
        if( countingTimer != nil ){
            
            countingTimer.invalidate();
        }
        
        var position = CGPoint(x: (Block.blockSize-1.0)/2 + 0.5, y: (Block.blockSize-1.0)/2 + 0.5);
        
        gamePath = gameStage.gamePath;
        
        resetControls();
        
        if( !creatorMode ){
            
            updateResumeInfo();
        }
        
        clearAllBlocks();
        
        NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: Selector("flashGameBlocks"), userInfo: nil, repeats: false);
        NSTimer.scheduledTimerWithTimeInterval(gameLevel.flashDuration+1+1, target: self, selector: Selector("enableTouch"), userInfo: nil, repeats: false);
    }
    
    func enableTouch(){
        
        touchesEnabled = true;
        countingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateElapsedTime"), userInfo: nil, repeats: true);
        
        if( gameLevel.blinkFirst == true ){
            
            var position : CGPoint = gamePath[0];
            var block : SKBlock! = self.nodeAtPoint(position) as! SKBlock;
            
            if( block != nil && block.name == "base-block" ){
                
                block.yellowColor();
                block.alpha = Block.baseAlpha;
                block.startBlinking();
            }
        }
        
        if( gameLevel.blinkLast == true ){
            
            var position : CGPoint = gamePath[gamePath.count-1];
            var block : SKBlock! = self.nodeAtPoint(position) as! SKBlock;
            
            if( block != nil && block.name == "base-block" ){
                
                block.yellowColor();
                block.alpha = Block.baseAlpha;
                block.startBlinking();
            }
        }
    }
    
    func restartStage(){

//        mainScore -= gameStage.stageScore;
    }
    
    func updateElapsedTime(){
        
        gameStage.elapsedTime++;
    }
    
    func flashGameBlocks(){
        
        var key : Int = 0;
        for position in gamePath {
            
            var block = drawFlashingBlock(position,
                color: "yellow",
                waitDuration: gameLevel.flashDuration,
                duration: 1.0);
            
            blockNumber++;
            
            if( nextSpecialBlockNumber != nil && blockNumber == nextSpecialBlockNumber ){
                
                if( key == 0 || key == gamePath.count ){
                    
                    nextSpecialBlockNumber = nextSpecialBlockNumber + 1;
                }else{
                    
                    block.setSpecial();
                    
                    block = self.getBaseBlockAtPoint(block.position);
                        
                    block.isSpecial = true;
                    nextSpecialBlockNumber = nil;
                }
            }
            
            key++;
        }
    }
    
    func updateScoreBoard(){

        NSNotificationCenter.defaultCenter().postNotificationName("updateScoreBoard", object:nil);
    }
    
    func playSound(soundName: String){
  
        playSound(soundName, delay: 0);
    }
    
    
    func playCachedSound(index: Int){

        if( soundEffects ){
            
            self.runAction(blockSoundList[index-1]);
        }
    }
    
    func playSound(soundName: String, delay: Double){
        
        if( soundEffects ){
            
            let waitAction = SKAction.waitForDuration(delay)
            let soundAction = SKAction.playSoundFileNamed(soundName+".mp3", waitForCompletion: false)
            let sequence = [waitAction, soundAction];

            self.runAction(SKAction.sequence(sequence));
        }
    }
    
    func getBaseBlockAtPoint(position: CGPoint) -> SKBlock! {
        
        var nodeList : Array<SKNode>! = self.nodesAtPoint(position) as! Array<SKNode>
        
        var block : SKBlock!;
        
        for node in nodeList {
            
            if( node.name == "base-block" ){
                
                return (node as! SKBlock);
            }
        }
        
        return nil;
    }
}