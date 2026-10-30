import Foundation

/// Pure, testable mapping between a scanned document's category and the folder/tag metadata
/// DesignFoundationPro's `Documents` vertical expects (`DFFolderModel`/`DFTagModel` both need a
/// stable `UUID`, so each case carries a fixed one rather than generating one per launch).
enum DocumentCategory: String, CaseIterable, Sendable {
    case receipt = "Receipt"
    case id = "ID"
    case note = "Note"
    case other = "Other"

    var folderID: UUID {
        switch self {
        case .receipt: UUID(uuidString: "8C3D1B10-0000-4000-8000-000000000001")!
        case .id: UUID(uuidString: "8C3D1B10-0000-4000-8000-000000000002")!
        case .note: UUID(uuidString: "8C3D1B10-0000-4000-8000-000000000003")!
        case .other: UUID(uuidString: "8C3D1B10-0000-4000-8000-000000000004")!
        }
    }

    var folderName: String {
        switch self {
        case .receipt: "Receipts"
        case .id: "IDs & Cards"
        case .note: "Notes"
        case .other: "Other"
        }
    }

    var iconSystemName: String {
        switch self {
        case .receipt: "receipt"
        case .id: "person.text.rectangle"
        case .note: "note.text"
        case .other: "doc"
        }
    }

    var colorHex: String {
        switch self {
        case .receipt: "#4ECDC4"
        case .id: "#FF6B35"
        case .note: "#A8E063"
        case .other: "#8B8B8B"
        }
    }

    /// Maps the free-text category the on-device model returns into a known case, defaulting to
    /// `.other` for anything unrecognized (models don't always follow @Guide hints exactly).
    static func from(modelOutput: String) -> DocumentCategory {
        let normalized = modelOutput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return allCases.first { $0.rawValue.lowercased() == normalized } ?? .other
    }
}
