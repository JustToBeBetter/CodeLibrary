//
//  CodeLibraryUITests.m
//  CodeLibraryUITests
//
//  Created by 李金柱 on 2017/4/12.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface CodeLibraryUITests : XCTestCase

@end

@implementation CodeLibraryUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void)testBarrage{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tables/*@START_MENU_TOKEN@*/.staticTexts[@"Barrage"]/*[[".cells.staticTexts[@\"Barrage\"]",".staticTexts[@\"Barrage\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
    XCUIElement *startButton = app.buttons[@"start"];
    [startButton tap];
    XCTAssertTrue(startButton.exists, @"'start'按钮存在");
    XCUIElement *stopButton = app.buttons[@"stop"];
    [stopButton tap];
    XCTAssertTrue(stopButton.exists, @"'stop'按钮存在");
    [app.navigationBars[@"Barrage"].buttons[@"Code"] tap];
    
}
- (void)testFireLike{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tables/*@START_MENU_TOKEN@*/.cells.staticTexts[@"FireLike"]/*[[".cells.staticTexts[@\"FireLike\"]",".staticTexts[@\"FireLike\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/ tap];
    XCUIElement *button = app.buttons[@"\u70b9\u8d5e"];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [button tap];
    [app.navigationBars[@"FireLike"].buttons[@"Code"] tap];
   
}
- (void)testCountDown{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tables/*@START_MENU_TOKEN@*/.staticTexts[@"CountDown"]/*[[".cells.staticTexts[@\"CountDown\"]",".staticTexts[@\"CountDown\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    [app.navigationBars[@"CountDown"].buttons[@"Code"] tap];
    
}
- (void)testPages{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tables/*@START_MENU_TOKEN@*/.staticTexts[@"Pages"]/*[[".cells.staticTexts[@\"Pages\"]",".staticTexts[@\"Pages\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
    XCUIElement *element = [[[[[[[app.otherElements containingType:XCUIElementTypeNavigationBar identifier:@"Pages"] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeScrollView] elementBoundByIndex:1] childrenMatchingType:XCUIElementTypeOther].element;
    [element swipeLeft];
    [element swipeLeft];
    [element swipeLeft];
    [element swipeLeft];
    [element swipeLeft];
    [element swipeLeft];
    [element swipeRight];
    [element swipeLeft];
    [element swipeLeft];
    [element swipeLeft];
    [element swipeRight];
    [element swipeRight];
    [element swipeRight];
    [element swipeRight];
    [element swipeRight];
    [app.navigationBars[@"Pages"].buttons[@"Code"] tap];
 
    
}
- (void)testGifMaker{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElementQuery *tablesQuery = app.tables;
    [tablesQuery/*@START_MENU_TOKEN@*/.staticTexts[@"GifMaker"]/*[[".cells.staticTexts[@\"GifMaker\"]",".staticTexts[@\"GifMaker\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    [app.navigationBars[@"GifMaker"].buttons[@"Code"] tap];
    [tablesQuery/*@START_MENU_TOKEN@*/.staticTexts[@"FloatingView"]/*[[".cells.staticTexts[@\"FloatingView\"]",".staticTexts[@\"FloatingView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    

    
}
- (void)testFloatingView{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tables/*@START_MENU_TOKEN@*/.staticTexts[@"FloatingView"]/*[[".cells.staticTexts[@\"FloatingView\"]",".staticTexts[@\"FloatingView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
    XCUIElement *element = [[[[[app.otherElements containingType:XCUIElementTypeNavigationBar identifier:@"FloatingView"] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element;
    [element swipeDown];
    [element swipeUp];
    /*@START_MENU_TOKEN@*/[element swipeLeft];/*[["element","["," swipeUp];"," swipeLeft];"],[[[-1,0,1]],[[1,3],[1,2]]],[0,0]]@END_MENU_TOKEN@*/
    [element tap];
    [element tap];
    [element swipeDown];
    [element swipeDown];
    [element swipeRight];
    [element swipeRight];
    /*@START_MENU_TOKEN@*/[element swipeRight];/*[["element","["," swipeUp];"," swipeRight];"],[[[-1,0,1]],[[1,3],[1,2]]],[0,0]]@END_MENU_TOKEN@*/
    [element swipeUp];
    [element swipeRight];
    [element swipeDown];
    [element swipeUp];
    [element swipeDown];
    [element swipeUp];
    /*@START_MENU_TOKEN@*/[element swipeLeft];/*[["element","["," swipeUp];"," swipeLeft];"],[[[-1,0,1]],[[1,3],[1,2]]],[0,0]]@END_MENU_TOKEN@*/
    [element tap];
    /*@START_MENU_TOKEN@*/[element swipeLeft];/*[["element","["," swipeUp];"," swipeLeft];"],[[[-1,0,1]],[[1,3],[1,2]]],[0,0]]@END_MENU_TOKEN@*/
    [element tap];
    [element tap];
    [app.navigationBars[@"FloatingView"].buttons[@"Code"] tap];
    
}
- (void)testPaoma{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tables/*@START_MENU_TOKEN@*/.staticTexts[@"Paoma"]/*[[".cells.staticTexts[@\"Paoma\"]",".staticTexts[@\"Paoma\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    /*@START_MENU_TOKEN@*/[app.navigationBars[@"Paoma"].buttons[@"Code"] pressForDuration:0.7];/*[["app.navigationBars[@\"Paoma\"].buttons[@\"Code\"]","["," tap];"," pressForDuration:0.7];"],[[[-1,0,1]],[[1,3],[1,2]]],[0,0]]@END_MENU_TOKEN@*/
    
}
- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

}

@end
