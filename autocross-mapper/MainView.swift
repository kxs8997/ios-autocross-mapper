import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {  // Add spacing between buttons
                // Button to navigate to the cone tagging page (ContentView)
                NavigationLink(destination: ContentView()) {
                    Text("Create New Chart")
                        .frame(maxWidth: .infinity)
                        .padding()  // Internal padding
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)  // External horizontal padding

                // Button to navigate to the saved charts page (SavedChartsView)
                NavigationLink(destination: SavedChartsView()) {
                    Text("View Saved Charts")
                        .frame(maxWidth: .infinity)
                        .padding()  // Internal padding
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)  // External horizontal padding
            }
            .padding(.vertical)  // Vertical padding for the VStack
            .navigationTitle("Autocross Mapper")
        }
    }
}

