//
//  GalleryTests.swift
//  PixelRoomTests
//
//  Created by Jean-Baptiste Castro on 28/04/2021.
//

import XCTest
@testable import PixelRoom


class GalleryTests: XCTestCase {
    

    func testLoadingGalleryComplete() throws {
        let dataSource = GalleryDataSource()
        let expectation = self.expectation(description: "Loading gallery should complete")
        
        dataSource.reloadPhotos {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
