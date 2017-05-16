//
//  Network.swift
//  TheApiAwakens
//
//  Created by Tassia Serrao on 13/03/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import Foundation

import Foundation

//MARK: error handling - The device being offline when an API call is made
public class Network {
    
    class func isConnectedToNetwork()-> Bool{
        
        var Status:Bool = false
        let url = NSURL(string: "http://google.com/")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "HEAD"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        var response: URLResponse?
        
        do {
            _ = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response) as NSData?
        } catch (let error) {
            print(error)
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
        return Status
    }
}
