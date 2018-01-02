![LiveGQL: Use GraphQL Websocket subscription in Swift](http://i.imgur.com/2hFD4w3.png)

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPod](https://img.shields.io/cocoapods/v/LiveGQL.svg)](https://github.com/florianmari/LiveGQL)
[![GraphQL](https://img.shields.io/badge/Designed%20for-GraphQL-ff69b4.svg)]()

LiveGQL is a simple library to use GraphQL Subscribtion on WebSocket based on [Apollo Protocol](https://github.com/apollographql/subscriptions-transport-ws/blob/master/PROTOCOL.md).

The Android version is [here](https://github.com/billybichon/liveGQL)

- [Features](#features)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage](#usage)
- [What's new?](#news)
- [Contributors](#contributors)

## Features

- [x] Connect to a GraphQL WebSocket server
- [x] Send messages
- [x] Subscribe / unsubscribe
- [x] Close connection
- [x] Data handling (delegate)
- [x] Error handling
- [x] Reconnect option
- [x] JSON raw response
- [x] Queue of unsent messages
- [x] Implement all Apollo protocol
- [x] Specify entry protocol

## Requirements

- iOS / tvOS >= 9.0
- Xcode >= 8.1
- Swift >= 3.0

We also use [SocketRocket](https://github.com/facebook/SocketRocket) and [JSONCodable](https://github.com/matthewcheok/JSONCodable), thanks to them

## Communication

- Use issue if you have any problem
- Don't hesitate to contribute to the project with a pull request

## Installation

### CocoaPods

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'LiveGQL', '~> 2.0.0'
end
```

### Carthage

```
github "florianmari/LiveGQL"
```

See [Carthage guide](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for more informations about integrating with Carthage.

### Manually

Just copy files in the Source folder!

## Usage

### Initializing

Important: to not fall out the variable in the scope, please instantiate above your viewDidLoad() for example.

```swift
import LiveGQL

let gql = LiveGQL(socket: "ws://localhost:7003/feedback")

gql.delegate = self
gql.initServer(connectionParams: nil, reconnect: true)
```

You can set a Dictionnary[String:String] as connectionParams like for authentification by example.
The default protocol is now: graphql-subscriptions, but you can specify yours this way

```swift
import LiveGQL
let gql = LiveGQL(socket: "ws://localhost:7003/feedback", protocol: "graphql-subscriptions")
```

### Subscribe / Unsubscribe

#### Subscribe

Just call subscribe method, set an identifier and your subscription query as well.

```swift
gql.subscribe(graphql: "subscription {feedbackAdded {id, text}}", identifier: "feed")
```

These parameters are mandatory but you can specify exposed variables and operation names if you want, look at the signature:

```swift
public func subscribe(graphql query: String, variables: [String: String]?, operationName: String?, identifier: String) {}
```

##### Treat server response

You have to implement delegate method, in your main ViewController (for example) just att that

```swift
override func viewDidLoad() {
        super.viewDidLoad()
        gql.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
```

Below your class add the folowing extension and implement the method:

```swift
extension ViewController: LiveGQLDelegate {
    func receivedMessage(text: String) {
        print("Received Message: \(text)")
    }
}
```

#### Unsubscribe

Just call unsubscribe method and your identifier

```swift
gql.unsubscribe(identifier: "feed")
```

### Close connection

```swift
gql.closeConnection()
```

## What's new?

### 2.0.0
In this second version of LiveGQL, we give up Starscream for using SocketRocket from Facebook, as well, the protocol has been fixed and you can specify yours!

## Contributors

I'd like to thanks these people for their contributions:

[@rhishikeshj] for cleaning the code and implement SocketRocket!
[@duncsand] for adding exposed variables and operationName on subscription call
[@josefdolezal] for giving us Carthage support!


