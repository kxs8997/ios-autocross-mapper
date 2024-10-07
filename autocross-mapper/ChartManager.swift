import Foundation

struct SavedChart: Codable {
    let name: String
    let coneData: [Cone]
    let rotationAngle: Double
}

class ChartManager {
    static let exportFileName = "exportedCharts.json"

    // Save chart to UserDefaults (old method)
    static func saveChart(name: String, coneLocations: [Cone], rotationAngle: Double) {
        let savedChart = SavedChart(name: name, coneData: coneLocations, rotationAngle: rotationAngle)
        
        var savedCharts = loadCharts() ?? []
        savedCharts.append(savedChart)
        
        if let encoded = try? JSONEncoder().encode(savedCharts) {
            UserDefaults.standard.set(encoded, forKey: "savedCharts")
        }
    }
    
    // Load charts from UserDefaults
    static func loadCharts() -> [SavedChart]? {
        if let data = UserDefaults.standard.data(forKey: "savedCharts") {
            if let decoded = try? JSONDecoder().decode([SavedChart].self, from: data) {
                return decoded
            }
        }
        return nil
    }
    
    // Delete chart from UserDefaults
    static func deleteChart(at index: Int) {
        var savedCharts = loadCharts() ?? []
        if index < savedCharts.count {
            savedCharts.remove(at: index)
            
            if let encoded = try? JSONEncoder().encode(savedCharts) {
                UserDefaults.standard.set(encoded, forKey: "savedCharts")
            }
        }
    }

    // Print list of all saved charts
    static func printAllCharts() {
        if let charts = loadCharts() {
            for (index, chart) in charts.enumerated() {
                print("Chart \(index + 1): \(chart.name) - Rotation: \(chart.rotationAngle) - Number of Cones: \(chart.coneData.count)")
            }
        } else {
            print("No charts found.")
        }
    }

    // Export charts to a file
    static func exportChartsToFile() {
        if let charts = loadCharts() {
            if let encoded = try? JSONEncoder().encode(charts) {
                let fileURL = getDocumentsDirectory().appendingPathComponent(exportFileName)
                do {
                    try encoded.write(to: fileURL)
                    print("Charts successfully exported to: \(fileURL.path)")
                } catch {
                    print("Failed to export charts to file: \(error.localizedDescription)")
                }
            } else {
                print("Failed to encode charts for export.")
            }
        } else {
            print("No charts available to export.")
        }
    }

    // Helper to get the documents directory
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

