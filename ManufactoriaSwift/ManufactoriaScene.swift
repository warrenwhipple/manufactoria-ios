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
  enum Kind {case Title, Menu, Game(String), Unlock, Reset}
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
    case .Game(let levelKey): nextScene = GameScene(size: view!.bounds.size, levelKey: levelKey)
      /*
      if GameProgressData.sharedInstance.tutorialsOn {
        switch levelKey {
        case "all": nextScene = BeltTutorialScene(size: view!.bounds.size)
        case "sort": nextScene = SortTutorialScene(size: view!.bounds.size)
        case "sequence": nextScene = SequenceTutorialScene(size: view!.bounds.size)
        default: break
        }
      }
      if nextScene == nil {
        nextScene = GameScene(size: view!.bounds.size, levelKey: levelKey)
      }
      */
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
  let transitionTime: NSTimeInterval = 0.3
  
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
      secondTransition: SKTransition.pushWithDirection(.Right, duration: transitionTime).inPlay()),
      transition: SKTransition.pushWithDirection(.Right, duration: transitionTime).outPlay())
  }
  
  func transitionToMenuScene() {
    view?.presentScene(TransitionScene(size: size, kind: .Menu,
      secondTransition: SKTransition.pushWithDirection(.Right, duration: transitionTime).inPlay()),
      transition: SKTransition.pushWithDirection(.Right, duration: transitionTime).outPlay())
  }
  
  func transitionToUnlockScene() {
    view?.presentScene(TransitionScene(size: size, kind: .Unlock,
      secondTransition: SKTransition.pushWithDirection(.Left, duration: transitionTime).inPlay()),
      transition: SKTransition.pushWithDirection(.Left, duration: transitionTime).outPlay())
  }
  
  func transitionToResetScene() {
    view?.presentScene(TransitionScene(size: size, kind: .Reset,
      secondTransition: SKTransition.pushWithDirection(.Left, duration: transitionTime).inPlay()),
      transition: SKTransition.pushWithDirection(.Left, duration: transitionTime).outPlay())
  }
  
  func transitionToGameSceneWithLevelKey(levelKey: String) {
    view?.presentScene(TransitionScene(size: size, kind: .Game(levelKey),
      secondTransition: SKTransition.pushWithDirection(.Left, duration: transitionTime).inPlay()),
      transition: SKTransition.pushWithDirection(.Left, duration: transitionTime).outPlay())
  }
}
