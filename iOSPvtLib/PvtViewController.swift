//
//  PvtViewController.swift
//  iOSPvt
//
//  Created by Mel Arthurs on 25/03/2021.
//  Copyright © 2021 Mel Arthurs. All rights reserved.
//

import UIKit

public protocol PvtResultDelegate {
    func onResults(_ results: [PvtResultMap])
    func onCancel()
}

public class PvtViewController: UIViewController, PvtDelegate {
    
    private let queue = DispatchQueue.global(qos: .userInteractive)
    private let group = DispatchGroup()
    
    private var pvt: Pvt = Pvt()
    
    var testCount = DEFAULT_TEST_COUNT
    var minInterval = DEFAULT_MIN_INTERVAL
    var maxInterval = DEFAULT_MAX_INTERVAL
    var countDownTime = DEFAULT_COUNTDOWN_TIME
    var stimulusTimeout = DEFAULT_STIMULUS_TIMEOUT
    var postResponseDelay = DEFAULT_POST_RESPONSE_DELAY
    var isTestingConfigEnabled = DEFAULT_IS_TESTING_CONFIG_ENABLED
    
    var delegate: PvtResultDelegate? = nil
    
    private var messageLabel: UILabel!
    private var reactionButton: UIButton!
    
    // TODO: extract this
    private let instructionText = "When the display goes RED, press on the screen as quickly as you are able. Your response time will then be shown in millseconds.\nTouch screen to start the test."
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        pvt = Pvt(
            testCount: testCount,
            minInterval: minInterval,
            maxInterval: maxInterval
        )
        pvt.setDelagate(to: self)
    }

    @objc func reactionOnTouchDown(sender: UIButton!) {
        let reactionTimestamp = Date().unixTimestamp

        switch pvt.curState {
        case is Pvt.Instructions:
            runTest(runCountdown: true)
            
        case is Pvt.Interval:
             pvt.updateState(with: .InvalidReaction)
            
        case is Pvt.StimulusShowing:
            pvt.updateState(with: .ValidReaction(reactionTimestamp: reactionTimestamp))
            
        case is Pvt.Countdown, is Pvt.InvalidReaction, is Pvt.ValidReaction, is  Pvt.Complete:
            break
            
        default:
            fatalError("StateError.unknownState")
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        pvt.curDispatchWorkItem?.cancel()
        if !allTasksComplete() {
            delegate?.onCancel()
        }
    }
    
    private func allTasksComplete() -> Bool {
        pvt.results.count == pvt.testCount
    }
    
    private func runTest(runCountdown: Bool) {
        pvt.curDispatchWorkItem = DispatchWorkItem {
            
            if runCountdown {
                self.runCountdown()
            }
            
            while self.testsRemain() && !self.dispatchItemCancelled() {
                let intervalDelay = self.pvt.getNextIntervalDelay()
                
                self.runInterval(delay: intervalDelay)
                
                if self.pvt.curState is Pvt.InvalidReaction {
                    continue
                }
                
                DispatchQueue.main.async {
                    self.onStimulus()
                }
                
                let startTimestamp = Date().unixTimestamp
                let result = self.runStimulus(
                    startTimestamp: startTimestamp,
                    interval: intervalDelay,
                    testNumber: self.pvt.currentTestIndex()
                )
                
                self.sleepMillis(self.postResponseDelay)
                
                if result == nil {
                    continue
                } else {
                    self.pvt.decrementRemainingTestCount()
                    self.pvt.results.append(result!.map)
                }
            }
            
            if !self.testsRemain() {
                self.handleCompletePvt()
            }
        }
        
        queue.async(group: group, execute: pvt.curDispatchWorkItem!)
    }
    
    private func testsRemain() -> Bool {
        self.pvt.remainingTestCount > 0
    }
    
    private func runInterval(delay: Int64) {
        pvt.updateState(with: .StartInterval)
        sleepMillis(delay)
    }
    
    private func runStimulus(startTimestamp: Int64, interval: Int64, testNumber: Int) -> PvtResult? {
        pvt.updateState(with: .ShowStimulus)
        
        while testHasNotTimedOut(startTimestamp) &&
            !validReactionHasOccurred() &&
            !dispatchItemCancelled() {
                
            DispatchQueue.main.async {
                self.onReactionDelayUpdate(
                    millisElapsed: self.timeSinceCalled(startTimestamp)
                )
            }
        }
        
        if pvt.curState is Pvt.ValidReaction {
            return handleValidReaction(
                startTimestamp: startTimestamp,
                interval: interval,
                testNumber: testNumber
            )
        } else {
            pvt.updateState(with: .InvalidReaction)
            return nil // returning nil as test timed out, no result created
        }
    }
    
    private func validReactionHasOccurred() -> Bool {
        pvt.curState is Pvt.ValidReaction
    }
    
    private func testHasNotTimedOut(_ startTimestamp: Int64) -> Bool {
        timeSinceCalled(startTimestamp) < stimulusTimeout
    }
    
    private func dispatchItemCancelled() -> Bool {
        pvt.curDispatchWorkItem?.isCancelled ?? true
    }
    
    private func timeSinceCalled(_ startTimestamp: Int64) -> Int64 {
        Date().unixTimestamp - startTimestamp
    }
    
    private func sleepMillis(_ millis: Int64) {
        usleep(UInt32(millis * 1000))
    }
    
    private func runCountdown() {
        pvt.updateState(with: .StartCountdown)
        
        for i in (1...5).reversed() {
            
            DispatchQueue.main.async {
                self.onCountdownUpdate(secondsElapsed: i)
            }
            sleep(1)
        }
    }
    
    private func handleValidReaction(
        startTimestamp: Int64,
        interval: Int64,
        testNumber: Int
    ) -> PvtResult {
        let reactionTimestamp = (pvt.curState as! Pvt.ValidReaction).reactionTimestamp
        let reactionDelay = reactionTimestamp - startTimestamp
        
        DispatchQueue.main.async {
            self.onReactionDelayUpdate(millisElapsed: reactionDelay)
        }
        
        return createResult(
            testNumber: testNumber,
            timestamp: startTimestamp,
            interval: interval,
            reactionDelay: reactionDelay
        )
    }
    
    private func createResult(
        testNumber: Int,
        timestamp: Int64,
        interval: Int64,
        reactionDelay: Int64
    ) -> PvtResult {
        if (isTestingConfigEnabled){
            return PvtTestConfigResult(
                testNumber: testNumber,
                timestamp: timestamp,
                interval: interval,
                reactionDelay: reactionDelay
            )
        } else {
            return PvtResult(
                testNumber: testNumber,
                timestamp: timestamp,
                interval: interval,
                reactionDelay: reactionDelay
            )
        }
    }
    
    private func handleCompletePvt() {
        pvt.updateState(with: .Complete)
        
        sleepMillis(self.postResponseDelay)
        
        DispatchQueue.main.async {
            self.onCompleteTest(results: self.pvt.results)
        }
    }
    
    private func onStimulus() {
        setBackgroundColor(to: UIColor.red)
    }
    
    func onStateUpdate(newState: PvtState) {
        switch newState {
        case is Pvt.Countdown:
            setBackgroundColorIfTestingConfigEnabled()
        case is Pvt.Instructions:
            messageLabel.text = instructionText
        case is Pvt.Interval:
            setBackgroundColor(to: UIColor.black)
            messageLabel.text = ""
        case is Pvt.InvalidReaction:
            setBackgroundColor(to: UIColor.black)
            messageLabel.text = "Invalid Reaction"
        case is Pvt.Complete:
            setBackgroundColor(to: UIColor.black)
            messageLabel.text = "Complete\nTest will now close"
        default:
            break
        }
    }
    
    func setBackgroundColorIfTestingConfigEnabled() {
        if isTestingConfigEnabled {
            setBackgroundColor(to: UIColor.green)
        }
    }
    
    func onCountdownUpdate(secondsElapsed: Int) {
        messageLabel.text = String(secondsElapsed)
    }
    
    func onReactionDelayUpdate(millisElapsed: Int64) {
        messageLabel.text = String(millisElapsed)
    }
    
    func onCompleteTest(results: [PvtResultMap]) {
        delegate?.onResults(results)
        dismiss(animated: true)
    }
    
    private func setBackgroundColor(to color: UIColor) {
        view.backgroundColor = color
        messageLabel.backgroundColor = color
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor.black
        
        messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = instructionText
        messageLabel.textColor = UIColor.white
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.font = messageLabel.font.withSize(20)
        messageLabel.textAlignment = .center
        view.addSubview(messageLabel)
        
        reactionButton = UIButton()
        reactionButton.translatesAutoresizingMaskIntoConstraints = false
        reactionButton.addTarget(
            self,
            action: #selector(self.reactionOnTouchDown(sender:)),
            for: .touchDown
        )
        view.addSubview(reactionButton)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            reactionButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            reactionButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            reactionButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            reactionButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
        ])
    }

}
