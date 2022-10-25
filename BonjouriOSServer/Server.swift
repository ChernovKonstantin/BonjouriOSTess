//
//  Server.swift
//  BonjouriOSServer
//
//  Created by Chernov Kostiantyn on 24.10.2022.
//

import Foundation
import Network
import SwiftUI

class Server: ObservableObject {
    @Published var status = ""
    @Published var message: String = "empty"
    
    let queue = DispatchQueue(label: "Server queue")
    let listener: NWListener
    private var connection: NWConnection?
    
    init(called: String) throws {
        listener = try NWListener(using: Constants.networkParams)
        
        listener.service = NWListener.Service(name: called, type: Constants.serviceType)
        
        listener.serviceRegistrationUpdateHandler = { (serviceChange) in
            switch(serviceChange) {
            case .add(let endpoint):
                switch endpoint {
                case let .service(name, type, domain, interface):
                    print("Service Name \(name) of type \(type) having domain: \(domain) and interface: \(String(describing: interface?.debugDescription))")
                default:
                    break
                }
            default:
                break
            }
        }
        
        listener.newConnectionHandler = { [weak self] newConnection in
            if let strongSelf = self {
                newConnection.start(queue: .main)
                strongSelf.receive(on: newConnection)
                strongSelf.connection = newConnection
            }
        }
        
        listener.stateUpdateHandler = { [weak self] (newState) in
            switch (newState) {
            case .ready:
                self?.status = "Listening on port: \(String(describing: self?.listener.port))"
                print("Listening on port: \(String(describing: self?.listener.port))")
            case .failed(let error):
                self?.status = "Failed"
                print("Listener failed with error: \(error)")
            case .cancelled:
                self?.status = "Cancelled"
                print("Listener cancelled")
            default:
                self?.status = "Not ready"
                break
            }
        }
        
        listener.start(queue: .main)
    }
    
    func receive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1) { [weak self] data, _, _, error in
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
    
    func send(message: String = "Callback") {
        guard let connection = connection else {
            print("No connection found")
            return
        }
        connection.send(content: message.data(using: .utf8), completion: .idempotent)
    }
}
