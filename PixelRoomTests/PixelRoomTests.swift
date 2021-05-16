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
    
    func testGalleryDataSourceCount() throws {
        let expectation = expectation(description: "GalleryDataSource reloadPhotos")
        let dataSource = GalleryDataSource()
        dataSource.reloadPhotos {
            XCTAssertEqual(dataSource.numberOfItemsInSection(0), 5)
            XCTAssertEqual(dataSource.numberOfItemsInSection(1), 6)
            XCTAssertEqual(dataSource.numberOfItemsInSection(2), 26)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
    
    func testPhotoModelStoreAndLoad() throws {
        guard let photoPath = Bundle.main.paths(forResourcesOfType: "jpg", inDirectory: nil).first else {
            return XCTFail()
        }
        let photoURL = URL(fileURLWithPath: photoPath)
        guard let dummyPhoto = UIImage(contentsOfFile: photoPath) else { return XCTFail() }
        let dummyVC = PhotoEditorViewController()
        
        let model = PhotoEditorModel(
            with: PhotoItem(
                name: photoURL.deletingPathExtension().lastPathComponent,
                thumbnail: dummyPhoto,
                thumbnailScale: 1.0,
                url: photoURL
            ),
            photoEditorView: dummyVC
        )
        
        model.editorDidChangeFilter(to: .pixellate, scaleValue: 35.5)
        guard let edits = UserDefaults.standard.photoEdits() else { return XCTFail() }
        model.editorDidChangeFilter(to: .pointillize, scaleValue: 28.4)
        UserDefaults.standard.setPhotoEdits(edits)
        model.loadFilterEdits()
        XCTAssertEqual(model.currentFilterType, .pixellate)
        XCTAssertEqual(model.currentInputScaleValue, 35.5)
        
        model.editorDidChangeFilter(to: .hexagonalPixellate, scaleValue: 19.5)
        guard let edits = UserDefaults.standard.photoEdits() else { return XCTFail() }
        model.editorDidChangeFilter(to: .pixellate, scaleValue: 45.2)
        UserDefaults.standard.setPhotoEdits(edits)
        model.loadFilterEdits()
        XCTAssertEqual(model.currentFilterType, .hexagonalPixellate)
        XCTAssertEqual(model.currentInputScaleValue, 19.5)
        
        model.editorDidChangeFilter(to: .pointillize, scaleValue: 18.5)
        guard let edits = UserDefaults.standard.photoEdits() else { return XCTFail() }
        model.editorDidChangeFilter(to: .hexagonalPixellate, scaleValue: 37.3)
        UserDefaults.standard.setPhotoEdits(edits)
        model.loadFilterEdits()
        XCTAssertEqual(model.currentFilterType, .pointillize)
        XCTAssertEqual(model.currentInputScaleValue, 18.5)
    }
}
