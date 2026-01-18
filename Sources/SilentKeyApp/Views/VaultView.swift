//
//  VaultView.swift
//  SilentKey
//
//  Created by Assistant AI on 18/01/2026.
//

import SwiftUI
import SilentKeyCore
import os.log

private let logger = Logger(subsystem: "com.thephoenixagency.silentkey", category: "VaultView")

/**
 VaultView (v2.2.0)
 Primary dashboard for secret management.
 Supports search, filtering, and CRUD operations.
 */
struct VaultView: View {
    @StateObject private var localization = LocalizationManager.shared
    @State private var items: [SecretItem] = []
    @State private var isShowingAddSheet = false
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Text(localization.localized(.vault).uppercased())
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(4)
                
                Spacer()
                
                Button(action: { isShowingAddSheet = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(localization.localized(.addSecret).uppercased())
                    }
                    .font(.system(size: 14, weight: .bold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(30)
            
            // Search Bar
            searchBar
            
            // Content
            if items.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(filteredItems) { item in
                        VaultItemRow(item: item)
                    }
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
            }
        }
        .onAppear { loadVaultData() }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.5))
            TextField(localization.localized(.search), text: $searchText)
                .textFieldStyle(.plain)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.dashed")
                .font(.system(size: 80))
                .foregroundStyle(.white.opacity(0.1))
            Text(localization.localized(.noSecrets).uppercased())
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
                .tracking(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var filteredItems: [SecretItem] {
        if searchText.isEmpty { return items }
        return items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func loadVaultData() {
        logger.info("Loading vault data.")
        // Simulated loading from VaultManager
        // items = VaultManager.shared.getItems()
    }
}

struct VaultItemRow: View {
    let item: SecretItem
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "lock.square.fill")
                .font(.system(size: 30))
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Text(item.username)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.2))
        }
        .padding(15)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.vertical, 4)
    }
}

// MOCK SECRET ITEM FOR UI TESTING
struct SecretItem: Identifiable {
    let id = UUID()
    let title: String
    let username: String
}
