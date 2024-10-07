//
//  DocumentPickerView.swift
//  autocross-mapper
//
//  Created by Karthik Subramanian on 10/7/24.
//

import SwiftUI
import UniformTypeIdentifiers

// DocumentPickerView for saving individual charts
struct DocumentPickerView: UIViewControllerRepresentable {
    var exportData: Data
    var chartName: String

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(chartName).json")

        // Write the chart data to a temporary file
        do {
            try exportData.write(to: tempURL)
        } catch {
            print("Failed to write data to temporary file: \(error)")
        }

        // Initialize document picker for exporting
        let documentPicker = UIDocumentPickerViewController(forExporting: [tempURL], asCopy: true)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // Handle successful export
            print("Exported to \(urls.first?.path ?? "unknown location")")
        }
    }
}
