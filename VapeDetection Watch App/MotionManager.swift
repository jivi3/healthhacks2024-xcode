import CoreMotion
import WatchConnectivity
import Foundation
import SwiftUI

class MotionManager: NSObject, ObservableObject, WCSessionDelegate {
    private var motionManager = CMMotionManager()
    @Published var isHitting = false

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        startMotionUpdates() // Start motion updates when initialized
    }

    // Start motion updates using CoreMotion
    func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02 // Poll at 50 Hz (20 ms intervals)
            motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
                guard let motion = motion else { return }
                
                // Accelerometer data
                let x = motion.userAcceleration.x
                let y = motion.userAcceleration.y
                let z = motion.userAcceleration.z

                // Gyroscope data
                let gx = motion.rotationRate.x
                let gy = motion.rotationRate.y
                let gz = motion.rotationRate.z

                let hitStatus = self.isHitting ? true : false
                let currentTime = Date().timeIntervalSince1970

                // Log motion data including gyroscope
                let motionDataString = """
                Time: \(currentTime),
                Accel X: \(x), Y: \(y), Z: \(z),
                Gyro X: \(gx), Y: \(gy), Z: \(gz),
                Hit: \(hitStatus)
                """
                print(motionDataString)

                // Send the motion data to iPhone
                self.sendMotionDataToPhone(
                    time: currentTime,
                    x: x,
                    y: y,
                    z: z,
                    gx: gx,
                    gy: gy,
                    gz: gz,
                    hit: hitStatus
                )
            }
        } else {
            print("Device Motion not available")
        }
    }


        // Send motion data to the iPhone using WCSession
    private func sendMotionDataToPhone(time: TimeInterval, x: Double, y: Double, z: Double, gx: Double, gy: Double, gz: Double, hit: Bool) {
        if WCSession.default.isReachable {
            let message: [String: Any] = [
                "time": "\(time)",
                "x": "\(x)",
                "y": "\(y)",
                "z": "\(z)",
                "gx": "\(gx)",
                "gy": "\(gy)",
                "gz": "\(gz)",
                "hit": hit
            ]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Error sending motion data to iPhone: \(error.localizedDescription)")
            })
        }
    }


    // This is the method that was missing
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle the received message from the iPhone
        if let hitStatus = message["hit"] as? String {
            DispatchQueue.main.async {
                self.isHitting = (hitStatus == "hit")
                print("Received hit status: \(hitStatus)")
            }
        }
    }

    // Handle session activation
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Watch session activation failed: \(error.localizedDescription)")
        } else {
            print("Watch session activated")
        }
    }

    // Optional: Handle any session deactivation or inactive states
//    func sessionDidBecomeInactive(_ session: WCSession) {}
//    func sessionDidDeactivate(_ session: WCSession) {
//        session.activate() // Re-activate the session
//    }
}
