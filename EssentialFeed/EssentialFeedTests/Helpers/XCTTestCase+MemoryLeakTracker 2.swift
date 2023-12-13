//
//  XCTTestCase+MemoryLeakTracker.swift
//  EssentialFeedTests
//
//  Created by Yauheni Ivaniuk on 7/31/23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance,
                "Instant should have been deallocated. Potential memory leak.",
                file: file,
                line: line
            )
        }
    }
}
