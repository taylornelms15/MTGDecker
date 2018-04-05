//
//  MTGDeckerTests.swift
//  MTGDeckerTests
//
//  Created by Taylor Nelms on 3/23/18.
//  Copyright © 2018 Taylor. All rights reserved.
//

import XCTest
import MTGSDKSwift
@testable import MTGDecker

class MTGDeckerTests: XCTestCase {
    
    let magic: Magic = Magic();
    
    override func setUp() {
        super.setUp()

        magic.fetchPageSize="100";
        magic.fetchPageTotal = "1";
        Magic.enableLogging = true;
       // let color = CardSearchParameter(parameterType: .colors, value: "black")
        // let cmc = CardSearchParameter(parameterType: .cmc, value: "2")
        let setCode = CardSearchParameter(parameterType: .set, value: "XLN")
        
        magic.fetchCards([setCode]) {
            cards, error in
            
            if let error = error {
                NSLog("\(error)");
            }
            
            for c in cards! {
                NSLog(c.name!);
            }
            
        }
        
        sleep(3)
        
    }//setUp
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        //self.measure{
            // Put the code you want to measure the time of here.
        //}
    }
    
}
