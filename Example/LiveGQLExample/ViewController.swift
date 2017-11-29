//
//  ViewController.swift
//  LiveGQLExample
//
//  Created by Florian Mari on 07/07/2017.
//  Copyright © 2017 Florian. All rights reserved.
//

import UIKit
import LiveGQL

class ViewController: UIViewController {

    let gql = LiveGQL(socket: "ws://localhost:7003/feedback")
    override func viewDidLoad() {
        super.viewDidLoad()
        gql.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func initMessage(_: Any) {
        gql.initServer(connectionParams: nil, reconnect: true)
    }

    @IBAction func subscribe(_: Any) {
        gql.subscribe(graphql: "subscription {feedbackAdded {id, text}}", variables: nil, operationName: nil, identifier: "feed")
    }

    @IBAction func unsubscribe(_: Any) {
        gql.unsubscribe(subscribtion: "feed")
    }

    @IBAction func closeConnection(_: Any) {
        gql.closeConnection()
    }
}

extension ViewController: LiveGQLDelegate {
    func receivedRawMessage(text: String) {
        print("Received Message: \(text)")
    }
}
