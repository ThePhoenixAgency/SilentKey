//
//  StoreView.swift
//  SilentKey
//
//  Interface professionnelle du magasin avec paywall moderne
//  Design élégant pour présenter les offres d'abonnement
//

import SwiftUI
import StoreKit

/// Vue principale du magasin avec paywall professionnel
struct StoreView: View {
    @StateObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var showingError = false
    @State private var showingSuccess = false
    
    var body: some View {
        ZStack {
            // Arrière-plan avec dégradé moderne
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.15, green: 0.15, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // En-tête
                    header
                    
                    // Cartes de produits
                    productsGrid
                    
                    // Fonctionnalités
                    featuresSection
                    
                    // Boutons d'action
                    actionsSection
                    
                    // Footer
                    footer
                }
                .padding(40)
            }
        }
        .frame(minWidth: 700, minHeight: 800)
        .alert("Erreur", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = storeManager.error {
                Text(error.localizedDescription)
            }
        }
        .alert("✓ Achat réussi!", isPresented: $showingSuccess) {
            Button("Continuer", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Merci pour votre achat! Profitez de SilentKey sans limites.")
        }
        .overlay(alignment: .topTrailing) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(20)
        }
    }
    
    // MARK: - Composants
    
    private var header: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Passez à SilentKey Pro")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text("Sécurité maximale, secrets illimités")
                .font(.title3)
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var productsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 20),
            GridItem(.flexible(), spacing: 20)
        ], spacing: 20) {
            ForEach(storeManager.products, id: \.id) { product in
                ProductCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                        isRecommended: product.id == "com.silentkey.lifetime"                ) {
                    selectedProduct = product
                }
            }
        }
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("✨ Fonctionnalités incluses")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                FeatureRow(icon: "infinity", text: "Secrets illimités")
                FeatureRow(icon: "lock.shield", text: "Double encryption")
                FeatureRow(icon: "icloud", text: "Sync iCloud")
                FeatureRow(icon: "face.smiling", text: "Support prioritaire")
                FeatureRow(icon: "bolt.fill", text: "Mises à jour rapides")
                FeatureRow(icon: "star.fill", text: "Fonctionnalités futures")
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            // Bouton d'achat principal
            Button(action: purchaseSelected) {
                HStack {
                    if storeManager.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    }
                    
                    Text(purchaseButtonText)
                        .font(.title3.bold())
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .disabled(selectedProduct == nil || storeManager.isLoading)
            
            // Bouton restaurer achats
            Button(action: restorePurchases) {
                Text("Restaurer les achats")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
    }
    
    private var footer: some View {
        VStack(spacing: 12) {
            Text("Paiement sécurisé via l'App Store")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            
            HStack(spacing: 16) {
                Link("Conditions d'utilisation", destination: URL(string: "https://github.com/EthanThePhoenix38/SilentKey")!)
                Text("•")
                Link("Politique de confidentialité", destination: URL(string: "https://github.com/EthanThePhoenix38/SilentKey")!)
            }
            .font(.caption2)
            .foregroundColor(.white.opacity(0.5))
        }
    }
    
    private var purchaseButtonText: String {
        if storeManager.isLoading {
            return "Traitement..."
        } else if let product = selectedProduct {
            return "Acheter pour \(product.displayPrice)"
        } else {
            return "Sélectionnez une offre"
        }
    }
    
    // MARK: - Actions
    
    private func purchaseSelected() {
        guard let product = selectedProduct else { return }
        
        AppLogger.shared.userAction("Tentative d'achat: \(product.displayName)", category: .purchase)
        
        Task {
            do {
                try await storeManager.purchase(product)
                await MainActor.run {
                    showingSuccess = true
                }
            } catch {
                await MainActor.run {
                    showingError = true
                }
            }
        }
    }
    
    private func restorePurchases() {
        AppLogger.shared.userAction("Restauration des achats", category: .purchase)
        
        Task {
            do {
                try await storeManager.restorePurchases()
                await MainActor.run {
                    showingSuccess = true
                }
            } catch {
                await MainActor.run {
                    showingError = true
                }
            }
        }
    }
}

// MARK: - Carte de produit

struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let isRecommended: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 16) {
                // Badge recommandé
                if isRecommended {
                    HStack {
                        Spacer()
                        Text("⭐️ RECOMMANDÉ")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.orange)
                            )
                    }
                }
                
                // Nom du produit
                Text(product.displayName)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                // Description
                Text(product.detailedDescription)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 60, alignment: .topLeading)
                
                Spacer()
                
                // Prix
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(product.displayPrice)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    if product.type == .autoRenewable {
                        Text("/mois")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    } else {
                        Text("unique")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Indicateur de sélection
                if isSelected {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Sélectionné")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: 280)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        isSelected ? Color.blue : Color.white.opacity(0.2),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ligne de fonctionnalité

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

// MARK: - Prévisualisation

#Preview {
    StoreView()
}
