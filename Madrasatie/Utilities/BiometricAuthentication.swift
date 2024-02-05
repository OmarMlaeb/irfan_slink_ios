//
//  BiometricAuthentication.swift
//  SUMSUNG
//
//  Created by Miled Aoun on 7/13/18.
//  Copyright © 2018 NOVA4. All rights reserved.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
}

class BiometricAuthentication {
    var loginReason = "Logging in with Touch ID"
    
    @available(iOS 11.0, *)
    func biometricType() -> BiometricType {
        let context = LAContext()
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        case .opticID:
            return .none
        }
    }
    
    func canEvaluatePolicy() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    func authenticateUser(completion: @escaping (String?) -> Void) {
        let context = LAContext()
        guard canEvaluatePolicy() else {
            completion("Touch ID not available")
            return
        }
        
        if #available(iOS 11.0, *) {
            if biometricType() == .faceID{
                loginReason = "Logging in with Face ID"
            }
        }
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: loginReason) { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    // User authenticated successfully, take appropriate action
                    completion(nil)
                }
            } else {
                let message: String
                
                if #available(iOS 11.0, *) {
                    switch evaluateError {
                    case LAError.authenticationFailed?:
                        message = "There was a problem verifying your identity."
                    case LAError.userCancel?:
                        message = "You pressed cancel."
                    case LAError.userFallback?:
                        message = "You pressed password."
                    case LAError.biometryNotAvailable?:
                        message = "Face ID/Touch ID is not available."
                    case LAError.biometryNotEnrolled?:
                        message = "Face ID/Touch ID is not set up."
                    case LAError.biometryLockout?:
                        message = "Face ID/Touch ID is locked."
                    default:
                        message = "Face ID/Touch ID may not be configured"
                    }
                } else {
                    switch evaluateError {
                    case LAError.authenticationFailed?:
                        message = "There was a problem verifying your identity."
                    case LAError.userCancel?:
                        message = "You pressed cancel."
                    case LAError.userFallback?:
                        message = "You pressed password."
                    default:
                        message = "Face ID/Touch ID may not be configured"
                    }
                }
                completion(message)
            }
        }
    }
}
