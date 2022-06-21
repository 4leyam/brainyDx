//
//  TrackListViewModel.swift
//  brainyDxInterview
//
//  Created by Aleyam  Rich on 21/06/22.
//

import Foundation
import OrderedCollections
import MapKit



extension Notification.Name {
    static var LOCATION_PULSE: Notification.Name {
          return .init(rawValue: "brainy.in.location.pulse")
    }
}


class TrackListViewModel : ObservableObject {
    
    @Published var trackList : OrderedSet<TrackDTO> = OrderedSet()
    @Published var currentTrackingSession : TrackDTO? = nil
    
    static let shared : TrackListViewModel = TrackListViewModel()
    
    private init() {}
    
    func getTrackBy(stringId : String) -> TrackDTO? {
        trackList.first { tmp in
            tmp.id.uuidString == stringId
        }
    }
    
    func startPointCollection(with track : TrackDTO , onUpdate : @escaping () -> Void) {
        if self.currentTrackingSession == nil {
            self.currentTrackingSession = track
            self.trackList.insert(track, at: 0)
            recursiveCollection(onUpdate:  onUpdate)
        }
    }
    
    func stopTrackCollection() {
        let tmp = Int64(NSDate().timeIntervalSince1970)
        currentTrackingSession?.endTimeStamp = tmp
        trackList.first { val in
            val.id == currentTrackingSession?.id
        }?.endTimeStamp = tmp
        DispatchQueue.main.async {
            self.currentTrackingSession = nil
        }
    }
    
    private func recursiveCollection(onUpdate : @escaping () -> Void) {
        if let currentTrackingSession = currentTrackingSession {
            if currentTrackingSession.endTimeStamp == -1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    print("Collecting...")
                    onUpdate()
                    NotificationCenter.default.post(name: .LOCATION_PULSE,
                                                    object: nil,
                                                    userInfo: [:])
                    self.recursiveCollection(onUpdate:  onUpdate)
                }
            }
        }
    }

    
}
