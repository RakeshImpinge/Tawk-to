//
//  ImageCatching.swift
//  Tawk.To App
//
//  Created by Raghav Kakria on 16/02/22.
//

import Foundation

struct ImageCaching {
    static let shared = ImageCaching()
    
    func loadData(url: URL, id: Int, completion: @escaping (Data?, Error?) -> Void) {
        let fileCachePath = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent + "\(id)", isDirectory: false)
        
        if let data = NSData.init(contentsOfFile: fileCachePath.path) {
            completion(data as Data, nil)
            return
        }
        
        self.download(url: url, toFile: fileCachePath) { error in
            if let data = NSData(contentsOfFile: fileCachePath.path) {
                completion(data as Data, error)
            }
            completion(nil,error)
        }
    }
    
    func download(url: URL, toFile file: URL, completion: @escaping (Error?) -> Void) {
        // Download the remote URL to a file
        let task = URLSession.shared.downloadTask(with: url) {
            (tempURL, response, error) in
            // Early exit on error
            guard let tempURL = tempURL else {
                completion(error)
                return
            }

            do {
                // Remove any existing document at file
                if FileManager.default.fileExists(atPath: file.path) {
                    try FileManager.default.removeItem(at: file)
                }

                // Copy the tempURL to file
                try FileManager.default.copyItem(
                    at: tempURL,
                    to: file
                )

                completion(nil)
            }

            // Handle potential file system errors
            catch let fileError {
                completion(fileError)
            }
        }

        // Start the download
        task.resume()
    }
}
