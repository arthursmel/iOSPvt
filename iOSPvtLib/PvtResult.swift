//
//  PvtResult.swift
//  iOSPvt
//
//  Created by Mel Arthurs on 17/03/2021.
//  Copyright © 2021 Mel Arthurs. All rights reserved.
//

import Foundation

public struct PvtResult: Codable {
    let testNumber: Int
    let timeStamp: Int64
    let interval: Int64
    let reactionDelay: Int64
}
