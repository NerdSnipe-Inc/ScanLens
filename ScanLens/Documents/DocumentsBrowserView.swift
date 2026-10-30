import SwiftUI
import SwiftData
import DesignFoundation
import DesignFoundationPro

/// The "Documents" tab — DesignFoundationPro's `Documents` vertical (browse + folders + tags +
/// editor) fed with our real SwiftData-persisted scans instead of its own fixture data.
///
/// Note on API fit: `DFDocumentsRootView` (the vertical's own composed root) owns its notes as
/// private `@State`, mutated in place on save/delete/pin with no callback out — it's meant to be
/// dropped in with its own fixture data, not driven by an external store. So instead we compose
/// the same two screens it composes internally (`DFDocumentBrowserScreen` for the list/sidebar,
/// `DFDocumentEditorScreen` for editing), but wire their callbacks to `modelContext` ourselves —
/// exactly the pattern `DFDocumentsRootView.compactShell` uses, just backed by real persistence.
struct DocumentsBrowserView: View {
    var onRequestImport: @MainActor @Sendable () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScannedDocument.modifiedAt, order: .reverse) private var documents: [ScannedDocument]
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            DFDocumentBrowserScreen(configuration: browserConfiguration)
                .navigationDestination(for: UUID.self) { id in
                    if let document = documents.first(where: { $0.id == id }) {
                        DFDocumentEditorScreen(configuration: editorConfiguration(for: document))
                    } else {
                        ContentUnavailableView("Document not found", systemImage: "doc.questionmark")
                    }
                }
        }
    }

    private var activeDocuments: [ScannedDocument] {
        documents.filter { !$0.isTrashed }
    }

    private var browserConfiguration: DFDocumentBrowserScreen.Configuration {
        DFDocumentBrowserScreen.Configuration(
            notes: documents.map(DocumentsMapper.note(for:)),
            folders: DocumentsMapper.folders(for: documents),
            tags: DocumentsMapper.allTags,
            appName: "ScanLens",
            trashCount: documents.count - activeDocuments.count,
            onNewNote: onRequestImport,
            onSelectNote: { id in navigationPath.append(id) },
            onPinNote: togglePin,
            onMoveNote: { _ in },
            onDeleteNote: trash
        )
    }

    private func editorConfiguration(for document: ScannedDocument) -> DFDocumentEditorScreen.Configuration {
        DFDocumentEditorScreen.Configuration(
            noteID: document.id,
            initialTitle: document.title,
            initialBody: document.extractedText,
            availableTags: DocumentsMapper.allTags,
            selectedTagIDs: [document.category.folderID],
            onDismiss: { navigationPath.removeLast() },
            onSave: { title, body, _ in save(document, title: title, body: body) }
        )
    }

    private func togglePin(_ id: UUID) {
        guard let document = documents.first(where: { $0.id == id }) else { return }
        document.isPinned.toggle()
        document.modifiedAt = .now
    }

    private func trash(_ id: UUID) {
        guard let document = documents.first(where: { $0.id == id }) else { return }
        document.isTrashed = true
        document.isPinned = false
    }

    private func save(_ document: ScannedDocument, title: String, body: String) {
        document.title = title
        document.extractedText = body
        document.modifiedAt = .now
    }
}
