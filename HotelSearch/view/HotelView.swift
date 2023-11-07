//
//  HotelView.swift
//  HotelSearch
//
//  Created by Rezimxerr on 07/11/23.
//
import SwiftUI
import MapKit

struct HotelView: View {
    @State var trackingMode: MapUserTrackingMode = .none
    @StateObject var model = ViewModel()

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in

            Map(coordinateRegion: $model.region, interactionModes: .all, showsUserLocation: false, userTrackingMode: $trackingMode, annotationItems: model.hotels) { hotel in
                MapAnnotation(coordinate: hotel.placemark.coordinate) {

                    if hotel == model.selectedhotel {
                        Button {
                            print("tapped annotation")
                        } label: {
                            
                            Circle().fill(Color.blue).frame(width: 20)
                        }

                    } else {
                        Button {
                            model.selectedhotel = hotel
                            proxy.scrollTo(hotel.id)
                        } label: {
                            Circle().fill(Color.red).frame(width: 30)
                        }

                    }
                }
            }
            .ignoresSafeArea()
            .onReceive(model.$region) { _ in
                self.model.search()
            }
            .overlay(alignment: .bottom) {
                
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(model.hotels) { hotel in
                                Button {
                                    DispatchQueue.main.async {
                                        model.selectedhotel = hotel
                                    }
                                } label: {
                                    CardView(mapItem: hotel)
                                }
                                .id(hotel.id)
                            }
                        }
                        .padding()
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct CardView: View {

    let mapItem: MKMapItem

    var body: some View {
        VStack {
            Text(mapItem.placemark.name ?? "N/A")
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 20).fill(.white))
                .shadow(radius: 5)
        }
    }

}

class ViewModel: ObservableObject {

    @Published var hotels: [MKMapItem] = []
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -6.121435, longitude: 106.774124), latitudinalMeters: 1000, longitudinalMeters: 1000)
    @Published var selectedhotel: MKMapItem? {
        didSet {
            guard let selectedhotel else { return }
            region = .init(center: selectedhotel.placemark.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        }
    }

    func search() {
        if selectedhotel == nil {
            search(for: "hotel")
        }
    }

    private func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(including: [MKPointOfInterestCategory.hotel])
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)
    }

    private func search(using searchRequest: MKLocalSearch.Request) {
        // Confine the map search area to an area around the user's current location.
        searchRequest.region = region

        // Include only point-of-interest results. This excludes results based on address matches.
        searchRequest.resultTypes = .pointOfInterest

        let local = MKLocalSearch(request: searchRequest)
        local.start { [unowned self] (response, error) in
            guard error == nil else {
                return
            }
            DispatchQueue.main.async {
                self.hotels = response?.mapItems ?? []
            }
        }
    }

}

extension MKMapItem: Identifiable {}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HotelView()
    }
}

