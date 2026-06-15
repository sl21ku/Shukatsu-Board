import XCTest

final class ShukatsuBoardUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testMainTabsLaunchAndNavigate() throws {
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launch()

        XCTAssertTrue(app.navigationBars["就活マイページ登録アプリ"].waitForExistence(timeout: 10))

        app.tabBars.buttons["企業"].tap()
        app.tabBars.buttons["比較"].tap()
        app.tabBars.buttons["タスク"].tap()

        app.tabBars.buttons["ホーム"].tap()
        XCTAssertTrue(app.navigationBars["就活マイページ登録アプリ"].waitForExistence(timeout: 5))
        app.buttons["設定"].tap()
        XCTAssertTrue(app.navigationBars["設定"].waitForExistence(timeout: 5))
    }

    func disabled_testQuickAddShowsImportControls() throws {
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launch()

        app.tabBars.buttons["追加"].tap()
        XCTAssertTrue(app.navigationBars["クイック追加"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["解析する"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["画像から文字を読み取る"].waitForExistence(timeout: 5))
    }
}
