//
//  Browser.swift
//  BonjouriOSTess
//
//  Created by Chernov Kostiantyn on 25.10.2022.
//

import UIKit
import Combine
import Network
import SwiftUI

class Browser: ObservableObject {
    @Published var device = ""
    
    var browser: NWBrowser
    
    init() {
        let bonjourTCP = NWBrowser.Descriptor.bonjour(type: Constants.serviceType , domain: Constants.serviceDomain)
        
        let bonjourParms = NWParameters()
        bonjourParms.allowLocalEndpointReuse = true
        bonjourParms.acceptLocalOnly = true
        bonjourParms.allowFastOpen = true
        
        browser = NWBrowser(for: bonjourTCP, using: bonjourParms)
            browser.stateUpdateHandler = { newState in
              switch newState {
              case .failed(let error):
                print("NW Browser: now in Error state: \(error)")
                self.browser.cancel()
              case .ready:
                print("NW Browser: new bonjour discovery - ready")
              case .setup:
                print("NW Browser: ooh, apparently in SETUP state")
              default:
                break
              }
            }
        browser.browseResultsChangedHandler = { ( results, changes ) in
            print("NW Browser: Scan results found:")
            for result in results {
                print(result.endpoint.debugDescription)
            }
            for change in changes {
                if case .added(let added) = change {
                    print("NW Browser: Added")
                    if case .service(let name, _, _, _) = added.endpoint {
                        self.device = name
                    }
                }
            }
        }
        self.browser.start(queue: .main)
    }
}

