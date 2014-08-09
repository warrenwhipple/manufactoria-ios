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
  var levelsComplete: Int
  
  class var sharedInstance: GameData {
  if _gameDataSharedInstance == nil {
    if NSFileManager.defaultManager().fileExistsAtPath(_gameDataFilePath) {
      _gameDataSharedInstance =  NSKeyedUnarchiver.unarchiveObjectWithFile(_gameDataFilePath) as? GameData
    }
    if _gameDataSharedInstance == nil {_gameDataSharedInstance = GameData()}
    }
    return _gameDataSharedInstance!
  }
  
  override init() {
    levelsComplete = 0
  }
  
  required init(coder aDecoder: NSCoder) {
    if let decoded = aDecoder.decodeObjectForKey("levelsComplete") as Int? {
      levelsComplete = decoded
    } else {
      levelsComplete = 0
    }
  }
  
  
  func encodeWithCoder(aCoder: NSCoder)  {
    aCoder.encodeObject(levelsComplete, forKey: "levelsComplete")
  }
  
  func save() {
    NSKeyedArchiver.archivedDataWithRootObject(self).writeToFile(_gameDataFilePath, atomically: true)
  }
    
  func completedLevel(levelNumber: Int) {
    levelsComplete = max(levelsComplete, levelNumber + 1)
    save()
  }
}