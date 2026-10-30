import Foundation
import SwiftData

@MainActor
enum SampleData {
    /// Seeds a couple of already-scanned documents on first launch so Documents isn't empty
    /// before anyone has run the Import flow themselves.
    static func seedIfNeeded(context: ModelContext) {
        let existing = try? context.fetch(FetchDescriptor<ScannedDocument>())
        guard (existing ?? []).isEmpty else { return }

        context.insert(ScannedDocument(
            title: "Trader Joe's",
            extractedText: "TRADER JOE'S\n\nBananas   $1.99\nOat Milk   $3.49\nHummus     $2.99\n\nTOTAL      $8.47",
            summary: "Grocery receipt from Trader Joe's totaling $8.47.",
            category: .receipt,
            createdAt: Date().addingTimeInterval(-86_400),
            modifiedAt: Date().addingTimeInterval(-86_400)
        ))

        context.insert(ScannedDocument(
            title: "Standup Notes",
            extractedText: "Standup — Sept 7\n\n- Finished folder sidebar\n- OCR accuracy looks good on printed receipts\n- Next: handwriting support",
            summary: "Engineering standup notes covering folder sidebar work and OCR accuracy.",
            category: .note,
            isPinned: true,
            createdAt: Date().addingTimeInterval(-3 * 86_400),
            modifiedAt: Date().addingTimeInterval(-3 * 86_400)
        ))

        try? context.save()
    }
}
