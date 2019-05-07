//
//  ImageLibraryTests.swift
//  ImageLibraryTests
//
//  Created by Steve JobsOne on 4/25/19.
//  Copyright © 2019 MobioApp Limited. All rights reserved.
//

import XCTest
@testable import ImageLibrary

class ImageLibraryTests: XCTestCase {

    var systemUnderTest: ImageListViewController!
    var systemUnderTest1: ImageDetailsViewController!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        
        //Get the storyboard the ViewController under test is inside
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        //Get the ViewController we want to test from the storyboard (note the identifier is the id explicitly set in the identity inspector)
        systemUnderTest = storyboard.instantiateViewController(withIdentifier: "ImageListViewController") as? ImageListViewController
        systemUnderTest1 = storyboard.instantiateViewController(withIdentifier: "ImageDetailsViewController") as? ImageDetailsViewController
        
        //load view hierarchy
        _ = systemUnderTest.view
        _ = systemUnderTest1.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        systemUnderTest = nil
        systemUnderTest1 = nil
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //Test case to allow, if view controller name is only "Image Library"
    func test_title_is_Image_Library() {
        let navigationController = UIApplication.shared.keyWindow!.rootViewController as! UINavigationController
        let rootViewController = navigationController.viewControllers.first as! ImageListViewController
        XCTAssertEqual("Image Library", rootViewController.title)
    }
    
    func testSUT_PassesDataToDetailsViewController() {
        // fetch the segue from story board
        let targetSegue: UIStoryboardSegue = UIStoryboardSegue(identifier: "showDetailsView", source: systemUnderTest, destination: systemUnderTest1)
        systemUnderTest1.imageId = "image_id_001"
        
        // simulate when user taps a cell - we get the associated model object and send its id (of type String) as the sender parameter of prepareForSegue()
        let tappedModelId = "image_id_001"
        systemUnderTest.prepare(for: targetSegue, sender: tappedModelId)
        
        // confirm that prepareForSegue() properly sets the 'imageId' property of the destination view controller
        XCTAssertEqual(tappedModelId, systemUnderTest1.imageId)
    }

}
