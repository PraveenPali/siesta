//
//  RequestCallbacks.swift
//  Siesta
//
//  Created by Paul on 2015/12/15.
//  Copyright © 2015 Bust Out Solutions. All rights reserved.
//

internal typealias ResponseInfo = (response: Response, isNew: Bool)
internal typealias ResponseCallback = ResponseInfo -> Void

internal protocol RequestWithDefaultCallbacks: Request
    {
    func addResponseCallback(callback: ResponseCallback)
    }

extension RequestWithDefaultCallbacks
    {
    func completion(callback: Response -> Void) -> Self
        {
        addResponseCallback
            {
            response, _ in
            callback(response)
            }
        return self
        }

    func success(callback: Entity -> Void) -> Self
        {
        addResponseCallback
            {
            response, _ in
            if case .Success(let entity) = response
                { callback(entity) }
            }
        return self
        }

    func newData(callback: Entity -> Void) -> Self
        {
        addResponseCallback
            {
            response, isNew in
            if case .Success(let entity) = response where isNew
                { callback(entity) }
            }
        return self
        }

    func notModified(callback: Void -> Void) -> Self
        {
        addResponseCallback
            {
            response, isNew in
            if case .Success = response where !isNew
                { callback() }
            }
        return self
        }

    func failure(callback: Error -> Void) -> Self
        {
        addResponseCallback
            {
            response, _ in
            if case .Failure(let error) = response
                { callback(error) }
            }
        return self
        }
    }

internal struct CallbackGroup<CallbackArguments>
    {
    private(set) var completedValue: CallbackArguments?
    private var callbacks: [CallbackArguments -> Void] = []

    mutating func addCallback(callback: CallbackArguments -> Void)
        {
        dispatch_assert_main_queue()

        if let completedValue = completedValue
            {
            // Request already completed. Callback can run immediately, but queue it on the main thread so that the
            // caller can finish their business first.

            dispatch_async(dispatch_get_main_queue())
                { callback(completedValue) }
            }
        else
            {
            callbacks.append(callback)
            }
        }

    func notify(arguments: CallbackArguments)
        {
        dispatch_assert_main_queue()

        for callback in callbacks
            { callback(arguments) }
        }

    mutating func notifyOfCompletion(arguments: CallbackArguments)
        {
        precondition(completedValue == nil, "notifyOfCompletion() already called")

        // Remember outcome in case more handlers are added after request is already completed
        completedValue = arguments

        notify(arguments)
        callbacks = []  // Fly, little handlers, be free!
        }
    }
