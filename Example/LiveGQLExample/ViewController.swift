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
    
    @IBAction func initMessage(_ sender: Any) {
        gql.initServer()
    }
    
    @IBAction func subscribe(_ sender: Any) {
        gql.subscribe(graphql: "subscription {feedbackAdded {id, text}}", identifier: "feed")
    }
    
    @IBAction func unsubscribe(_ sender: Any) {
        gql.unsubscribe(subscribtion: "feed")
    }
    
    @IBAction func closeConnection(_ sender: Any) {
        gql.closeConnection()
    }
}

extension ViewController: LiveGQLDelegate {
    func receivedMessage(text: String) {
        print("Received Message: \(text)")
    }
}

