//
//  ContentView.swift
//  BonjouriOSTess
//
//  Created by Chernov Kostiantyn on 24.10.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var client = Client()
    @State var text = "Message"
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            TextField("title", text: $text)
                .font(.largeTitle)
                .padding()
                .border(.black)
                .cornerRadius(5)
                .padding()
            Button(action: {
                client.send(message: text)
            }, label: {
                Text("Send")
            })
            Spacer()
            Text(client.message)
                .font(.title)
                .frame(width: 200)
            Spacer()
            Text(client.status)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
