import Foundation
import SwiftData

@Model
final class ScannedDocument {
    // DFNoteModel keys everything (selection, navigation, search results) off a plain UUID —
    // SwiftData's own `persistentModelID` isn't a UUID, so we need our own stable one to bridge.
    @Attribute(.unique) var id: UUID
    var title: String
    var extractedText: String
    var summary: String
    var categoryRaw: String
    var isPinned: Bool
    var isTrashed: Bool
    var createdAt: Date
    var modifiedAt: Date

    var category: DocumentCategory {
        get { DocumentCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        title: String,
        extractedText: String,
        summary: String,
        category: DocumentCategory,
        isPinned: Bool = false,
        isTrashed: Bool = false,
        createdAt: Date = .now,
        modifiedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.extractedText = extractedText
        self.summary = summary
        self.categoryRaw = category.rawValue
        self.isPinned = isPinned
        self.isTrashed = isTrashed
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}
