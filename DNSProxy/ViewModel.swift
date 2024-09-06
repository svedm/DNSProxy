//
//  ViewModel.swift
//  DNSProxy
//
//  Created by Svetoslav on 6.9.2024.
//

import Foundation

final class ViewModel: ObservableObject {
    private lazy var dnsProxyService = DNSProxyService(remoteDNSHost: "1.1.1.1", onNewMessage: onNewMessage)

    @Published var log = [MessageItem]()
    @Published var selectedItem: MessageItem?
    @Published var isRunning = false

    deinit {
        print("Stopping...")
        dnsProxyService.stop()
    }

    func start() {
        dnsProxyService.start()
        isRunning = true
    }

    func stop() {
        dnsProxyService.stop()
        isRunning = false
    }

    func clean() {
        log = []
    }

    func updateSelectedItem(id: MessageItem.ID?) {
        guard let id, let message = log.first(where: { $0.id == id }) else { return print("Not found") }

        selectedItem = message
    }

    private func onNewMessage(_ message: DNSConversation) {
        DispatchQueue.main.async {
            self.log.append(MessageItem(conversation: message))
        }
    }
}
