//
//  MessageTypes.swift
//  graphql-subscription
//
//  Created by Florian Mari on 06/07/2017.
//  Copyright © 2017 Florian. All rights reserved.
//

import Foundation


/// All Apollo PROTOCOL Message types
enum MessageTypes: String {
    case GQL_CONNECTION_INIT = "connection_init",
        GQL_CONNECTION_ACK = "connection_ack",
        GQL_CONNECTION_ERROR = "connection_error",
        GQL_CONNECTION_KEEP_ALIVE = "keepalive",
        GQL_CONNECTION_TERMINATE = "connection_terminate",
        GQL_START = "start",
        GQL_DATA = "data",
        GQL_ERROR = "error",
        GQL_COMPLETE = "complete",
        GQL_STOP = "stop"
}
