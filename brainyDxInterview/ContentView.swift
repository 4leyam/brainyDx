//
//  ContentView.swift
//  brainyDxInterview
//
//  Created by Aleyam  Rich on 21/06/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TrackList().onAppear{
            print("started")
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
