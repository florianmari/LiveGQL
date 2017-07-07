![LiveGQL: Use GraphQL Websocket subscription in Swift](http://i.imgur.com/kW0Mtet.png)

LiveGQL is a simple library to use GraphQL Subscribtion on WebSocket based on [Apollo Protocol](https://github.com/apollographql/subscriptions-transport-ws/blob/master/PROTOCOL.md).

*Hello folks! I made this simple prototype of a future complete library, you can try it now and see in your console how does it work! I will provide a fully functionnal version next week! But it's ready to use in development*

- [Features](#features)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage](#usage)
- [Bugs](#bugs)

## Features

- [x] Connect to a GraphQL WebSocket server
- [x] Send messages
- [x] Subscribe / unsubscribe
- [x] Close connection
- [x] Data handling (delegate)
- [ ] Error handling
- [ ] JSON parsing
- [ ] Implement all Apollo protocol (today just Client part totally implemented)

## Requirements

- iOS 9.0
- Xcode >= 8.1
- Swift >= 3.0

We also use [Starscream](https://github.com/daltoniam/Starscream) and [JSONCodable](https://github.com/matthewcheok/JSONCodable), thank you them

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
    pod 'LiveGQL', '~> 0.0.4'
end
```

### Manually

Just copy files in the Source folder!


## Usage

### Initializing

Important: to not fall out the variable in the scope, please instantiate above your viewDidLoad() for example.

```swift
import LiveGQL

let gql = LiveGQL(socket: "ws://localhost:7003/feedback")

gql.initServer()
```

### Subscribe / Unsubscribe

#### Subscribe

Just call subscribe method, set an identifier and your subscription query as well.

```swift
gql.subscribe(graphql: "subscription {feedbackAdded {id, text}}", identifier: "feed")
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
gql.unsubscribe(subscribtion: "feed")
```

### Close connection

```swift
gql.closeConnection()
```

## Bugs

Bugs I know:

- I don't verify if the initMessage (initServer()) has been sent (if it hasn't subscribe doesn't work)
- closeConnection() may be bug
- Error are not handled but your app won't crash (because it's on the stream ;))