//
//  ManufactoriaScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/21/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class TransitionScene: SKScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum Kind {case Title, Menu, Game(Int), Unlock, Reset}
  let kind: Kind
  var nextScene: SKScene?
  let secondTransition: SKTransition
  
  init(size: CGSize, kind: Kind, secondTransition: SKTransition) {
    self.kind = kind
    self.secondTransition = secondTransition
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    runAction(SKAction.sequence([
      SKAction.waitForDuration(0),
      SKAction.runBlock({[unowned self] in self.loadNextScene()})
      ]))
  }
  func loadNextScene() {
    switch kind {
    case .Title: nextScene = TitleScene(size: size)
    case .Menu: nextScene = MenuScene(size: size)
    case .Unlock: nextScene = UnlockScene(size: size)
    case .Reset: nextScene = ResetScene(size: size)
    case .Game(let levelNumber):
      if levelNumber == 0 && GameData.sharedInstance.levelsComplete == 0 {
        nextScene = BeltTutorialScene(size: view!.bounds.size)
      } else if levelNumber == 1 && GameData.sharedInstance.levelsComplete == 1 {
        nextScene = SortTutorialScene(size: view!.bounds.size)
      } else if levelNumber == 2 && GameData.sharedInstance.levelsComplete == 2 {
        nextScene = SequenceTutorialScene(size: view!.bounds.size)
      } else if levelNumber == 3 && GameData.sharedInstance.levelsComplete == 3 {
        nextScene = EngineTutorialScene(size: view!.bounds.size)
      } else {
        nextScene = GameScene(size: view!.bounds.size, levelNumber: levelNumber)
      }
    }
    runAction(SKAction.sequence([
      SKAction.waitForDuration(0),
      SKAction.runBlock({[unowned self] in self.presentNextScene()})
      ]))
  }
  func presentNextScene() {
    if nextScene != nil {
      view?.presentScene(nextScene!, transition: secondTransition)
    }
  }
}

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
    view?.presentScene(TransitionScene(size: size, kind: .Title,
      secondTransition: SKTransition.pushWithDirection(.Right, duration: 0.5).inPlay()),
      transition: SKTransition.pushWithDirection(.Right, duration: 0.5).outPlay())
  }
  
  func transitionToMenuScene() {
    view?.presentScene(TransitionScene(size: size, kind: .Menu,
      secondTransition: SKTransition.pushWithDirection(.Right, duration: 0.5).inPlay()),
      transition: SKTransition.pushWithDirection(.Right, duration: 0.5).outPlay())
  }
  
  func transitionToUnlockScene() {
    view?.presentScene(TransitionScene(size: size, kind: .Unlock,
      secondTransition: SKTransition.pushWithDirection(.Left, duration: 0.5).inPlay()),
      transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outPlay())
  }
  
  func transitionToResetScene() {
    view?.presentScene(TransitionScene(size: size, kind: .Reset,
      secondTransition: SKTransition.pushWithDirection(.Left, duration: 0.5).inPlay()),
      transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outPlay())
  }
  
  func transitionToGameSceneWithLevelNumber(levelNumber: Int) {
    view?.presentScene(TransitionScene(size: size, kind: .Game(levelNumber),
      secondTransition: SKTransition.pushWithDirection(.Left, duration: 0.5).inPlay()),
      transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outPlay())
  }
}
