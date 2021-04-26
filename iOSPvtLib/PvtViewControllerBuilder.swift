//
//  PvtViewControllerBuilder.swift
//  iOSPvt
//
//  Created by Mel Arthurs on 25/03/2021.
//  Copyright © 2021 Mel Arthurs. All rights reserved.
//

import Foundation

public class PvtViewControllerBuilder {
    private var testCount = DEFAULT_TEST_COUNT
    private var minInterval = DEFAULT_MIN_INTERVAL
    private var maxInterval = DEFAULT_MAX_INTERVAL
    private var countDownTime = DEFAULT_COUNTDOWN_TIME
    private var stimulusTimeout = DEFAULT_STIMULUS_TIMEOUT
    private var postResponseDelay = DEFAULT_POST_RESPONSE_DELAY
    private var isTestingConfigEnabled = DEFAULT_IS_TESTING_CONFIG_ENABLED
    private var delegate: PvtResultDelegate? = nil
    
    public init() {}
    
    public func withTestCount(_ count: Int) -> PvtViewControllerBuilder {
        self.testCount = count
        return self
    }

    public func withInterval(min: Int64, max: Int64) -> PvtViewControllerBuilder {
        self.minInterval = min
        self.maxInterval = max
        return self
    }

    public func withCountdownTime(_ time: Int64) -> PvtViewControllerBuilder {
        self.countDownTime = time
        return self
    }

    public func withStimulusTimeout(_ timeout: Int64) -> PvtViewControllerBuilder {
        self.stimulusTimeout = timeout
        return self
    }

    public func withPostResponseDelay(_ delay: Int64) -> PvtViewControllerBuilder {
        self.postResponseDelay = delay
        return self
    }
    
    public func withTestingConfigEnabled(_ isTestingConfigEnabled: Bool) -> PvtViewControllerBuilder {
        self.isTestingConfigEnabled = isTestingConfigEnabled
        return self
    }
    
    public func build(_ delegate: PvtResultDelegate) -> PvtViewController {
        let vc = PvtViewController()

        vc.testCount = testCount
        vc.minInterval = minInterval
        vc.maxInterval = maxInterval
        vc.countDownTime = countDownTime
        vc.stimulusTimeout = stimulusTimeout
        vc.postResponseDelay = postResponseDelay
        vc.isTestingConfigEnabled = isTestingConfigEnabled
        vc.delegate = delegate
        
        return vc
    }
}
