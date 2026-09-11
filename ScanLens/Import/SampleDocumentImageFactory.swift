import SwiftUI
import UIKit

/// Renders a few plain sample "documents" on the fly (grocery receipt, parking receipt, meeting
/// note) so the OCR → AI extraction pipeline is fully demoable without needing to seed the
/// Simulator's Photos library or ship binary image assets.
@MainActor
enum SampleDocumentImageFactory {
    struct Sample: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let content: String
    }

    static let samples: [Sample] = [
        Sample(
            name: "Grocery Receipt",
            icon: "cart",
            content: """
            WHOLE FOODS MARKET
            445 Market St

            Organic Bananas        $3.49
            Almond Milk             $4.99
            Sourdough Bread         $5.25
            Avocado x3              $4.50

            SUBTOTAL               $18.23
            TAX                     $1.60
            TOTAL                  $19.83

            09/10/2026  2:14 PM
            Thank you for shopping!
            """
        ),
        Sample(
            name: "Parking Receipt",
            icon: "parkingsign",
            content: """
            CITY PARKING GARAGE
            Lot 12 — Downtown

            Entry: 09/09/2026 9:02 AM
            Exit:  09/09/2026 5:47 PM
            Duration: 8h 45m

            RATE: $2.50/hr
            AMOUNT DUE: $22.00

            Paid by card ending 4471
            """
        ),
        Sample(
            name: "Meeting Note",
            icon: "note.text",
            content: """
            Team Sync — Sept 8

            - Ship the Documents vertical demo by Friday
            - Review OCR accuracy on receipts
            - Follow up with design on folder icons

            Next check-in: Thursday 10am
            """
        )
    ]

    static func renderImage(for sample: Sample) -> CGImage? {
        let content = VStack(alignment: .leading, spacing: 8) {
            Text(sample.content)
                .font(.system(size: 22, design: .monospaced))
                .foregroundStyle(.black)
        }
        .padding(24)
        .frame(width: 600, alignment: .leading)
        .background(Color.white)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 2
        return renderer.uiImage?.cgImage
    }
}
