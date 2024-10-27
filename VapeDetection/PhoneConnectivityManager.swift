import WatchConnectivity
import SwiftUI

class PhoneConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = PhoneConnectivityManager()
    @Published var motionData: String = "Waiting for data..."
    
    private var dataString: String = "time,x,y,z,gx,gy,gz,hit\n"

      // CSV file URL
      private var csvFileURL: URL

    @Published var isHitting = false
//    private var csvFileURL: URL

    override init() {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        csvFileURL = paths[0].appendingPathComponent("motion_data_received.csv")
    
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
            DispatchQueue.main.async {
                if let time = message["time"] as? String,
                   let x = message["x"] as? String,
                   let y = message["y"] as? String,
                   let z = message["z"] as? String,
                   let gx = message["gx"] as? String,
                   let gy = message["gy"] as? String,
                   let gz = message["gz"] as? String,
                   let hit = message["hit"] as? Bool {
                    
                    self.motionData = """
                    Time: \(time)
                    Accel X: \(x), Y: \(y), Z: \(z)
                    Gyro X: \(gx), Y: \(gy), Z: \(gz)
                    Hit: \(hit)
                    """
                    
                    let newLine = "\(time),\(x),\(y),\(z),\(gx),\(gy),\(gz),\(hit)\n"
                    self.dataString.append(newLine)
                }
            }
        }
    
    func saveToCSV() {
           do {
               try dataString.write(to: csvFileURL, atomically: true, encoding: .utf8)
               print("CSV file saved at \(csvFileURL.path)")
           } catch {
               print("Failed to save CSV file: \(error.localizedDescription)")
           }
       }

       // Share the CSV file using UIActivityViewController
       func shareCSV() {
           let activityViewController = UIActivityViewController(activityItems: [csvFileURL], applicationActivities: nil)
           UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
       }
    
    // Toggle the "hit" status and send it to the Watch
    func toggleHitStatus() {
        isHitting.toggle()
        sendHitStatus(isHitting: isHitting)
    }

    // Send a message to the Watch with hit status
    func sendHitStatus(isHitting: Bool) {
        if WCSession.default.activationState == .activated && WCSession.default.isReachable {
            let message = ["hit": isHitting ? "hit" : "not"]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Error sending message: \(error.localizedDescription)")
            })
        } else {
            print("Session is not activated or Watch is not reachable")
        }
    }
    
    // Request CSV file from the Watch
//        func requestCSVFileFromWatch() {
//            if WCSession.default.isReachable {
//                let message = ["command": "sendCSV"]
//                WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
//                    print("Error requesting CSV from watch: \(error.localizedDescription)")
//                })
//            }
//        }
    
    // Handle incoming CSV data from Watch
//        func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
//            do {
//                try messageData.write(to: csvFileURL)
//                print("CSV file received and saved at \(csvFileURL.path)")
//            } catch {
//                print("Failed to save CSV file: \(error.localizedDescription)")
//            }
//        }

        // Share the CSV file
//        func shareCSV() {
//            let activityViewController = UIActivityViewController(activityItems: [csvFileURL], applicationActivities: nil)
//            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
//        }

    // WCSessionDelegate required methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("iPhone session activation failed: \(error.localizedDescription)")
        } else {
            print("iPhone session activated with state: \(activationState)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate() // Re-activate the session
    }
}
