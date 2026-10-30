import Foundation
import DesignFoundationPro

/// Pure mapping from our SwiftData model to DesignFoundationPro's `Documents` vertical value
/// types (`DFNoteModel`/`DFFolderModel`/`DFTagModel`) — kept free of SwiftData/SwiftUI so it's
/// directly unit testable.
enum DocumentsMapper {
    static func note(for document: ScannedDocument) -> DFNoteModel {
        let category = document.category
        let body = document.summary.isEmpty
            ? document.extractedText
            : "\(document.summary)\n\n\(document.extractedText)"
        return DFNoteModel(
            id: document.id,
            title: document.title,
            body: body,
            tags: [tag(for: category)],
            folderID: category.folderID,
            isPinned: document.isPinned,
            isTrashed: document.isTrashed,
            createdAt: document.createdAt,
            modifiedAt: document.modifiedAt
        )
    }

    static func tag(for category: DocumentCategory) -> DFTagModel {
        DFTagModel(id: category.folderID, name: category.rawValue, colorHex: category.colorHex)
    }

    static func folders(for documents: [ScannedDocument]) -> [DFFolderModel] {
        DocumentCategory.allCases.map { category in
            let count = documents.filter { !$0.isTrashed && $0.category == category }.count
            return DFFolderModel(
                id: category.folderID,
                name: category.folderName,
                iconSystemName: category.iconSystemName,
                noteCount: count
            )
        }
    }

    static var allTags: [DFTagModel] {
        DocumentCategory.allCases.map(tag(for:))
    }
}
