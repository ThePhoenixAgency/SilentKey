//
//  TrashManager.swift
//  SilentKey
//

import Foundation
import UserNotifications

/// Gestionnaire de la poubelle avec rétention 30 jours
actor TrashManager {
    static let shared = TrashManager()
    
    private let fileStorage: FileStorage
    private let logger = Logger.shared
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Rétention de 30 jours
    private let retentionDays: Int = 30
    private let cleanupCheckInterval: TimeInterval = 24 * 60 * 60 // 1 jour
    
    // MARK: - Initialisation
    
    private init() {
        self.fileStorage = FileStorage.shared
        
        // Planifier le nettoyage automatique
        Task {
            await scheduleAutomaticCleanup()
        }
        
        logger.log("TrashManager initialisé", level: .info, category: .storage)
    }
    
    // MARK: - Trash Operations
    
    /// Déplace un item vers la poubelle
    func moveToTrash<T: SecretItemProtocol>(_ item: T) async throws {
        logger.log("Déplacement vers poubelle: \(item.title)", level: .info, category: .storage)
        
        // Déplacer vers la poubelle via FileStorage
        try await fileStorage.moveToTrash(forID: item.id)
        
        // Planifier une notification d'expiration
        await scheduleExpirationNotification(for: item)
        
        logger.log("Item déplacé vers poubelle avec succès", level: .info, category: .storage)
    }
    
    /// Restaure un item depuis la poubelle
    func restore(id: UUID) async throws {
        logger.log("Restauration item: \(id)", level: .info, category: .storage)
        
        // Vérifier si l'item existe dans la poubelle
        let trashItems = try await listTrashItems()
        guard trashItems.contains(where: { $0.id == id }) else {
            throw TrashError.itemNotInTrash
        }
        
        // Restaurer via FileStorage (gère les conflits de noms)
        try await fileStorage.restoreFromTrash(id: id)
        
        // Annuler la notification d'expiration
        await cancelExpirationNotification(for: id)
        
        logger.log("Item restauré avec succès", level: .info, category: .storage)
    }
    
    /// Supprime définitivement un item de la poubelle
    func permanentDelete(id: UUID) async throws {
        logger.log("Suppression définitive: \(id)", level: .warning, category: .storage)
        
        try await fileStorage.permanentDelete(id: id)
        
        // Annuler la notification d'expiration
        await cancelExpirationNotification(for: id)
        
        logger.log("Item supprimé définitivement", level: .warning, category: .storage)
    }
    
    /// Vide complètement la poubelle
    func emptyTrash() async throws {
        logger.log("Vidage complet de la poubelle", level: .warning, category: .storage)
        
        let items = try await listTrashItems()
        
        for item in items {
            try await permanentDelete(id: item.id)
        }
        
        logger.log("Poubelle vidée: \(items.count) items supprimés", level: .warning, category: .storage)
    }
    
    // MARK: - Listing
    
    /// Liste tous les items dans la poubelle
    func listTrashItems() async throws -> [TrashItem] {
        logger.log("Liste des items en poubelle", level: .debug, category: .storage)
        
        let trashIDs = try await fileStorage.listTrashIDs()
        var trashItems: [TrashItem] = []
        
        let fileManager = FileManager.default
        let trashDir = try getTrashDirectory()
        
        for id in trashIDs {
            let metadataURL = trashDir.appendingPathComponent("\(id.uuidString).meta")
            
            if let metadataData = try? Data(contentsOf: metadataURL),
               let metadata = try? JSONDecoder().decode(TrashMetadata.self, from: metadataData) {
                
                let daysRemaining = calculateDaysRemaining(from: metadata.expirationDate)
                
                let trashItem = TrashItem(
                    id: metadata.originalID,
                    deletedDate: metadata.deletedDate,
                    expirationDate: metadata.expirationDate,
                    daysRemaining: daysRemaining
                )
                
                trashItems.append(trashItem)
            }
        }
        
        // Trier par date de suppression (plus récents en premier)
        trashItems.sort { $0.deletedDate > $1.deletedDate }
        
        logger.log("\(trashItems.count) items en poubelle", level: .debug, category: .storage)
        return trashItems
    }
    
    /// Vérifie si un item est dans la poubelle
    func isInTrash(id: UUID) async throws -> Bool {
        let trashIDs = try await fileStorage.listTrashIDs()
        return trashIDs.contains(id)
    }
    
    // MARK: - Automatic Cleanup
    
    /// Nettoie automatiquement les items expirés
    func cleanupExpiredItems() async throws {
        logger.log("Nettoyage automatique des items expirés", level: .info, category: .storage)
        
        try await fileStorage.cleanExpiredTrash()
        
        logger.log("Nettoyage automatique terminé", level: .info, category: .storage)
    }
    
    /// Planifie le nettoyage automatique périodique
    private func scheduleAutomaticCleanup() async {
        logger.log("Planification nettoyage automatique", level: .info, category: .storage)
        
        // Vérifier et nettoyer toutes les 24 heures
        Task {
            while true {
                try? await Task.sleep(nanoseconds: UInt64(cleanupCheckInterval * 1_000_000_000))
                try? await cleanupExpiredItems()
            }
        }
    }
    
    // MARK: - Notifications
    
    /// Planifie une notification d'expiration
    private func scheduleExpirationNotification<T: SecretItemProtocol>(for item: T) async {
        let expirationDate = Date().addingTimeInterval(TimeInterval(retentionDays * 24 * 60 * 60))
        
        // Notification 7 jours avant expiration
        let warningDate = expirationDate.addingTimeInterval(-7 * 24 * 60 * 60)
        
        let content = UNMutableNotificationContent()
        content.title = "Item bientôt supprimé définitivement"
        content.body = "\"\(item.title)\" sera supprimé définitivement dans 7 jours."
        content.sound = .default
        content.categoryIdentifier = "TRASH_EXPIRATION"
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: warningDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "trash_\(item.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            logger.log("Notification d'expiration planifiée", level: .debug, category: .system)
        } catch {
            logger.log("Erreur planification notification: \(error)", level: .warning, category: .system)
        }
    }
    
    /// Annule la notification d'expiration
    private func cancelExpirationNotification(for id: UUID) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["trash_\(id.uuidString)"])
        logger.log("Notification d'expiration annulée", level: .debug, category: .system)
    }
    
    // MARK: - Helpers
    
    /// Calcule le nombre de jours restants avant expiration
    private func calculateDaysRemaining(from expirationDate: Date) -> Int {
        let now = Date()
        let timeInterval = expirationDate.timeIntervalSince(now)
        let days = Int(timeInterval / (24 * 60 * 60))
        return max(0, days)
    }
    
    /// Récupère le répertoire de la poubelle
    private func getTrashDirectory() throws -> URL {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appSupport.appendingPathComponent("SilentKey/Trash")
    }
}

// MARK: - Supporting Types

/// Représente un item dans la poubelle
public struct TrashItem: Identifiable {
    let id: UUID
    let deletedDate: Date
    let expirationDate: Date
    let daysRemaining: Int
    
    var isExpired: Bool {
        return daysRemaining <= 0
    }
    
    var isExpiringSoon: Bool {
        return daysRemaining <= 7 && daysRemaining > 0
    }
}

// MARK: - Trash Errors

public enum TrashError: LocalizedError {
    case itemNotInTrash
    case itemAlreadyExpired
    case restoreConflict
    
    var errorDescription: String? {
        switch self {
        case .itemNotInTrash:
            return "L'item n'est pas dans la poubelle."
        case .itemAlreadyExpired:
            return "L'item a déjà expiré et a été supprimé."
        case .restoreConflict:
            return "Conflit lors de la restauration. Un item avec le même nom existe déjà."
        }
    }
}
