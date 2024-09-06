//
//  DNSConversation.swift
//  DNSProxy
//
//  Created by Svetoslav on 6.9.2024.
//

import Foundation
import DNS

struct DNSConversation {
    let date: Date = Date()
    var request: Message
    var response: Message
//    var fromHost: String
//    var fromPort: Int
}
