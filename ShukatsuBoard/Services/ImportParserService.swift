import Foundation

struct ParsedImportCandidate: Equatable {
    var companyName: String?
    var url: URL?
    var detectedDates: [Date]
    var position: String?
    var location: String?
    var salary: String?
    var entrySheetQuestions: [String]
    var rawText: String

    var suggestedTaskTitle: String? {
        guard let date = detectedDates.first else {
            return nil
        }

        if rawText.contains("面接") {
            return "面接"
        }

        if rawText.contains("Webテスト") || rawText.contains("WEBテスト") {
            return "Webテスト"
        }

        if rawText.contains("締切") || rawText.contains("〆切") || rawText.contains("提出") {
            return "提出締切"
        }

        return DateFormatter.shortDateTime.string(from: date)
    }
}

struct ImportParserService {
    static let shared = ImportParserService()

    func parse(_ text: String) -> ParsedImportCandidate {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue |
                NSTextCheckingResult.CheckingType.date.rawValue
        )
        let range = NSRange(normalized.startIndex..<normalized.endIndex, in: normalized)
        let matches = detector?.matches(in: normalized, options: [], range: range) ?? []

        let firstURL = matches.compactMap(\.url).first
        let dates = matches.compactMap(\.date).sorted()

        return ParsedImportCandidate(
            companyName: detectCompanyName(in: normalized),
            url: firstURL,
            detectedDates: dates,
            position: detectValue(in: normalized, keywords: ["職種", "募集職種", "ポジション"]),
            location: detectValue(in: normalized, keywords: ["勤務地", "勤務場所"]),
            salary: detectValue(in: normalized, keywords: ["給与", "月給", "年収"]),
            entrySheetQuestions: detectEntrySheetQuestions(in: normalized),
            rawText: normalized
        )
    }

    private func detectCompanyName(in text: String) -> String? {
        let lines = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let companyLine = lines.first { line in
            line.contains("株式会社") ||
                line.contains("有限会社") ||
                line.contains("合同会社") ||
                line.localizedCaseInsensitiveContains("Inc.") ||
                line.localizedCaseInsensitiveContains("Corporation")
        }

        if let companyLine {
            return companyLine.removingMailPrefix()
        }

        return lines.first?.removingMailPrefix()
    }

    private func detectValue(in text: String, keywords: [String]) -> String? {
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            for keyword in keywords where line.contains(keyword) {
                return line
                    .replacingOccurrences(of: keyword, with: "")
                    .replacingOccurrences(of: "：", with: "")
                    .replacingOccurrences(of: ":", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }

    private func detectEntrySheetQuestions(in text: String) -> [String] {
        text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { line in
                line.contains("設問") ||
                    line.contains("質問") ||
                    line.contains("字以内") ||
                    line.hasSuffix("ください。") ||
                    line.hasSuffix("ください")
            }
    }
}

private extension String {
    func removingMailPrefix() -> String {
        replacingOccurrences(of: "件名:", with: "")
            .replacingOccurrences(of: "件名：", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
