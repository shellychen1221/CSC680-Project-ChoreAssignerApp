import SwiftUI
import CoreLocation
import MapKit

struct ExpenseEditorView: View {
    @ObservedObject var expenseManager: ExpenseManager
    @Binding var isPresented: Bool
    var expense: Expense?
    var onSave: (Expense) -> Void
    
    @State private var amount: String = ""
    @State private var category: String = ""
    @State private var contributors: String = ""
    @State private var date: Date = Date()
    @State private var isSettled: Bool = false
    @StateObject private var locationHelper = LocationHelper()
    
    var body: some View {
        VStack {
            Form {
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                TextField("Category", text: $category)
                TextField("Contributors", text: $contributors)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Toggle("Settled", isOn: $isSettled)
                
                if let location = locationHelper.location {
                    Text("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    if let locationDescription = locationHelper.locationDescription {
                        Text("Area: \(locationDescription)")
                    } else {
                        Text("Fetching location details...")
                    }
                } else {
                    Text("Location: Updating...")
                }
                
                Button(action: {
                    saveExpense()
                }) {
                    Text("Save")
                }
            }
            
            MapView(location: $locationHelper.location)
                .frame(height: 200)
        }
        .onAppear {
            resetStateVariables()
            
            if let expense = expense {
                amount = "\(expense.amount)"
                category = expense.category
                contributors = expense.contributors.joined(separator: ", ")
                date = expense.date
                isSettled = expense.isSettled
                if let latitude = expense.latitude, let longitude = expense.longitude {
                    let expenseLocation = CLLocation(latitude: latitude, longitude: longitude)
                    locationHelper.location = expenseLocation
                    locationHelper.fetchLocationDescription(for: expenseLocation)
                }
            } else {
                locationHelper.startUpdatingLocation()
            }
        }
        .navigationBarTitle(expense != nil ? "Edit Expense" : "Add Expense")
    }
    
    private func resetStateVariables() {
        amount = expense?.amount.description ?? ""
        category = expense?.category ?? ""
        contributors = expense?.contributors.joined(separator: ", ") ?? ""
        date = expense?.date ?? Date()
        isSettled = expense?.isSettled ?? false
        
        if expense == nil {
            locationHelper.startUpdatingLocation()
        }
    }
    
    private func saveExpense() {
        let contributorsArray = contributors.components(separatedBy: ",")
        
        let updatedExpense = Expense(
            id: expense?.id ?? UUID(),
            amount: Double(amount) ?? 0.0,
            category: category,
            contributors: contributorsArray,
            date: date,
            isSettled: isSettled,
            latitude: locationHelper.location?.coordinate.latitude,
            longitude: locationHelper.location?.coordinate.longitude
        )
        
        onSave(updatedExpense)
        
        // Clear user input
        amount = ""
        category = ""
        contributors = ""
        date = Date()
        isSettled = false
        
        isPresented = false
    }
}

struct MapView: UIViewRepresentable {
    @Binding var location: CLLocation?
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        
        if let location = location {
            let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            uiView.addAnnotation(annotation)
            
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            uiView.setRegion(region, animated: true)
        }
    }

    

}


class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var geocoder = CLGeocoder()
    
    @Published var authorized = false
    @Published var location: CLLocation?
    @Published var locationDescription: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        requestAuthorization()
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        if authorized {
            print("Starting location updates...")
            locationManager.startUpdatingLocation()
        } else {
            print("Not authorized to start location updates.")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Authorization granted.")
            authorized = true
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Authorization denied or restricted.")
            authorized = false
        case .notDetermined:
            print("Authorization not determined.")
            authorized = false
        @unknown default:
            fatalError("Unhandled authorization status.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        location = newLocation
        print("Updated location: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
        fetchLocationDescription(for: newLocation)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func fetchLocationDescription(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let error = error {
                print("Failed to reverse geocode location: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                self.locationDescription = [
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ]
                .compactMap { $0 }
                .joined(separator: ", ")
            }
        }
    }
}

struct ExpenseRow: View {
    var expense: Expense
    var onEdit: () -> Void
    
    var body: some View {
        Button(action: {
            onEdit()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount: \(expense.amount)")
                        .font(.headline)
                    Text("Category: \(expense.category)")
                        .font(.subheadline)
                    Text("Contributors: \(expense.contributors.joined(separator: ", "))")
                        .font(.subheadline)
                    Text("Date: \(expense.date, formatter: dateFormatter)")
                        .font(.subheadline)
                }
                .padding(.vertical)
                
                Spacer()
                
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.blue)
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

    
