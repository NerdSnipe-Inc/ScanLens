import SwiftUI
import SwiftData
import DesignFoundation

@main
struct ScanLensApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: ScannedDocument.self)
        } catch {
            fatalError("Failed to create SwiftData ModelContainer: \(error)")
        }

        SampleData.seedIfNeeded(context: modelContainer.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .dfThemePreset(.aurora)
        }
        .modelContainer(modelContainer)
    }
}
