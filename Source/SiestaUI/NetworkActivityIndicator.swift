//
//  NetworkActivityIndicator.swift
//  Siesta
//
//  Created by Andrew Reed on 30/10/2016.
//  Copyright © 2016 Bust Out Solutions. All rights reserved.
//

import Siesta
import UIKit

// Tracks the number of requests in progress across all Siesta services
private var requestsInProgress = 0
    {
    didSet
        {
        UIApplication.shared.isNetworkActivityIndicatorVisible =
            requestsInProgress > 0
        }
    }

private func requestStarted()
    { requestsInProgress += 1 }

private func requestCompleted()
    { requestsInProgress -= 1 }

extension Configuration
    {
    /**
      Causes requests to automatically show and hide the iOS network activity indicator. You can attach this to an
      entire service:
      
          service.configure {
            $0.showRequestsWithNetworkActivityIndicator()
          }

      …or only to carefully selected large resources, if you are looking to follow [Apple’s Human Interface guidelines
      for the indicator](https://developer.apple.com/ios/human-interface-guidelines/ui-controls/progress-indicators/#network-activity-indicators):

          service.configure("/downloads/​**") {
            $0.showRequestsWithNetworkActivityIndicator()
          }
          service.configure("/profile/avatar", requestMethods: [.post, .put]) {
            $0.showRequestsWithNetworkActivityIndicator()
          }
    */
    public mutating func showRequestsWithNetworkActivityIndicator()
        {
        decorateRequests
            {
            resource, request in
            
            requestStarted()
            request.onCompletion
                { _ in requestCompleted() }
            
            return request
            }
        }
    }
