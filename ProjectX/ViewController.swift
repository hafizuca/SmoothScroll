//
//  ViewController.swift
//  ProjectX
//
//  Created by Usama, Hafiz on 5/23/19.
//  Copyright © 2019 HU. All rights reserved.
//

import UIKit
let kCellIdentifier = "ImageViewCell"
class ViewController: UIViewController, ImageTaskDownloadedDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var imageDownloader: ImageDownloader?
    var imagesId: [Int] = []
    var imageTasks: [ImageTask] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageDownloader = ImageDownloader()
        self.imageDownloader?.getImagesList(listCallback: { (list) in
            if let list = list {
                self.processImagesList(list)
            }
        })
    }
    
    func processImagesList(_ list: [[String: Any]]) {
        for i in 0..<list.count {
            if let id = list[i]["id"] as? Int {
                self.imagesId.append(id)
            }
        }
        
        let session = URLSession(configuration: .default)
        for i in 0..<imagesId.count {
            let url = URL(string: "https://picsum.photos/500/500/?image=\(imagesId[i])")!
            let imageTask = ImageTask(position: i, url: url, session: session, delegate: self)
            self.imageTasks.append(imageTask)
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func imageDownloaded(position: Int) {
        
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageTasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier, for: indexPath) as! ImageViewCell
        cell.backgroundColor = UIColor.lightGray
        let image = self.imageTasks[indexPath.row].image
        cell.imageView.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.imageTasks[indexPath.row].resume { (image) in
            if let cell = cell as? ImageViewCell {
                cell.imageView.image = image
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.imageTasks[indexPath.row].pause()
    }
}
