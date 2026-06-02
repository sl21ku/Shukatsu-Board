import XCTest
@testable import ShukatsuBoard

final class ImportParserServiceTests: XCTestCase {
    func testParseCompanyUrlAndQuestion() {
        let text = """
        サンプル株式会社
        https://example.com/jobs
        勤務地：東京
        給与：月給250000円
        設問1：学生時代に力を入れたことを400字以内で教えてください。
        """

        let candidate = ImportParserService.shared.parse(text)

        XCTAssertEqual(candidate.companyName, "サンプル株式会社")
        XCTAssertEqual(candidate.url?.absoluteString, "https://example.com/jobs")
        XCTAssertEqual(candidate.location, "東京")
        XCTAssertEqual(candidate.salary, "月給250000円")
        XCTAssertEqual(candidate.entrySheetQuestions.count, 1)
    }
}
