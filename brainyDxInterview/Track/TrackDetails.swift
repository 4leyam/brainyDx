//
//  TrackDetails.swift
//  brainyDxInterview
//
//  Created by Aleyam  Rich on 21/06/22.
//

import SwiftUI
import MapKit

struct ActivityIndicatorRepresentable : UIViewRepresentable {
   

    @Binding var isAnimating: Bool
    var style : UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorRepresentable>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorRepresentable>) {
        //when outside animation state is set to true the loader will spin otherwise nothing happens
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
    
    
}







struct TrackDetails: View {
    
    @StateObject private var viewModel : TrackListViewModel = TrackListViewModel.shared
    @StateObject var track : TrackDTO
    
    var body: some View {
        VStack {
            getMapView()
            getMoreDetailView()
        }.navigationTitle("Tracker: Detail view")
            .onReceive( NotificationCenter
                          .Publisher(center: .default,
                                     name: Notification.Name.LOCATION_PULSE)) { pub in
                if let cs = self.viewModel.currentTrackingSession {
                    if viewModel.currentTrackingSession?.id == track.id {
                        self.track.pointSet = cs.pointSet
                    }
                }
                
            }
        
    }
    
    
    
    private func getMapView() -> some View {
        
        if (self.viewModel.currentTrackingSession?.id ?? UUID()) == track.id {
            
            if self.viewModel.currentTrackingSession?.pointSet.isEmpty == true {
                return AnyView(VStack {
                  
                    Spacer()
                    
                    HStack {
                    
                        Text("Loading location update")
                        ActivityIndicatorRepresentable(isAnimating: .constant(true), style: UIActivityIndicatorView.Style.medium)
                        
                    }
                    
                    Spacer()
                    
                })
            } else {
                return AnyView( MKViewRepresentable(track: self.track , count: Binding<Int>(get: {
                    self.track.pointSet.count
                }, set: { new in
                    
                })))
            }
            
        } else {
            return AnyView( MKViewRepresentable(track: self.track , count: .constant(0)))
        }

    }
    
    
    private func getMoreDetailView() -> some View {
        VStack {
            if self.track.endTimeStamp == -1 {
            
                Text("Time elapsed: \(Int64(NSDate().timeIntervalSince1970) - track.startTimeStamp) seconds")
                
            } else {
                Text("Time elapsed: \(track.endTimeStamp - track.startTimeStamp) seconds")
            }
                
            
            Text("Point captured: \(track.pointSet.count)")
            
            Button("Stop & save") {
                viewModel.stopTrackCollection()
            }.padding(.top , 20)
        }
    }
    
}

//struct TrackDetails_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetails()
//    }
//}
