//
//  PvtResult.swift
//  iOSPvt
//
//  Created by Mel Arthurs on 17/03/2021.
//  Copyright © 2021 Mel Arthurs. All rights reserved.
//

import Foundation

internal typealias PvtResultMap = [String : Any]

internal class PvtResult {
    
    private let TEST_NUMBER = "testNumber"
    private let TIMESTAMP = "timestamp"
    private let INTERVAL = "interval"
    private let REACTION_DELAY = "reactionDelay"

    private let RESULT_MAP_FIELD_COUNT = 4
    
    let testNumber: Int
    let timestamp: Int64
    let interval: Int64
    let reactionDelay: Int64
    
    init(
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
