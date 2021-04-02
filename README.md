# iOSPvt

A psychomotor vigilance task (PVT) for iOS.

## Installation

via [Cocoapods](https://cocoapods.org)

```ruby
pod 'iOSPvt', :git => 'https://github.com/arthursmel/iOSPvt', :tag => '0.0.3'
```

## Usage

```swift
import iOSPvt
```

Implement the `PvtResultDelegate` to get the results from the PVT
```swift
func onResults(results: String) {
    print("onResults: \(results)")
}

func onCancel() {
    print("onCancel")
}
```

Use the builder to configure the PVT:

```swift
let pvtViewController = PvtViewControllerBuilder(self)
    .withTestCount(3)
    .withCountdownTime(3 * 1000)
    .withInterval(min: 2 * 1000, max: 4 * 1000)
    .withStimulusTimeout(10 * 1000)
    .build()
```

Present the view controller:

```swift
present(pvtViewController, animated: true)
```

Builder methods:

method | description | Default Value
--- | --- | ---
`.withTestCount(count: Int)` | Number of tasks a user will be asked to complete | 3
`.withCountdownTime(time: Int64)` | The countdown timer duration before the test starts | 3000ms
`.withInterval(min: Int64, max: Int64)` | The interval used to general a random waiting duration before the stimulus is shown | 2000ms, 4000ms
`.withStimulusTimeout(timeout: Int64)` | The maximum duration a user can take to respond | 10000ms
`.withPostResponseDelay(delay: Int64)` | The time the user's response will be held on the screen for | 2000ms

JSON format:
```
[
    {
        "interval": <the random wait time before the stimulus is shown>,
        "reactionDelay": <the time it took for the user to response to the stimulus>,
        "testNumber": <the index of the test the user has completed>,
        "timestamp": <timestamp of reaction>
    }
]

```

## References
The behaviour of the PVT is inspired by [Android cognitive test battery](https://github.com/movisens/AndroidCognitiveTestBattery)
