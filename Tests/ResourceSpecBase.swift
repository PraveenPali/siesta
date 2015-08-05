//
//  ResourceTests.swift
//  Siesta
//
//  Created by Paul on 2015/6/20.
//  Copyright © 2015 Bust Out Solutions. All rights reserved.
//

@testable import Siesta
import Quick
import Nimble
import Nocilla
import Alamofire

class ResourceSpecBase: QuickSpec
    {
    func resourceSpec(service: () -> Service, _ resource: () -> Resource)
        { }
    
    override final func spec()
        {
        beforeSuite { Siesta.enabledLogCategories = LogCategory.all }
        
        beforeSuite { LSNocilla.sharedInstance().start() }
        afterSuite  { LSNocilla.sharedInstance().stop() }
        afterEach   { LSNocilla.sharedInstance().clearStubs() }
        
        afterEach  { fakeNow = nil }
        
        let service  = specVar { Service(base: "https://zingle.frotz/v1") },
            resource = specVar { service().resource("/a/b") }
        
        resourceSpec(service, resource)
        }
    }


// MARK: - Request stubbing

func stubReqest(resource: () -> Resource, _ method: String) -> LSStubRequestDSL
    {
    return stubRequest(method, resource().url!.absoluteString)
    }

func awaitNewData(req: Siesta.Request)
    {
    let responseExpectation = QuickSpec.current().expectationWithDescription("awaiting response callback: \(req)")
    let successExpectation = QuickSpec.current().expectationWithDescription("awaiting success callback: \(req)")
    let newDataExpectation = QuickSpec.current().expectationWithDescription("awaiting newData callback: \(req)")
    req.completion  { _ in responseExpectation.fulfill() }
       .success     { _ in successExpectation.fulfill() }
       .failure     { _ in fail("error callback should not be called") }
       .newData     { _ in newDataExpectation.fulfill() }
       .notModified { _ in fail("notModified callback should not be called") }
    QuickSpec.current().waitForExpectationsWithTimeout(1, handler: nil)
    }

func awaitNotModified(req: Siesta.Request)
    {
    let responseExpectation = QuickSpec.current().expectationWithDescription("awaiting response callback: \(req)")
    let successExpectation = QuickSpec.current().expectationWithDescription("awaiting success callback: \(req)")
    let notModifiedExpectation = QuickSpec.current().expectationWithDescription("awaiting notModified callback: \(req)")
    req.completion  { _ in responseExpectation.fulfill() }
       .success     { _ in successExpectation.fulfill() }
       .failure     { _ in fail("error callback should not be called") }
       .newData     { _ in fail("newData callback should not be called") }
       .notModified { _ in notModifiedExpectation.fulfill() }
    QuickSpec.current().waitForExpectationsWithTimeout(1, handler: nil)
    }

func awaitFailure(req: Siesta.Request)
    {
    let responseExpectation = QuickSpec.current().expectationWithDescription("awaiting response callback: \(req)")
    let errorExpectation = QuickSpec.current().expectationWithDescription("awaiting failure callback: \(req)")
    req.completion  { _ in responseExpectation.fulfill() }
       .failure     { _ in errorExpectation.fulfill() }
       .success     { _ in fail("success callback should not be called") }
       .newData     { _ in fail("newData callback should not be called") }
       .notModified { _ in fail("notModified callback should not be called") }
    QuickSpec.current().waitForExpectationsWithTimeout(1, handler: nil)
    }

// MARK: - Clock stubbing

func setResourceTime(time: NSTimeInterval)
    {
    fakeNow = time
    }