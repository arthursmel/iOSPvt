//
//  PvtTestConfigResult.swift
//  iOSPvtLib
//
//  Created by Mel Arthurs on 23/04/2021.
//

import UIKit

public let BATTERY_PERCENTAGE = "batteryPercentage"

internal class PvtTestConfigResult : PvtResult {
    
    required init(
        testNumber: Int,
        timestamp: Int64,
        interval: Int64,
        reactionDelay: Int64
    ) {
        super.init(
            testNumber: testNumber,
            timestamp: timestamp,
            interval: interval,
            reactionDelay: reactionDelay
        )
    }
    
    override var map: PvtResultMap {
        get {
            var map = PvtResultMap()
            
            map[TEST_NUMBER] = testNumber
            map[TIMESTAMP] = timestamp
            map[INTERVAL] = interval
            map[REACTION_DELAY] = reactionDelay
            map[BATTERY_PERCENTAGE] = -1
            
            return map
        }
    }
}
