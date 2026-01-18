//
//  StoreManager.swift
//  SilentKey
//
//  Gestionnaire des achats in-app et modèle freemium
//  Gère: 5 secrets gratuits, achats StoreKit, codes promo
//

import Foundation
import StoreKit

/// Gestionnaire centralisé des achats in-app et du modèle freemium
@MainActor
public final class StoreManager: ObservableObject {
    // MARK: - Singleton
    public static let shared = StoreManager()
    
    // MARK: - Propriétés publiées
    @Published public private(set) var products: [Product] = []
    @Published public private(set) var purchasedProductIDs = Set<String>()
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: StoreError?
    
    // MARK: - Configuration
    private let freeSecretsLimit = 5
    
    /// Identifiants des produits dans App Store Connect
    /// À configurer dans App Store Connect avant publication
    public enum ProductID: String, CaseIterable {
        case unlimitedSecrets = "com.silentkey.unlimited"
        case pro = "com.silentkey.pro"
        case lifetime = "com.silentkey.lifetime"
        
        var displayName: String {
            switch self {
            case .unlimitedSecrets: return "Secrets Illimités"
            case .pro: return "Pro (Mensuel)"
            case .lifetime: return "Accès Vie (Unique)"
            }
        }
    }
    
    // MARK: - Erreurs
    public enum StoreError: LocalizedError {
        case failedVerification
        case productNotFound
        case purchaseFailed(Error)
        case restoreFailed
        
        public var errorDescription: String? {
            switch self {
            case .failedVerification:
                return "Échec de vérification de l'achat"
            case .productNotFound:
                return "Produit introuvable"
            case .purchaseFailed(let error):
                return "Achat échoué: \(error.localizedDescription)"
            case .restoreFailed:
                return "Restauration des achats échouée"
            }
        }
    }
    
    // MARK: - Task de mise à jour
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Initialisation
    private init() {
        // Démarrer l'écoute des transactions
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
        
        AppLogger.shared.info("StoreManager initialisé", category: .purchase)
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Méthodes publiques
    
    /// Vérifie si l'utilisateur peut créer un nouveau secret
    /// - Parameter currentSecretCount: Nombre actuel de secrets
    /// - Returns: Vrai si création autorisée
    public func canCreateSecret(currentSecretCount: Int) -> Bool {
        // Si abonnement actif, pas de limite
        if hasActiveSubscription {
            return true
        }
        
        // Sinon, limiter à 5 secrets gratuits
        return currentSecretCount < freeSecretsLimit
    }
    
    /// Vérifie si l'utilisateur a un abonnement actif
    public var hasActiveSubscription: Bool {
        return !purchasedProductIDs.isEmpty
    }
    
    /// Retourne le type d'abonnement actif
    public var subscriptionType: ProductID? {
        for id in purchasedProductIDs {
            if let productID = ProductID(rawValue: id) {
                return productID
            }
        }
        return nil
    }
    
    /// Charge les produits depuis App Store
    public func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            let storeProducts = try await Product.products(for: productIDs)
            
            DispatchQueue.main.async {
                self.products = storeProducts
                AppLogger.shared.info("\(storeProducts.count) produits chargés", category: .purchase)
            }
        } catch {
            DispatchQueue.main.async {
                self.error = .purchaseFailed(error)
                AppLogger.shared.logError(error, context: "Chargement des produits", category: .purchase)
            }
        }
    }
    
    /// Effectue un achat
    /// - Parameter product: Produit à acheter
    public func purchase(_ product: Product) async throws {
        isLoading = true
        defer { isLoading = false }
        
        AppLogger.shared.userAction("Tentative d'achat: \(product.displayName)", category: .purchase)
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Vérifier la transaction
                let transaction = try checkVerified(verification)
                
                // Mettre à jour les produits achetés
                await updatePurchasedProducts()
                
                // Finaliser la transaction
                await transaction.finish()
                
                AppLogger.shared.info("Achat réussi: \(product.displayName)", category: .purchase)
                
            case .userCancelled:
                AppLogger.shared.info("Achat annulé par l'utilisateur", category: .purchase)
                
            case .pending:
                AppLogger.shared.info("Achat en attente d'approbation", category: .purchase)
                
            @unknown default:
                AppLogger.shared.warning("Résultat d'achat inconnu", category: .purchase)
            }
        } catch {
            AppLogger.shared.logError(error, context: "Achat du produit \(product.displayName)", category: .purchase)
            throw StoreError.purchaseFailed(error)
        }
    }
    
    /// Restaure les achats précédents
    public func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }
        
        AppLogger.shared.userAction("Restauration des achats", category: .purchase)
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            AppLogger.shared.info("Achats restaurés avec succès", category: .purchase)
        } catch {
            AppLogger.shared.logError(error, context: "Restauration des achats", category: .purchase)
            throw StoreError.restoreFailed
        }
    }
    
    /// Applique un code promotionnel
    /// - Parameter code: Code promo à appliquer
    public func redeemPromoCode(_ code: String) async throws {
        AppLogger.shared.userAction("Utilisation du code promo", category: .purchase)
        
        // Note: StoreKit gère les codes promo automatiquement
        // Cette méthode peut être étendue pour des codes personnalisés
        try await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    // MARK: - Méthodes privées
    
    /// Écoute les transactions en arrière-plan
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    await self.updatePurchasedProducts()
                    
                    await transaction.finish()
                } catch {
                    AppLogger.shared.logError(error, context: "Transaction update", category: .purchase)
                }
            }
        }
    }
    
    /// Met à jour la liste des produits achetés
    private func updatePurchasedProducts() async {
        var purchasedIDs = Set<String>()
        
        // Vérifier les transactions actuelles
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Vérifier si la transaction est toujours valide
                if transaction.revocationDate == nil {
                    purchasedIDs.insert(transaction.productID)
                }
            } catch {
                AppLogger.shared.logError(error, context: "Vérification des entitlements", category: .purchase)
            }
        }
        
        DispatchQueue.main.async {
            self.purchasedProductIDs = purchasedIDs
            AppLogger.shared.debug("Produits achetés mis à jour: \(purchasedIDs.count)", category: .purchase)
        }
    }
    
    /// Vérifie la validité d'une transaction
    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            AppLogger.shared.security("Transaction non vérifiée détectée")
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Extensions de formatage

extension Product {
    /// Prix formaté avec devise
    var formattedPrice: String {
        return displayPrice
    }
    
    /// Description détaillée du produit
    var detailedDescription: String {
        switch self.id {
        case StoreManager.ProductID.unlimitedSecrets.rawValue:
            return "Stockez un nombre illimité de secrets en toute sécurité"
        case StoreManager.ProductID.pro.rawValue:
            return "Accès complet + fonctionnalités avancées + support prioritaire"
        case StoreManager.ProductID.lifetime.rawValue:
            return "Accès illimité à vie sans abonnement récurrent"
        default:
            return description
        }
    }
}

// MARK: - Helper pour UI

extension StoreManager {
    /// Retourne un message pour inciter à l'upgrade
    public func getUpgradePrompt(currentSecretCount: Int) -> String? {
        guard !hasActiveSubscription else { return nil }
        
        let remaining = max(0, freeSecretsLimit - currentSecretCount)
        
        if remaining == 0 {
            return "Vous avez atteint la limite de \(freeSecretsLimit) secrets gratuits. Passez à la version Pro pour créer des secrets illimités."
        } else if remaining <= 2 {
            return "Plus que \(remaining) secret(s) gratuit(s) disponible(s). Passez à Pro pour un accès illimité."
        }
        
        return nil
    }
    
    /// Retourne le produit le plus populaire
    public var recommendedProduct: Product? {
        return products.first { $0.id == ProductID.lifetime.rawValue }
    }
}
