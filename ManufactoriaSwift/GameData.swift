//
//  GameProgressData.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/24/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

// when class variables become available, move into class
private let _gameDataFilePath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingPathComponent("gameData")
private let _gameDataSharedInstance = GameProgressData()

class GameProgressData: NSObject, NSCoding {
  var tutorialsOn: Bool
  var levelProgressDictionary: [String:LevelProgressData]
  
  class var sharedInstance: GameProgressData {
    return _gameDataSharedInstance
  }
  
  override init() {
    if let loadedGameProgressData = NSKeyedUnarchiver.unarchiveObjectWithFile(_gameDataFilePath) as? GameProgressData {
      tutorialsOn = loadedGameProgressData.tutorialsOn
      levelProgressDictionary = loadedGameProgressData.levelProgressDictionary
    } else {
      tutorialsOn = false
      levelProgressDictionary = LevelLibrary.map {return LevelProgressData(levelSetup: $0)}
    }
  }
  
  required init(coder aDecoder: NSCoder) {
    tutorialsOn = aDecoder.decodeObjectForKey("tutorialsOn") as? Bool ?? true
    levelProgressDictionary = aDecoder.decodeObjectForKey("levelProgressDictionary") as? [String:LevelProgressData] ?? [String:LevelProgressData]()
    for key in LevelLibrary.keys {
      if levelProgressDictionary[key] == nil {
        levelProgressDictionary[key] = LevelProgressData(levelSetup: LevelLibrary[key]!)
      }
    }
  }
  
  func encodeWithCoder(aCoder: NSCoder)  {
    aCoder.encodeObject(tutorialsOn, forKey: "tutorialsOn")
    aCoder.encodeObject(levelProgressDictionary, forKey: "levelProgressDictionary")
  }
  
  func save() {
    NSKeyedArchiver.archivedDataWithRootObject(self).writeToFile(_gameDataFilePath, atomically: true)
  }
  
  func resetAllGameProgressData() {
    tutorialsOn = false
    levelProgressDictionary = LevelLibrary.map {return LevelProgressData(levelSetup: $0)}
    save()
  }
  
  func unlockAllLevels() {
    tutorialsOn = false
    for levelProgressData in levelProgressDictionary.values {
      levelProgressData.isComplete = true
    }
    save()
  }
    
  func completedLevelWithKey(levelKey: String) {
    if let levelProgressData = levelProgressDictionary[levelKey] {
      levelProgressData.isComplete = true
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