//
//  MessageItem.swift
//  DNSProxy
//
//  Created by Svetoslav on 6.9.2024.
//

import Foundation
import DNS

struct MessageItem: Identifiable, Hashable {
    let id: UUID
    let date: String
    let requestType: String
    let requestQuery: String
    let response: [AnswerItem]

    struct AnswerItem: Identifiable, Hashable {
        var id: UUID
        var name: String
        var unique: String
        var ttl: String
        var ip: String

        init(record: ResourceRecord) {
            id = UUID()
            name = record.name
            unique = record.unique ? "true" : "false"
            ttl = String(record.ttl)
            if let hostRecord = record as? HostRecord<IPv4> {
                ip = hostRecord.ip.presentation
            } else if let hostRecord = record as? HostRecord<IPv6> {
                ip = hostRecord.ip.presentation
            } else {
                ip = ""
            }
        }
    }

    private static let formatter = DateFormatter()

    init(conversation: DNSConversation) {
        id = UUID()
        Self.formatter.dateFormat = "HH:mm:ss"
        self.date = Self.formatter.string(from: conversation.date)
        self.requestType = conversation.request.questions.first?.type.debugDescription ?? "-"
        self.requestQuery = conversation.request.questions.first?.name ?? "-"
        self.response = conversation.response.answers.map(MessageItem.AnswerItem.init)
    }

}
