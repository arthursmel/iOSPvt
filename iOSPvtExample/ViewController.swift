//
//  ViewController.swift
//  iOSPvtExample
//
//  Created by Mel Arthurs on 31/03/2021.
//

import UIKit
import iOSPvtLib

class ViewController: UIViewController, PvtResultDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startPvt(_ sender: UIButton) {
    
        let pvtViewController = PvtViewControllerBuilder()
            .withTestCount(3)
            .withCountdownTime(3 * 1000)
            .withInterval(min: 2 * 1000, max: 4 * 1000)
            .withStimulusTimeout(10 * 1000)
            .withPostResponseDelay(2 * 1000)
            .withTestingConfigEnabled(true)
            .build(self)
        
        present(pvtViewController, animated: true)
    }
    
    func onResults(_ results: [PvtResultMap]) {
        print("onResults: \(results)")
    }
    
    func onCancel() {
        print("onCancel")
    }

}
