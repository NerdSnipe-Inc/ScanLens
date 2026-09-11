import Testing
import Foundation
@testable import ScanLens

@Suite("DocumentsMapper")
struct DocumentsMapperTests {
    @Test("maps a scanned document into a DFNoteModel with matching identity and folder")
    func mapsBasicFields() {
        let document = ScannedDocument(
            title: "Whole Foods",
            extractedText: "Bananas $3.49",
            summary: "Grocery receipt.",
            category: .receipt
        )

        let note = DocumentsMapper.note(for: document)

        #expect(note.id == document.id)
        #expect(note.title == "Whole Foods")
        #expect(note.folderID == DocumentCategory.receipt.folderID)
        #expect(note.body.contains("Grocery receipt."))
        #expect(note.body.contains("Bananas $3.49"))
        #expect(note.tags.first?.name == "Receipt")
    }

    @Test("folder counts reflect only active, non-trashed documents in that category")
    func folderCountsExcludeTrashed() {
        let active = ScannedDocument(title: "A", extractedText: "", summary: "", category: .note)
        let trashed = ScannedDocument(title: "B", extractedText: "", summary: "", category: .note, isTrashed: true)

        let folders = DocumentsMapper.folders(for: [active, trashed])
        let noteFolder = folders.first { $0.id == DocumentCategory.note.folderID }

        #expect(noteFolder?.noteCount == 1)
    }
}
