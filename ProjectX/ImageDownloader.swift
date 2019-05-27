//
//  ImageDownloader.swift
//  ProjectX
//
//  Created by Usama, Hafiz on 5/27/19.
//  Copyright © 2019 HU. All rights reserved.
//

import UIKit

class ImageDownloader: NSObject {
    override init() {
        super.init()
    }
    
    func getImagesList(listCallback: @escaping ([[String: Any]]?) -> Void) {
        guard let url = URL(string: "https://picsum.photos/list") else {
            listCallback(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                listCallback(nil)
                return
            }
            
            guard let data = data else {
                listCallback(nil)
                return
            }
            
            do {
                let objects = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]]
                listCallback(objects)
            }
            catch {
                listCallback(nil)
            }
        }
        
        task.resume()
    }
}
