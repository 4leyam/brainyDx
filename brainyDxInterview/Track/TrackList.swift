//
//  TrackList.swift
//  brainyDxInterview
//
//  Created by Aleyam  Rich on 21/06/22.
//

import SwiftUI
import MapKit


class LocationManagerDelegate : NSObject , CLLocationManagerDelegate , ObservableObject {
    
    var currentLocationStatus : CLAuthorizationStatus = .notDetermined
    @Published var latestUserLocation : CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    
    //listen to location authorization changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.currentLocationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.startUpdatingLocation()
        } else {
            TrackListViewModel.shared.currentTrackingSession = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last?.coordinate {
            self.latestUserLocation = location
            manager.stopUpdatingLocation()
            TrackListViewModel.shared.currentTrackingSession = nil
        }
        
    }
    
}



struct TrackList: View {
    
    
    @ObservedObject var locationDelegate : LocationManagerDelegate = LocationManagerDelegate()
    var locationManager : CLLocationManager = CLLocationManager()
    
    
    @StateObject private var viewModel : TrackListViewModel = TrackListViewModel.shared
    @State private var currentActiveNavigation : String = ""
    
    
    var body: some View {
        NavigationView {
            
            
            List {
                
                ForEach(viewModel.trackList) { aTrack in
                    
                    NavigationLink(isActive: isLinkActive(track: aTrack)) {
                        //the destination to the click
                        if let track = viewModel.getTrackBy(stringId: currentActiveNavigation) {
                            TrackDetails(track: track)
                        } else {
                            VStack {
                                Spacer()
                                Text("The current track details is not pupulated.")
                                Spacer()
                            }
                        }
                    } label: {
                        getListItemfor(aTrack: aTrack).onTapGesture {
                            self.currentActiveNavigation = aTrack.id.uuidString
                        }
                    }
                }
                
            }
            .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
            .navigationTitle(Text("Tracker"))
            .navigationBarItems(trailing: Button("New Tracking") {
                    //TODO: launch a new tracking session.
                    
                    if self.locationManager.delegate == nil {
                        self.locationManager.delegate = self.locationDelegate
                    }
                    
                    self.locationManager.pausesLocationUpdatesAutomatically = true
                    if self.locationDelegate.currentLocationStatus == .notDetermined {
                        
                        self.locationManager.requestWhenInUseAuthorization()
                        
                    }
                    startNewTracking()
                    
                    
                    
                    
                })
            
        }
    }
    
    
    private func startNewTracking() {
        
        let tmpTrack = TrackDTO(id: UUID(),
                                trackName: "Auto-Generated track name \(self.viewModel.trackList.count)",
                                startTimeStamp: Int64(NSDate().timeIntervalSince1970),
                                endTimeStamp: -1,
                                pointSet: [])
        
        self.currentActiveNavigation = tmpTrack.id.uuidString
        self.viewModel.startPointCollection(with: tmpTrack) {
            let factor = (Double(self.viewModel.currentTrackingSession?.pointSet.count ?? 1) / 4000)
            self.viewModel.currentTrackingSession?.pointSet.append(
                CLLocationCoordinate2D(latitude:  factor + (locationManager.location?.coordinate.latitude ?? 0),
                                       longitude: factor + (locationManager.location?.coordinate.longitude ?? 0))
            )
        }
        
    }
    
    
    private func isLinkActive(track : TrackDTO) -> Binding<Bool> {
        Binding<Bool>(get: {
            self.currentActiveNavigation == track.id.uuidString
        }, set: { new in
            self.viewModel.stopTrackCollection()
            self.currentActiveNavigation = ""
        })
    }

    private func getListItemfor(aTrack track : TrackDTO) -> some View {
        VStack {
            
            Text(track.trackName)
                .padding()
            
            HStack {
                Text("STARTED: \(self.displayTimeLapse(date: track.startTimeStamp))")
                Spacer()
                if track.endTimeStamp == -1 {
                    Text("Time elapsed: \(Int64(NSDate().timeIntervalSince1970) - track.startTimeStamp) seconds")
                } else {
                    Text("Time elapsed: \(track.endTimeStamp - track.startTimeStamp) seconds")
                }

            }.padding(.trailing , 20)
        }
        .padding(.horizontal , 15)
    }
    
    
    private func displayTimeLapse(date : Int64) -> String {
        let duration : Int
        var lapsedTime : String
        let timestamp = NSDate().timeIntervalSince1970
        let wastedTime : Int64 = (Int64(timestamp) - Int64(date))*Int64(1000)
        
        if wastedTime < (60*1000) {
            lapsedTime = "\(wastedTime / 1000) seconds ago";
        } else if wastedTime < (1000*60*60)  {
            duration = Int(wastedTime/(1000*60))
            if duration > 1 {
                
                lapsedTime = "\(duration) minutes ago"
            } else {
                lapsedTime = "\(duration) minute ago"
            }
        } else if wastedTime < (1000*60*60*24) {
            duration = Int(wastedTime/(1000*60*60))
            if duration > 1 {
                lapsedTime = "\(duration) hours ago"
            } else {
                lapsedTime = "\(duration) hour ago"
            }
        }else if wastedTime < (1000*60*60*24*7) {
            duration = Int(wastedTime/(1000*60*60*24))
            if duration > 1 {
                lapsedTime = "\(duration) days ago"
            } else {
                lapsedTime = "\(duration) day ago"
            }
        } else {
            duration = Int(wastedTime/(1000*60*60*24*7))
            if duration == 1 {
                lapsedTime = "\(duration) week ago"
            } else if duration == 2 {
                
                lapsedTime = "\(duration) week ago"
            } else {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none

                dateFormatter.locale = Locale(identifier: "en_US")
                
                lapsedTime = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(date)))
                
                
            }
        }
        return lapsedTime
    }
    
    
}

//
//struct TrackList_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackList()
//    }
//}
