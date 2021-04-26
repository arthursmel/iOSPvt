//
//  PvtResult.swift
//  iOSPvt
//
//  Created by Mel Arthurs on 17/03/2021.
//  Copyright © 2021 Mel Arthurs. All rights reserved.
//

import Foundation

public typealias PvtResultMap = [String : Any]

public let TEST_NUMBER = "testNumber"
public let TIMESTAMP = "timestamp"
public let INTERVAL = "interval"
public let REACTION_DELAY = "reactionDelay"

internal class PvtResult {
    private let RESULT_MAP_FIELD_COUNT = 4
    
    let testNumber: Int
    let timestamp: Int64
    let interval: Int64
    let reactionDelay: Int64
    
    required init(
        testNumber: Int,
        timestamp: Int64,
        interval: Int64,
        reactionDelay: Int64
    ) {
        self.testNumber = testNumber
        self.timestamp = timestamp
        self.interval = interval
        self.reactionDelay = reactionDelay
    }

    var map: PvtResultMap {
        get {
            var map = PvtResultMap()
            
            map[TEST_NUMBER] = testNumber
            map[TIMESTAMP] = timestamp
            map[INTERVAL] = interval
            map[REACTION_DELAY] = reactionDelay
            
            return map
        }
    }
}
