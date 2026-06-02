import Foundation
import UIKit
import Vision

enum OCRServiceError: LocalizedError {
    case missingImageData
    case recognitionFailed

    var errorDescription: String? {
        switch self {
        case .missingImageData: "画像データを読み込めませんでした。"
        case .recognitionFailed: "文字認識に失敗しました。"
        }
    }
}

struct OCRService {
    static let shared = OCRService()

    func recognizeText(in image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRServiceError.missingImageData
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let recognized = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")

                if recognized.isEmpty {
                    continuation.resume(throwing: OCRServiceError.recognitionFailed)
                } else {
                    continuation.resume(returning: recognized)
                }
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ja-JP", "en-US"]
            request.usesLanguageCorrection = true

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try VNImageRequestHandler(cgImage: cgImage).perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
