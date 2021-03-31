//
//  Extensions.swift
//  iOSPvt
//
//  Created by Mel Arthurs on 23/03/2021.
//  Copyright © 2021 Mel Arthurs. All rights reserved.
//

import Foundation

extension Date {
    var unixTimestamp: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
