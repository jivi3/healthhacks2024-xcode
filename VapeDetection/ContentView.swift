import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @State private var isHitting = false
    @ObservedObject var connectivityManager = PhoneConnectivityManager.shared

    var body: some View {
        VStack {
            Text("Hit Detection")
                .font(.largeTitle)
                .padding()

            // Display the motion data received from the Watch
            Text(connectivityManager.motionData)
                .padding()
                .multilineTextAlignment(.leading)
                .foregroundColor(.white)

            Spacer()

            // Button to start/stop recording hit
            Button(action: {
                isHitting.toggle()
                PhoneConnectivityManager.shared.sendHitStatus(isHitting: isHitting)
            }) {
                Text(isHitting ? "Stop Hit" : "Start Hit")
                    .padding()
                    .background(isHitting ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()

            // Button to save the accumulated motion data to CSV
            Button(action: {
                connectivityManager.saveToCSV()
            }) {
                Text("Save to CSV")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            // Button to share the CSV file
            Button(action: {
                connectivityManager.shareCSV()
            }) {
                Text("Share CSV")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}
