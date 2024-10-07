import SwiftUI
import UniformTypeIdentifiers

struct SavedChartsView: View {
    @State private var savedCharts: [SavedChart] = []
    @State private var selectedChart: SavedChart?
    @State private var exportData: Data?
    @State private var showingDocumentPicker = false
    @State private var showingChartSelection = false
    @State private var showingImportPicker = false

    var body: some View {
        VStack {
            if savedCharts.isEmpty {
                Text("No saved charts yet.")
                    .padding()
            } else {
                List(savedCharts, id: \.name) { chart in
                    NavigationLink(destination: SavedChartView(chart: chart)) {
                        Text(chart.name)
                    }
                }
            }

            // Add Export Button to Select and Export a Chart
            Button(action: {
                showingChartSelection = true // Trigger chart selection
            }) {
                Text("Export a Chart")
                    .font(.subheadline)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .actionSheet(isPresented: $showingChartSelection) {
                ActionSheet(title: Text("Select a Chart to Export"), buttons: createChartSelectionButtons())
            }
            .sheet(isPresented: $showingDocumentPicker) {
                if let data = exportData {
                    DocumentPickerView(exportData: data, chartName: selectedChart?.name ?? "Chart")
                }
            }

            // Add Load Chart Button
            Button(action: {
                showingImportPicker = true // Trigger file picker for importing chart
            }) {
                Text("Load a Chart")
                    .font(.subheadline)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .sheet(isPresented: $showingImportPicker) {
                DocumentPickerImportView(onChartLoaded: { chart in
                    savedCharts.append(chart) // Add loaded chart to saved charts
                })
            }

            // Add Print All Charts Button
            Button(action: {
                ChartManager.printAllCharts() // Call print all charts function
            }) {
                Text("Print Charts")
                    .font(.subheadline)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .onAppear {
            if let loadedCharts = ChartManager.loadCharts() {
                savedCharts = loadedCharts
            }
        }
        .navigationTitle("Saved Charts")
    }

    // Create buttons for selecting which chart to export
    func createChartSelectionButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = savedCharts.map { chart in
            ActionSheet.Button.default(Text(chart.name)) {
                selectedChart = chart
                exportSelectedChart()
            }
        }
        buttons.append(.cancel())
        return buttons
    }

    // Export the selected chart
    func exportSelectedChart() {
        if let chart = selectedChart {
            if let encoded = try? JSONEncoder().encode(chart) {
                exportData = encoded
                showingDocumentPicker = true // Trigger document picker to export file
            }
        }
    }
}

// DocumentPickerImportView for loading a chart
struct DocumentPickerImportView: UIViewControllerRepresentable {
    var onChartLoaded: (SavedChart) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json], asCopy: true)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onChartLoaded: onChartLoaded)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onChartLoaded: (SavedChart) -> Void

        init(onChartLoaded: @escaping (SavedChart) -> Void) {
            self.onChartLoaded = onChartLoaded
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            do {
                let data = try Data(contentsOf: url)
                let decodedChart = try JSONDecoder().decode(SavedChart.self, from: data)
                onChartLoaded(decodedChart)
                print("Chart successfully loaded: \(decodedChart.name)")
            } catch {
                print("Failed to load chart: \(error.localizedDescription)")
            }
        }
    }
}

