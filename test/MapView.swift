/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A view that hosts an `MKMapView`.
 */

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    var coordinate:CLLocationCoordinate2D
    var map:MKMapView!
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.isUserInteractionEnabled = false
        let delegate = MyMapView()
        map.delegate = delegate
        return map
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        view.setRegion(region, animated: true)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        view.addAnnotation(pin)
    }
    
}

class MyMapView : NSObject, MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("added")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return MKPinAnnotationView()
    }
    
}

#if DEBUG
struct MapView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        MapView(coordinate: testData.first!.coordinate)
    }
}
#endif
