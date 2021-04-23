//
//  Pvt.swift
//  iOSPvt
//
//  Created by Mel Arthurs on 16/03/2021.
//  Copyright © 2021 Mel Arthurs. All rights reserved.
//

import Foundation

internal let ONE_SECOND = 1000
internal let DEFAULT_TEST_COUNT = 3
internal let DEFAULT_MIN_INTERVAL = Int64(2 * ONE_SECOND)
internal let DEFAULT_MAX_INTERVAL = Int64(4 * ONE_SECOND)
internal let DEFAULT_COUNTDOWN_TIME = Int64(3 * ONE_SECOND)
internal let DEFAULT_STIMULUS_TIMEOUT = Int64(10 * ONE_SECOND)
internal let DEFAULT_POST_RESPONSE_DELAY = Int64(2 * ONE_SECOND)

internal protocol PvtState {
    func consumeAction(action: Pvt.Action) throws -> PvtState
}

internal protocol PvtDelegate {
    func onStateUpdate(newState: PvtState)
}

internal enum StateError: Error {
    case unknownState
    case illegalTransition
}

internal class Pvt {
    
    private var pvtDelagate: PvtDelegate? = nil
    
    var remainingTestCount = 0
    var curDispatchWorkItem: DispatchWorkItem? = nil
    var curState: PvtState = Instructions()
    var results = [PvtResultMap]()
    
    var testCount: Int
    var minInterval: Int64
    var maxInterval: Int64
    
    init(testCount: Int = DEFAULT_TEST_COUNT,
         minInterval: Int64 = DEFAULT_MIN_INTERVAL,
         maxInterval: Int64 = DEFAULT_MAX_INTERVAL) {
        remainingTestCount = testCount
        
        self.testCount = testCount
        self.minInterval = minInterval
        self.maxInterval = maxInterval
    }
    
    func setDelagate(to delagate: PvtDelegate) {
        pvtDelagate = delagate
    }
    
    func updateState(with action: Action) {
        do {
            try curState = curState.consumeAction(action: action)
        } catch {
            fatalError("StateError.illegalTransition")
        }
        
        DispatchQueue.main.async {
            self.pvtDelagate?.onStateUpdate(newState: self.curState)
        }
    }
    
    func decrementRemainingTestCount() {
        remainingTestCount -= 1
    }
    
    func resetRemainingTestCount() {
        remainingTestCount = testCount
    }
    
    func currentTestIndex() -> Int {
        testCount - remainingTestCount
    }
    
    func getNextIntervalDelay() -> Int64 {
        Int64.random(in: minInterval...maxInterval)
    }
    
    struct Instructions: PvtState {
        func consumeAction(action: Action) throws -> PvtState {
            switch (action) {
            case .StartCountdown:
                return Countdown()
            case .Restart:
                return Instructions()
            default:
                throw StateError.illegalTransition
            }
        }
    }

    struct Countdown: PvtState {
        func consumeAction(action: Action) throws -> PvtState {
            switch (action) {
            case .StartInterval:
                return Interval()
            case .Restart:
                return Instructions()
            default:
                throw StateError.illegalTransition
            }
        }
    }

    struct Interval: PvtState {
        func consumeAction(action: Action) throws -> PvtState {
            switch action {
            case .ShowStimulus:
                return StimulusShowing()
            case .InvalidReaction:
                return InvalidReaction()
            case .Restart:
                return Instructions()
            default:
                throw StateError.illegalTransition
            }
        }
    }
    
    struct StimulusShowing: PvtState {
        func consumeAction(action: Pvt.Action) throws -> PvtState {
            switch action {
            case .ValidReaction(let reactionTimestamp):
                return ValidReaction(reactionTimestamp: reactionTimestamp)
            case .InvalidReaction:
                return InvalidReaction()
            case .Restart:
                return Instructions()
            default:
                throw StateError.illegalTransition
            }
        }
    }
    
    struct ValidReaction: PvtState {
        let reactionTimestamp: Int64
        
        func consumeAction(action: Pvt.Action) throws -> PvtState {
            switch action {
            case .StartInterval:
                return Interval()
            case .Complete:
                return Complete()
            case .Restart:
                return Instructions()
            default:
                throw StateError.illegalTransition
            }
        }
    }
    
    struct InvalidReaction: PvtState {
        func consumeAction(action: Pvt.Action) throws -> PvtState {
            switch action {
            case .StartInterval:
                return Interval()
            case .Restart:
                return Instructions()
            default:
                throw StateError.illegalTransition
            }
        }
    }
    
    struct Complete: PvtState {
        func consumeAction(action: Pvt.Action) throws -> PvtState {
            switch action{
            case .Restart:
                return Instructions()
            default:
                return self
            }
        }
    }
    
    enum Action {
        case Restart
        case StartCountdown
        case StartInterval
        case ShowStimulus
        case ValidReaction(reactionTimestamp: Int64)
        case InvalidReaction
        case Complete
    }
}
