//
//  ImageTask.swift
//  ProjectX
//
//  Created by Usama, Hafiz on 5/27/19.
//  Copyright © 2019 HU. All rights reserved.
//

import UIKit

class ImageTask: NSObject {
    let position: Int
    let url: URL
    let session: URLSession
    let delegate: ImageTaskDownloadedDelegate
    var image: UIImage?
    var callback: ((UIImage?) -> Void)?
    private var task: URLSessionDownloadTask?
    private var resumeData: Data?
    private var isDownloading = false
    private var isFinishedDownloading = false
    
    init(position: Int, url: URL, session: URLSession, delegate: ImageTaskDownloadedDelegate) {
        self.position = position
        self.url = url
        self.session = session
        self.delegate = delegate
    }
    
    func resume(callback: @escaping (UIImage?) -> Void) {
        if !self.isDownloading && !self.isFinishedDownloading {
            self.callback = callback
            self.isDownloading = true
            if let resumeData = self.resumeData {
                self.task = self.session.downloadTask(withResumeData: resumeData, completionHandler: downloadTaskCompletionHandler)
            }
            else {
                self.task = self.session.downloadTask(with: self.url, completionHandler: downloadTaskCompletionHandler)
            }
            
            self.task?.resume()
        }
    }
    
    func pause() {
        if self.isDownloading && !self.isFinishedDownloading {
            self.callback = nil
            self.task?.cancel(byProducingResumeData: { (data) in
                self.resumeData = data
            })
            
            self.isDownloading = false
        }
    }
    
    private func downloadTaskCompletionHandler(url: URL?, response: URLResponse?, error: Error?) {
        if let error = error {
            print("Error downloading: ", error)
            return
        }
        
        guard let url = url else { return }
        guard let data = FileManager.default.contents(atPath: url.path) else { return }
        guard let image = UIImage(data: data) else { return }
        self.image = image
        DispatchQueue.main.async {
            self.delegate.imageDownloaded(position: self.position)
            self.callback?(image)
        }
        
        self.isFinishedDownloading = true
    }
}

protocol ImageTaskDownloadedDelegate {
    func imageDownloaded(position: Int)
}
