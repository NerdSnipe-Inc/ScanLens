import Foundation

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct DocumentExtraction: Sendable {
    @Guide(description: "A short descriptive title, e.g. the vendor name for a receipt or the document type")
    var title: String

    @Guide(description: "Exactly one of: Receipt, ID, Note, Other — whichever best fits the content")
    var category: String

    @Guide(description: "A one or two sentence summary of what this document contains")
    var summary: String
}

/// Turns raw OCR text into structured fields entirely on-device via Apple's Foundation Models
/// framework — no network round trip, no API key. Same on-device pattern as AICompleteChat and
/// BudgetLens's Insights tab, applied here to document classification instead of chat or
/// financial summaries.
@available(iOS 26.0, macOS 26.0, *)
@MainActor
final class DocumentExtractionEngine {
    private var session: LanguageModelSession?

    var isAvailable: Bool {
        switch SystemLanguageModel.default.availability {
        case .available: return true
        case .unavailable: return false
        }
    }

    func prewarm() {
        guard isAvailable else { return }
        let session = session ?? makeSession()
        self.session = session
        session.prewarm()
    }

    func extract(from ocrText: String) async throws -> DocumentExtraction {
        let session = session ?? makeSession()
        self.session = session

        let prompt = """
        Here is text extracted via OCR from a scanned document or receipt:

        \(ocrText)

        Give it a short title, classify it, and summarize what it contains.
        """

        let response = try await session.respond(to: prompt, generating: DocumentExtraction.self)
        return response.content
    }

    private func makeSession() -> LanguageModelSession {
        LanguageModelSession {
            "You classify and summarize scanned documents from raw OCR text. Be concise. Never invent details that aren't present in the text."
        }
    }
}
#endif
