//
//  Server.swift
//  Server
//
//  Created by Maxim Kucherov on 24.10.2022.
//

import Foundation
import Network

class Server {
    let queue = DispatchQueue(label: "Network Server Queue")
    let listener: NWListener
    
    var listening = false
    var dead = false
    
    init() throws {
        listener = try NWListener(using: Constants.networkParams)
        
        listener.service = NWListener.Service(name: ProcessInfo().hostName, type: Constants.serviceType)
        
        listener.serviceRegistrationUpdateHandler = { (serviceChange) in
            switch (serviceChange) {
            case .add(let endpoint):
                switch endpoint {
                case let .service(name,_,_,_):
                    print("Listening as \(name)")
                default:
                    break
                }
            default:
                break
            }
        }
        
        listener.newConnectionHandler = { [weak self] newConnection in
            if let strongSelf = self {
                newConnection.start(queue: strongSelf.queue)
                strongSelf.receive(on: newConnection)
            }
        }
        
        listener.stateUpdateHandler = { [weak self] (newState) in
            switch (newState) {
            case .ready:
                print("Listening on port: \(String(describing: self?.listener.port))")
                self?.listening = true
            case .failed(let error):
                print("Listener failed with error: \(error)")
                self?.dead = true
            case .cancelled:
                print("Listener cancelled")
                self?.dead = true
            default:
                break
            }
        }
        
        listener.start(queue: queue)
    }
    
    func receive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 77777) { [weak self] data, _, _, error in
//        connection.receiveMessage { [weak self] completeContent, contentContext, isComplete, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let data = data, let text = String(data: data, encoding: .utf8) {
                print(text)
            }
            self?.receive(on: connection)
        }
    }
}
