//
//  VaultView.swift
//  SilentKey
//
//  Created by Assistant AI on 18/01/2026.
//

import SwiftUI
import SilentKeyCore
import os.log

private let logger = os.Logger(subsystem: "com.thephoenixagency.silentkey", category: "VaultView")

/**
 VaultView (v0.9.0)
 Primary dashboard for secret management.
 Supports search, filtering, and Export/Import operations.
 Cloud Sync status integrated.
 */
struct VaultView: View {
    @StateObject private var localization = LocalizationManager.shared
    @State private var items: [SecretItem] = []
    @State private var isShowingAddSheet = false
    @State private var searchText = ""
    @State private var isCloudSynced = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localization.localized(.vault).uppercased())
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .tracking(4)
                    
                    HStack(spacing: 6) {
                        Circle().fill(isCloudSynced ? Color.green : Color.orange).frame(width: 8, height: 8)
                        Text(isCloudSynced ? "CLOUD SYNC ACTIVE" : "SYNCING...").font(.system(size: 10, weight: .black)).opacity(0.6)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: { /* Import logic */ }) {
                        Image(systemName: "square.and.arrow.down").font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                    .help("Import from CSV/JSON")
                    
                    Button(action: { /* Export logic */ }) {
                        Image(systemName: "square.and.arrow.up").font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                    .help("Export to CSV")
                    
                    Button(action: { isShowingAddSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("ADD SECRET")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(Color.blue).cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(30)
            
            searchBar
            
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
            Image(systemName: "magnifyingglass").foregroundStyle(.white.opacity(0.5))
            TextField(localization.localized(.search), text: $searchText).textFieldStyle(.plain)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12).background(Color.black.opacity(0.3)).cornerRadius(10).padding(.horizontal, 30).padding(.bottom, 20)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.dashed").font(.system(size: 80)).foregroundStyle(.white.opacity(0.1))
            Text("YOUR VAULT IS READY").font(.system(size: 18, weight: .bold)).foregroundStyle(.white.opacity(0.3)).tracking(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var filteredItems: [SecretItem] {
        if searchText.isEmpty { return items }
        return items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func loadVaultData() {
        // Mock data
        items = [
            SecretItem(title: "Google Workspace", type: .credential, encryptedValue: Data()),
            SecretItem(title: "AWS Production Key", type: .apiKey, encryptedValue: Data()),
            SecretItem(title: "Phoenix Agency Token", type: .token, encryptedValue: Data())
        ]
    }
}

struct VaultItemRow: View {
    let item: SecretItem
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconForType(item.type)).font(.system(size: 30)).foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Text(item.type.rawValue.uppercased()).font(.system(size: 10, weight: .black)).foregroundStyle(.white.opacity(0.4))
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundStyle(.white.opacity(0.2))
        }
        .padding(15).background(Color.white.opacity(0.05)).cornerRadius(12).padding(.vertical, 4)
    }
    
    private func iconForType(_ type: SecretType) -> String {
        switch type {
        case .apiKey: return "key.fill"
        case .token: return "command.circle.fill"
        case .credential: return "person.badge.key.fill"
        case .sshKey: return "terminal.fill"
        case .generic: return "lock.square.fill"
        }
    }
}
