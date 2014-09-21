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
  
  override init(size: CGSize) {
    super.init(size: size)
  }
  
  func transitionToTitleScene() {
    view?.presentScene(
      TitleScene(size: view!.bounds.size),
      transition: SKTransition.fadeWithColor(Globals.strokeColor, duration: 3).outInPlay())
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
    view?.presentScene(GameScene(size: view!.bounds.size, levelNumber: levelNumber),
      transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay())
  }
}
