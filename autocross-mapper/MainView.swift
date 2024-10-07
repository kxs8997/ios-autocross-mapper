import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack {
                // Button to navigate to the cone tagging page (ContentView)
                NavigationLink(destination: ContentView()) {
                    Text("Create New Chart")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                // Button to navigate to the saved charts page (SavedChartsView)
                NavigationLink(destination: SavedChartsView()) {
                    Text("View Saved Charts")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            
            }
            .navigationTitle("Autocross Mapper")
        }
    }
}

