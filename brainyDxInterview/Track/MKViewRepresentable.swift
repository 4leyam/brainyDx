//
//  MKViewRepresentable.swift
//  brainyDxInterview
//
//  Created by Aleyam  Rich on 21/06/22.
//

import SwiftUI
import MapKit
import OrderedCollections


struct MKViewRepresentable: UIViewRepresentable {
    
    var track : TrackDTO
    @Binding var count : Int
    
    
    class MapCoordinator :NSObject , MKMapViewDelegate {
        
        var track : TrackDTO
        
        init(track : TrackDTO) {
            self.track = track
        }
        
    }
    
    
    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(track: self.track)
    }
    
    
    
    
    
    func makeUIView(context: Context) -> MKMapView {
        
        print("Static object")
        
        let mapView = MKMapView()
        let region = MKCoordinateRegion( center: self.track.pointSet.first! ,
                                         latitudinalMeters: CLLocationDistance(exactly: 50)!,
                                         longitudinalMeters: CLLocationDistance(exactly: 50)!)
        
        
        self.track.pointSet.forEach { tmp in
            let chosenPlace = MKPointAnnotation()
            chosenPlace.title = UUID().uuidString
            chosenPlace.coordinate = tmp
            mapView.addAnnotation(chosenPlace)
        }
        
        
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        
        return mapView
        
    }
    
    
    
    
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        
        let region = MKCoordinateRegion( center: context.coordinator.track.pointSet.last! ,
                                         latitudinalMeters: CLLocationDistance(exactly: 700)!,
                                         longitudinalMeters: CLLocationDistance(exactly: 700)!)
        
            
        
        let chosenPlace = MKPointAnnotation()
        chosenPlace.title = UUID().uuidString
        chosenPlace.coordinate = context.coordinator.track.pointSet.last!
        mapView.addAnnotation(chosenPlace)
            
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
    }
    
    
}


//struct MKViewRepresentable_Previews: PreviewProvider {
//    static var previews: some View {
//        MKViewRepresentable()
//    }
//}
