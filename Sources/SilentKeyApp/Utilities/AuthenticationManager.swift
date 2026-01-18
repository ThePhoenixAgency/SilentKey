import Foundation
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    func authenticate() {
        // Simulation d'authentification pour le moment
        isAuthenticated = true
    }
    
    func logout() {
        isAuthenticated = false
    }
}
