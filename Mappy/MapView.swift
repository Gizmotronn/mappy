//
//  MapView.swift
//  Mappy
//
//  Created by Liam Arbuckle on 10/1/2026.
//

import SwiftUI
import MapKit


struct MapView: View {
    @Binding var position: MapCameraPosition
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            Map(position: $position, interactionModes: .all) {
                UserAnnotation()
            }
            .mapStyle(.standard)
            .onAppear {
                locationManager.requestLocation()
            }
            .onChange(of: locationManager.userLocation) { oldValue, newValue in
                if let location = newValue {
                    withAnimation {
                        position = .region(MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))
                    }
                }
            }
        }
    }
}

#Preview {
    @State var previewPosition: MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    return MapView(position: $previewPosition)
}
