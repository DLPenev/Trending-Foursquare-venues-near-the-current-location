//
//  NetworkManager.swift
//  TrendingVenues
//
//  Created by Dobromir Penev on 23.11.19.
//  Copyright © 2019 Dobromir Penev. All rights reserved.
//

import UIKit

class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    
    /** The default coordinates are New York coordinates and are used when a fixed location is used */
    func getVenuesRequest(latitude: Double? = 40.7127, longitude: Double? = -74.0059 ,completion: @escaping (_ succes: Bool, _ data: [String: Any]?)->()) {
        
        // Acording to Foursquare documentation 'v' should be fixed instead of use current day, also radius should not be requiered but there are cases when more venues are found with radious set
        var parameters = [String : String]()
        parameters["client_id"] = "ESJLWO1UQY3CHSPW22VOY2WCWPODHIKOVG1HBNO0KLPKZSI1"
        parameters["client_secret"] = "JLFHNL3QQ4MWJH3PGQTTF5IDHVXJDKL4421TVPR0C2B1I1BX"
        parameters["v"] = "20200101"
        parameters["limit"] = "5"
        parameters["radius"] = "50000"
        parameters["ll"] = "\(latitude ?? 40.7127),\(longitude ?? -74.0059)"
        let urlComp = NSURLComponents(string: "https://api.foursquare.com/v2/venues/trending")!
        var items = [URLQueryItem]()
        for (key,value) in parameters {
            items.append(URLQueryItem(name: key, value: value))
        }
        items = items.filter{!$0.name.isEmpty}
        if !items.isEmpty {
            urlComp.queryItems = items
        }
        var urlRequest = URLRequest(url: urlComp.url!)
        urlRequest.httpMethod = "GET"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                return
            }
            if let error = error {
                print("Error retrieving data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            } else if let data = data {
                do {
                    let jsonArray = try JSONSerialization.jsonObject(with: data , options:[])
                    if let dictionary = jsonArray as? [String: Any] {
                        DispatchQueue.main.async {
                            completion(true, dictionary)
                        }
                    }
                }
                catch {
                    print("Error: \(error)")
                }
            }
        })
        task.resume()
    }
}
