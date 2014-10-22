//
//  ManufactoriaScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/21/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class ManufactoriaScene: SKScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  var lastUpdateTime: NSTimeInterval = 0
  
  override init(size: CGSize) {
    super.init(size: size)
  }
  
  override func update(currentTime: NSTimeInterval) {
    // calculate dt
    var dt: NSTimeInterval = currentTime - lastUpdateTime
    lastUpdateTime = currentTime
    if (dt > 0.25) {dt = 1.0/60.0}
    updateDt(dt)
  }
  
  func updateDt(dt: NSTimeInterval) {}

  
  func transitionToTitleScene() {
    view?.presentScene(
      TitleScene(size: view!.bounds.size),
      transition: SKTransition.fadeWithColor(Globals.highlightColor, duration: 1).outInPlay())
  }
  
  func transitionToMenuScene() {
    view?.presentScene(MenuScene(size: view!.bounds.size),
      transition: SKTransition.pushWithDirection(.Right, duration: 0.5).outInPlay())
  }
  
  func transitionToUnlockScene() {
    view?.presentScene(UnlockScene(size: view!.bounds.size),
      transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay())
  }
  
  func transitionToResetScene() {
    view?.presentScene(ResetScene(size: view!.bounds.size),
      transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay())
  }
  
  func transitionToGameSceneWithLevelNumber(levelNumber: Int) {
    if levelNumber == 0 && GameData.sharedInstance.levelsComplete == 0 {
      view?.presentScene(BeltTutorialScene(size: view!.bounds.size),
        transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay())
    } else if levelNumber == 1 && GameData.sharedInstance.levelsComplete == 1 {
      view?.presentScene(SortTutorialScene(size: view!.bounds.size),
        transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay())
    } else if levelNumber == 2 && GameData.sharedInstance.levelsComplete == 2 {
      view?.presentScene(SequenceTutorialScene(size: view!.bounds.size),
        transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay())
    } else if levelNumber == 3 && GameData.sharedInstance.levelsComplete == 3 {
      view?.presentScene(EngineTutorialScene(size: view!.bounds.size),
        transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay())
    } else{
      view?.presentScene(GameScene(size: view!.bounds.size, levelNumber: levelNumber),
        transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay())
    }
  }
}
