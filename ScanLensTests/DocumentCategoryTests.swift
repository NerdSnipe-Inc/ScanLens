import Testing
import Foundation
@testable import ScanLens

@Suite("DocumentCategory")
struct DocumentCategoryTests {
    @Test("maps exact model output to the matching category")
    func mapsExactMatch() {
        #expect(DocumentCategory.from(modelOutput: "Receipt") == .receipt)
        #expect(DocumentCategory.from(modelOutput: "ID") == .id)
        #expect(DocumentCategory.from(modelOutput: "Note") == .note)
    }

    @Test("is case-insensitive and trims whitespace")
    func isCaseInsensitiveAndTrims() {
        #expect(DocumentCategory.from(modelOutput: "  receipt  ") == .receipt)
        #expect(DocumentCategory.from(modelOutput: "NOTE") == .note)
    }

    @Test("falls back to .other for unrecognized model output")
    func fallsBackToOther() {
        #expect(DocumentCategory.from(modelOutput: "Invoice") == .other)
        #expect(DocumentCategory.from(modelOutput: "") == .other)
    }

    @Test("every category has a stable, distinct folder id")
    func folderIDsAreStableAndDistinct() {
        let ids = Set(DocumentCategory.allCases.map(\.folderID))
        #expect(ids.count == DocumentCategory.allCases.count)
        #expect(DocumentCategory.receipt.folderID == DocumentCategory.receipt.folderID)
    }
}
