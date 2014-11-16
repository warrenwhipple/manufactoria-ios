//
//  GameData.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/24/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

// when class variables become available, move into class
private let _gameDataFilePath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingPathComponent("gameData")
private var _gameDataSharedInstance: GameData?

class GameData: NSObject, NSCoding {
  var tutorialsOn: Bool
  var progressArray: [LevelProgressData]
  
  class var sharedInstance: GameData {
    if _gameDataSharedInstance == nil {
      _gameDataSharedInstance = NSKeyedUnarchiver.unarchiveObjectWithFile(_gameDataFilePath) as? GameData ?? GameData()
    }
    return _gameDataSharedInstance!
  }
  
  override init() {
    //levelsComplete = 0
    tutorialsOn = true
    progressArray = LevelLibrary.map {return LevelProgressData(levelSetup: $0)}
  }
  
  required init(coder aDecoder: NSCoder) {
    tutorialsOn = aDecoder.decodeObjectForKey("tutorialsOn") as? Bool ?? true
    progressArray = aDecoder.decodeObjectForKey("progressArray") as? [LevelProgressData] ?? [LevelProgressData]()
    let pCount = progressArray.count
    let lCount = LevelLibrary.count
    if pCount < lCount {
      progressArray += LevelLibrary[lCount-pCount ..< lCount].map {return LevelProgressData(levelSetup: $0)}
    }
  }
  
  func encodeWithCoder(aCoder: NSCoder)  {
    aCoder.encodeObject(tutorialsOn, forKey: "tutorialsOn")
    aCoder.encodeObject(progressArray, forKey: "progressArray")
  }
  
  func save() {
    NSKeyedArchiver.archivedDataWithRootObject(self).writeToFile(_gameDataFilePath, atomically: true)
  }
  
  func resetAllGameData() {
    tutorialsOn = true
    progressArray = LevelLibrary.map {return LevelProgressData(levelSetup: $0)}
    save()
  }
  
  func unlockAllLevels() {
    tutorialsOn = false
    for progress in progressArray {
      progress.isComplete = true
    }
    save()
  }
    
  func completedLevel(levelNumber: Int) {
    if levelNumber < progressArray.count && !progressArray[levelNumber].isComplete {
      progressArray[levelNumber].isComplete = true
      save()
    }
  }
}

class LevelProgressData: NSObject, NSCoding {
  var isComplete: Bool
  
  override init() {
    isComplete = false
  }
  
  init(levelSetup: LevelSetup) {
    isComplete = false
  }
  
  required init(coder aDecoder: NSCoder) {
    isComplete = aDecoder.decodeObjectForKey("isComplete") as? Bool ?? false
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(isComplete, forKey: "isComplete")
  }
}