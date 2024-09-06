//
//  DNSProxyService.swift
//  DNSProxy
//
//  Created by Svetoslav on 6.9.2024.
//

import Foundation
import Network
import DNS

final class DNSProxyService {
    typealias NewMessage = (DNSConversation) -> Void

    private let remoteDNSHost: String
    private let dnsPort: NWEndpoint.Port = 53

    private let onNewMessage: NewMessage

    private var listener: NWListener?

    init(remoteDNSHost: String, onNewMessage: @escaping NewMessage) {
        self.remoteDNSHost = remoteDNSHost
        self.onNewMessage = onNewMessage
    }

    deinit {
        stop()
    }

    func start() {
        listener = try? NWListener(using: .udp, on: dnsPort)
        listener?.stateUpdateHandler = { state in
            print("Listener state: \(state)")
        }

        listener?.newConnectionHandler = onNewConnection
        listener?.start(queue: .global(qos: .userInitiated))
    }

    func stop() {
        listener?.cancel()
    }

    private func onNewConnection(_ connection: NWConnection) {
        print("New connection from \(connection)")
        connection.start(queue: .global())
        connection.receiveMessage { content, contentContext, isComplete, error in
            if let error { return print(error) }

            guard isComplete, let content else {
                return print("Not complete")
            }


            print("received: \(String(data: content, encoding: .utf8) ?? "n/a")")
            let sender = NWConnection(to: .hostPort(host: .init(self.remoteDNSHost), port: self.dnsPort), using: .udp)
            sender.stateUpdateHandler = {
                print("Sender state \($0)")
            }
            sender.start(queue: .global())

            self.forward(with: sender, data: content) { [weak self] responseData in
                sender.cancel()
                connection.send(content: responseData, completion: .contentProcessed({ error in
                    if let error { print(error) }

                    if let requestMessage = try? Message(deserialize: content), let responseData,
                       let responseMessage = try? Message(deserialize: responseData) {
                        self?.onNewMessage(.init(request: requestMessage, response: responseMessage))
                    }
                    
                    connection.cancel()
                }))
            }
        }
    }

    private func forward(with sender: NWConnection, data: Data, completion: @escaping (Data?) -> Void) {
        sender.send(content: data, completion: .contentProcessed({ error in
            if let error { print(error) }

            sender.receiveMessage(completion: { content, contentContext, isComplete, error in
                completion(content)
            })
        }))
    }
}
