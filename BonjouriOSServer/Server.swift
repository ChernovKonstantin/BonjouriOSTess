//
//  Server.swift
//  BonjouriOSServer
//
//  Created by Chernov Kostiantyn on 24.10.2022.
//

import Foundation
import Network
import SwiftUI

class Server {
    let queue = DispatchQueue(label: "Network Server Queue")
    let listener: NWListener
    
    var listening = false
    var dead = false
    
    init() throws {
        listener = try NWListener(using: networkParams)
        
        listener.service = NWListener.Service(name: serviceName, type: serviceType)
        
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
        connection.receiveMessage { [weak self] completeContent, contentContext, isComplete, error in
            if let data = completeContent, let text = String(data: data, encoding: .utf8) {
                print("> \(text)")
            }
            self?.receive(on: connection)
        }
    }
}

public let serviceType = "_bonjourTest._tcp"
    public  let serviceDomain = "local"
    public  let serviceName = "BonjourTest"
    public  let networkParams: NWParameters = .udp

