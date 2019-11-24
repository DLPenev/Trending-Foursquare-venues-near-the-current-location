//
//  MainViewController.swift
//  TrendingVenues
//
//  Created by Dobromir Penev on 23.11.19.
//  Copyright © 2019 Dobromir Penev. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UITableViewController {
    
    @IBOutlet weak var stateSegmentedControl: UISegmentedControl!
    
    enum ControllerState {
        case noVenues
        case allVenues
        case about
    }
    
    var venues: [Venue]? {
        didSet {
            if stateSegmentedControl.selectedSegmentIndex == 0 {
                tableView.reloadData()
            }
        }
    }
    let locationManager = CLLocationManager()
    var controlerState: ControllerState = .allVenues
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "UseFixedLocation") {
            getVenues()
        } else {
            updateLocation()
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch controlerState {
        case .allVenues:
            return venues?.count ?? 0
        case .noVenues:
            return 1
        case .about:
            return 4
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch controlerState {
        case .allVenues:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "venueCellId", for: indexPath) as? VenueTableViewCell, let venue = venues?[indexPath.row] else {
                return UITableViewCell()
            }
            cell.nameLabel.text = venue.name
            cell.cityLabel.text = venue.address?.city
            cell.addressLabel.text = venue.address?.street
            if let distance = venue.address?.distance.description {
                cell.distanceLabel.text = "Distance: \(distance) m."
            }
            return cell
        case .noVenues:
            let cell = UITableViewCell()
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "No venues found for your location."
            return cell
        case .about:
            let cell = UITableViewCell()
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "This app takes your current location and shows you up to 5 trends venues around you."
            case 1:
                cell.textLabel?.text = "However, it's quite possible to not find any around you..."
            case 2:
                cell.textLabel?.text = "But you can still try the app by using a fixed location."
            default:
                cell.textLabel?.text = UserDefaults.standard.bool(forKey: "UseFixedLocation") ? "Press to  use your location" : "Press to use New York location"
                cell.textLabel?.textColor = .systemBlue
                cell.textLabel?.textAlignment = .center
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard controlerState == .about, indexPath.row == 3 else {
            return
        }
        let useFixedLocation = UserDefaults.standard.bool(forKey: "UseFixedLocation")
        if !useFixedLocation {
            getVenues()
        } else {
            updateLocation()
        }
        UserDefaults.standard.set(!useFixedLocation, forKey: "UseFixedLocation")
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Actions and funcs
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex, venues == nil) {
        case (0, false):
            tableView.separatorStyle = .singleLine
            controlerState = .allVenues
        case (0, true):
            tableView.separatorStyle = .singleLine
            controlerState = .noVenues
        default:
            tableView.separatorStyle = .none
            controlerState = .about
        }
        tableView.reloadData()
    }

    /** It's used both with real location and with a fixed one if the request is successful and venues are found it will delete old values and return the new ones.
     If the request is successful but no venues are found will change state to .noVenues.
     If the request is unsuccessful will get the old values. */
    private func getVenues(latitude: Double? = nil, longitude: Double? = nil) {
        NetworkManager.sharedInstance.getVenuesRequest(latitude: latitude, longitude: longitude) { (succses, data) in
            if succses {
                CoreDataManager.sharedInstance.persistDataAndSave(response: data) { didFindVenues in
                    if didFindVenues {
                        self.controlerState = .allVenues
                        self.venues = CoreDataManager.sharedInstance.getTrendingVenues()
                    } else {
                        self.controlerState = .noVenues
                        self.venues = nil
                        if self.stateSegmentedControl.selectedSegmentIndex == 0 {
                            self.tableView.reloadData()
                        }
                    }
                }
            } else {
                self.venues = CoreDataManager.sharedInstance.getTrendingVenues()
            }
        }
    }
    
    private func updateLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        if location?.horizontalAccuracy ?? 0 > 0 {
            locationManager.stopUpdatingLocation()
            getVenues(latitude: location?.coordinate.latitude, longitude: location?.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError: \(error.localizedDescription)")
    }
}
