//
//  LevelData.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/2/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import Foundation

class LevelData: NSObject, NSCoding {
  let grid: Grid
  var undoGrids: [Grid]
  var redoGrids: [Grid]
  
  init(levelNumber: Int) {
    let space = LevelLibrary[levelNumber].space
    let filePath = LevelData.filePathForLevelNumber(levelNumber)
    if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
      if let levelData = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? LevelData {
        if levelData.grid.space == space {
          grid = levelData.grid
          undoGrids = levelData.undoGrids
          redoGrids = levelData.redoGrids
          super.init()
          return
        }
      }
    }
    grid = Grid(space: space)
    undoGrids = []
    redoGrids = []
    super.init()
  }
  
  func saveWithLevelNumber(levelNumber: Int) {
    NSKeyedArchiver.archivedDataWithRootObject(self).writeToFile(LevelData.filePathForLevelNumber(levelNumber), atomically: true)
  }
  
  class func filePathForLevelNumber(levelNumber: Int) -> String {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
      .stringByAppendingPathComponent("level\(levelNumber)Data")
  }
  
  // MARK: - NSCoding Methods
  
  required init(coder aDecoder: NSCoder) {
    grid = aDecoder.decodeObjectForKey("grid") as Grid
    undoGrids = aDecoder.decodeObjectForKey("undoGrids") as [Grid]
    redoGrids = aDecoder.decodeObjectForKey("redoGrids") as [Grid]
  }
  
  func encodeWithCoder(aCoder: NSCoder)  {
    aCoder.encodeObject(grid, forKey: "grid")
    aCoder.encodeObject(undoGrids, forKey: "undoGrids")
    aCoder.encodeObject(redoGrids, forKey: "redoGrids")
  }
}