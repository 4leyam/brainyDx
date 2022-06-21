//
//  TrackDTO.swift
//  brainyDxInterview
//
//  Created by Aleyam  Rich on 21/06/22.
//

import Foundation
import MapKit

class TrackDTO : Hashable , Identifiable , ObservableObject {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: TrackDTO, rhs: TrackDTO) -> Bool {
        lhs.id == rhs.id
    }
    
    
    var id : UUID
    var trackName : String
    var startTimeStamp : Int64
    var endTimeStamp : Int64
    @Published var pointSet : [CLLocationCoordinate2D]
    
    init(id : UUID , trackName : String , startTimeStamp : Int64 , endTimeStamp : Int64 , pointSet : [CLLocationCoordinate2D]) {
        self.id = id
        self.trackName = trackName
        self.startTimeStamp = startTimeStamp
        self.endTimeStamp = endTimeStamp
        self.pointSet = pointSet
    }
    
}
