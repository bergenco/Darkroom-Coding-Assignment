//
//  PixelRoomTests.swift
//  PixelRoomTests
//
//  Created by Igor Lipovac on 01/03/2021.
//

import XCTest
@testable import PixelRoom

class PixelRoomTests: XCTestCase {
    func testGalleryDataSourcePhotoLoading() throws {
        let expectation = expectation(description: "GalleryDataSource reloadPhotos")
        GalleryDataSource().reloadPhotos {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
}
