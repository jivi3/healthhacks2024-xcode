import SwiftUI

struct ContentView: View {
//    @ObservedObject var connectivityManager = WatchConnectivityManager.shared
    @ObservedObject var motionManager = MotionManager()
    var body: some View {
        VStack {
            Text("Hit Detection")
                .font(.largeTitle)
                .padding()
          
            Text(motionManager.isHitting ? "Hitting" : "Not Hitting")
                .font(.title)
                .padding()
                .background(motionManager.isHitting ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            
        }
    }
}
