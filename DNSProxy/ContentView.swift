//
//  ContentView.swift
//  DNSProxy
//
//  Created by Svetoslav on 6.9.2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State private var selectedItemsIds = Set<MessageItem.ID>()

    var body: some View {
        VStack {
            ScrollViewReader { reader in
                Table(viewModel.log, selection: $selectedItemsIds) {
                    TableColumn("Time", value: \.date)
                        .width(100)
                    TableColumn("Record", value: \.requestType)
                        .width(100)
                    TableColumn("Query", value: \.requestQuery)
                }
                .textSelection(.enabled)
                .onChange(of: selectedItemsIds) { _, new in
                    viewModel.updateSelectedItem(id: new.first)
                }
                .onChange(of: viewModel.log) {
                    if let id = viewModel.log.last?.id {
                        reader.scrollTo(id)
                    }
                }
                HStack {
                    Text("Response")
                    Spacer()
                }
                if let item = viewModel.selectedItem {
                    Table(item.response) {
                        TableColumn("Name", value: \.name)
                        TableColumn("Unique", value: \.unique)
                            .width(100)
                        TableColumn("TTL", value: \.ttl)
                            .width(100)
                        TableColumn("IP", value: \.ip)
                            .width(200)
                    }
                    .textSelection(.enabled)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("StartStop", systemImage: viewModel.isRunning ? "stop.fill" : "play.fill") {
                    if viewModel.isRunning {
                        viewModel.stop()
                    } else {
                        viewModel.start()
                    }
                }
                Button("Clean", systemImage: "trash") {
                    viewModel.clean()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .frame(width: 400, height: 400)
}
