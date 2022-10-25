//
//  ContentView.swift
//  BonjouriOSServer
//
//  Created by Chernov Kostiantyn on 24.10.2022.
//

import SwiftUI
//import UIKit

struct ContentView: View {
    var server = try! Server()
    var body: some View {
        Text("Hello")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
