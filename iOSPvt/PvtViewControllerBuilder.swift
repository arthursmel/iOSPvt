//
//  PvtViewControllerBuilder.swift
//  iOSPvt
//
//  Created by Mel Arthurs on 25/03/2021.
//  Copyright © 2021 Mel Arthurs. All rights reserved.
//

import Foundation

class PvtViewControllerBuilder {
    private var testCount = DEFAULT_TEST_COUNT
    private var minInterval = DEFAULT_MIN_INTERVAL
    private var maxInterval = DEFAULT_MAX_INTERVAL
    private var countDownTime = DEFAULT_COUNTDOWN_TIME
    private var stimulusTimeout = DEFAULT_STIMULUS_TIMEOUT
    private var postResponseDelay = DEFAULT_POST_RESPONSE_DELAY
    private var delegate: PvtResultDelegate? = nil

    func withTestCount(_ count: Int) -> PvtViewControllerBuilder {
        self.testCount = count
        return self
    }

    func withInterval(min: Int64, max: Int64) -> PvtViewControllerBuilder {
        self.minInterval = min
        self.maxInterval = max
        return self
    }

    func withCountdownTime(_ time: Int64) -> PvtViewControllerBuilder {
        self.countDownTime = time
        return self
    }

    func withStimulusTimeout(_ timeout: Int64) -> PvtViewControllerBuilder {
        self.stimulusTimeout = timeout
        return self
    }

    func withPostResponseDelay(_ delay: Int64) -> PvtViewControllerBuilder {
        self.postResponseDelay = delay
        return self
    }
    
    func withDelegate(_ delegate: PvtResultDelegate) -> PvtViewControllerBuilder {
        self.delegate = delegate
        return self
    }
    
    func build() -> PvtViewController {
        let vc = PvtViewController()

        vc.testCount = testCount
        vc.minInterval = minInterval
        vc.maxInterval = maxInterval
        vc.countDownTime = countDownTime
        vc.stimulusTimeout = stimulusTimeout
        vc.postResponseDelay = postResponseDelay
        vc.delegate = delegate
        
        return vc
    }
}
