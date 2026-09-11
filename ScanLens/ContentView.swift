import SwiftUI
import DesignFoundation

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DocumentsBrowserView(onRequestImport: { selectedTab = 1 })
                .tabItem { Label("Documents", systemImage: "doc.text.image") }
                .tag(0)

            ImportView(onImported: { selectedTab = 0 })
                .tabItem { Label("Import", systemImage: "camera.viewfinder") }
                .tag(1)
        }
    }
}
