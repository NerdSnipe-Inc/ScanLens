import SwiftUI
import SwiftData
import PhotosUI
import ImageIO
import DesignFoundation

struct ImportView: View {
    var onImported: () -> Void

    @Environment(\.modelContext) private var modelContext

    @State private var photoItem: PhotosPickerItem?
    @State private var stage: Stage = .idle
    @State private var errorMessage: String?

    private enum Stage: Equatable {
        case idle
        case recognizingText
        case extracting
        case saved(title: String)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    DFText("Scan a Document", scale: .headline)
                    DFText(
                        "Import a photo of a receipt, ID, or note. On-device Vision reads the text, then Apple Intelligence turns it into a titled, categorized entry in Documents.",
                        scale: .caption
                    )

                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label("Choose from Photos", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.df(.filled))
                    .disabled(isBusy)

                    DFDivider()

                    DFText("Or try a sample", scale: .label)

                    ForEach(SampleDocumentImageFactory.samples) { sample in
                        DFButton(sample.name, style: .outlined) {
                            Task { await runPipeline(cgImage: SampleDocumentImageFactory.renderImage(for: sample)) }
                        }
                        .disabled(isBusy)
                    }

                    statusView
                }
                .padding()
            }
            .navigationTitle("Import")
            .onChange(of: photoItem) { _, newItem in
                Task { await handlePickedPhoto(newItem) }
            }
        }
    }

    private var isBusy: Bool {
        stage == .recognizingText || stage == .extracting
    }

    @ViewBuilder
    private var statusView: some View {
        switch stage {
        case .idle:
            EmptyView()
        case .recognizingText:
            statusRow("Reading text on-device…")
        case .extracting:
            statusRow("Classifying with Apple Intelligence…")
        case .saved(let title):
            DFCard {
                HStack {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    DFText("Saved \"\(title)\" to Documents", scale: .body)
                }
                .padding()
            }
        }
        if let errorMessage {
            DFText(errorMessage, scale: .caption)
        }
    }

    private func statusRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            ProgressView()
            DFText(text, scale: .caption)
        }
    }

    private func handlePickedPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            guard
                let data = try await item.loadTransferable(type: Data.self),
                let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
                let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
            else {
                errorMessage = "Couldn't read that photo."
                return
            }
            await runPipeline(cgImage: cgImage)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func runPipeline(cgImage: CGImage?) async {
        errorMessage = nil
        guard let cgImage else {
            errorMessage = "Couldn't render an image to scan."
            return
        }

        do {
            stage = .recognizingText
            let text = try await TextRecognizer.recognizeText(in: cgImage)

            var title = String(text.split(separator: "\n").first ?? "Scanned Document")
            var category = DocumentCategory.other
            var summary = ""

            if #available(iOS 26.0, macOS 26.0, *) {
                stage = .extracting
                let engine = DocumentExtractionEngine()
                if engine.isAvailable {
                    // AI classification is an enhancement, not a requirement — if the on-device
                    // model fails for any reason (guardrail/asset issues, etc.), still save the
                    // document with the OCR text and the heuristic title/category below rather
                    // than losing the scan the user just did.
                    do {
                        let extraction = try await engine.extract(from: text)
                        title = extraction.title
                        category = DocumentCategory.from(modelOutput: extraction.category)
                        summary = extraction.summary
                    } catch {
                        errorMessage = "Saved with basic text only — on-device classification failed: \(error.localizedDescription)"
                    }
                }
            }

            let document = ScannedDocument(
                title: title,
                extractedText: text,
                summary: summary,
                category: category
            )
            modelContext.insert(document)
            stage = .saved(title: title)
            photoItem = nil
            onImported()
        } catch {
            stage = .idle
            errorMessage = error.localizedDescription
        }
    }
}
