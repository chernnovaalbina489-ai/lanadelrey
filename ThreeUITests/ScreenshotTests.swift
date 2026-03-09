import XCTest

final class ScreenshotTests: XCTestCase {

    let app = XCUIApplication()
    var screenshotDir: String {
        let subdir: String
        if let content = try? String(contentsOfFile: "/tmp/screenshot_subdir.txt", encoding: .utf8),
           !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            subdir = content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            subdir = "Screenshots"
        }
        return "/Users/sadygsadygov/Desktop/new_dom/Three/\(subdir)"
    }

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func saveScreenshot(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let data = screenshot.pngRepresentation
        let url = URL(fileURLWithPath: "\(screenshotDir)/\(name).png")
        try? data.write(to: url)
    }

    @MainActor
    func testCaptureAllScreenshots() throws {
        try? FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true)

        app.launchArguments = ["-hasCompletedOnboarding", "NO"]
        app.launch()
        sleep(3)
        saveScreenshot("01-onboarding-seed")

        app.terminate()
        app.launchArguments = ["-hasCompletedOnboarding", "YES"]
        app.launch()
        sleep(3)
        saveScreenshot("02-garden-empty")

        let addBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'plus'")).firstMatch
        if addBtn.waitForExistence(timeout: 3) {
            addBtn.tap()
            sleep(2)
            saveScreenshot("03-add-plant-name")

            let nameField = app.textFields["e.g., Monstera Deliciosa"]
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText("Monstera")
            }

            let nextBtn = app.buttons["Next"]
            if nextBtn.waitForExistence(timeout: 2) {
                nextBtn.tap()
                sleep(2)
                saveScreenshot("04-add-plant-details")

                if nextBtn.waitForExistence(timeout: 2) {
                    nextBtn.tap()
                    sleep(2)
                    saveScreenshot("05-add-plant-care")
                }

                let plantItBtn = app.buttons["Plant It!"]
                if plantItBtn.waitForExistence(timeout: 2) {
                    plantItBtn.tap()
                    sleep(3)
                }
            }
        }

        saveScreenshot("06-garden-with-plant")

        let plantCard = app.staticTexts["Monstera"]
        if plantCard.waitForExistence(timeout: 3) {
            plantCard.tap()
            sleep(2)
            saveScreenshot("07-plant-detail")

            let backBtn = app.navigationBars.buttons.firstMatch
            if backBtn.waitForExistence(timeout: 2) {
                backBtn.tap()
                sleep(1)
            }
        }

        let careBtn = app.buttons["Care"]
        if careBtn.waitForExistence(timeout: 3) {
            careBtn.tap()
            sleep(2)
            saveScreenshot("08-care-tasks")
        }

        let journalBtn = app.buttons["Journal"]
        if journalBtn.waitForExistence(timeout: 3) {
            journalBtn.tap()
            sleep(2)
            saveScreenshot("09-journal-feed")
        }

        let chartButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'stats' OR label CONTAINS[c] 'chart' OR label CONTAINS[c] 'Stats'"))
        if chartButtons.firstMatch.waitForExistence(timeout: 3) {
            chartButtons.firstMatch.tap()
            sleep(2)
            saveScreenshot("10-stats")
            let backBtn = app.navigationBars.buttons.firstMatch
            if backBtn.waitForExistence(timeout: 2) {
                backBtn.tap()
                sleep(1)
            }
        }

        let settingsBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'gearshape'")).firstMatch
        if settingsBtn.waitForExistence(timeout: 3) {
            settingsBtn.tap()
            sleep(2)
            saveScreenshot("11-settings")

            let window = app.windows.firstMatch
            window.swipeUp()
            sleep(1)
            saveScreenshot("12-settings-detail")
        }
    }
}
