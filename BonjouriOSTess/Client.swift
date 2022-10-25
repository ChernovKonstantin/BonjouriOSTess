//
//  Client.swift
//  BonjouriOSTess
//
//  Created by Chernov Kostiantyn on 24.10.2022.
//

import Foundation
import Network
import Combine
import SwiftUI

class Client: ObservableObject {
    @Published var status: String = "Not ready"
    @Published var message: String = "empty"
    @ObservedObject var browser = Browser()
    
    let queue = DispatchQueue(label: "Client queue")
    var connection: NWConnection?
    
    var cancellable = Set<AnyCancellable>()
    
    init() {
        browser.$device
            .sink(receiveValue: { [weak self] deviceName in
                if deviceName.count > 0 {
                    self?.start(name: deviceName)
                }
            })
            .store(in: &self.cancellable)
    }
    
    func start(name: String) {
        connection = NWConnection(to: .service(name: name,
                                               type: Constants.serviceType,
                                               domain: Constants.serviceDomain,
                                               interface: nil),
                                  using: Constants.networkParams)
        
        connection?.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .ready:
                self.status = "Connected"
                print("Ready to send")
            case .failed(let error):
                self.status = "Failed"
                print("Client failed with error: \(error)")
            case .cancelled:
                self.status = "Cancelled"
                print("Connection cancelled")
            default:
                self.status = "Not ready"
                print(newState)
                break
            }
        }
        
        connection?.start(queue: .main)
        if let connection = connection {
            receive(on: connection)
        }
    }
    
    func receive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 77777) { [weak self] data, _, _, error in
//        connection.receiveMessage { [weak self] completeContent, contentContext, isComplete, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let data = data, let text = String(data: data, encoding: .utf8) {
                self?.message = text
                print(text)
            }
            self?.receive(on: connection)
        }
    }
    
    func send(message: String) {
        connection?.send(content: message.data(using: .utf8), completion: .idempotent)
    }
}
