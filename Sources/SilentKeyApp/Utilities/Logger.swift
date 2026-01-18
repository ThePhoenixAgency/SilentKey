//
//  Logger.swift
//  SilentKey
//
//  Système de logging professionnel avec rapports automatiques
//  Gère tous les événements, erreurs et analyse pour support utilisateur
//

import Foundation
import OSLog

#if os(macOS)
import AppKit
#endif

/// Gestionnaire centralisé de logging professionnel
/// Capture tous les événements, erreurs et métriques pour analyse et support
public final class AppLogger {
    // MARK: - Singleton
    public static let shared = AppLogger()
    
    // MARK: - Propriétés
    private let logger: Logger
    private let logFileURL: URL
    private let maxLogSize: Int = 5_000_000 // 5 MB
    private let queue = DispatchQueue(label: "com.silentkey.logger", qos: .utility)
    
    /// Configuration GitHub pour rapports automatiques
    private let githubOwner = "EthanThePhoenix38"
    private let githubRepo = "SilentKey"
    
    // MARK: - Niveaux de log
    public enum LogLevel: String {
        case debug = "[DEBUG]"
        case info = "[INFO]"
        case warning = "[WARNING]"
        case error = "[ERROR]"
        case critical = "[CRITICAL]"
        case security = "[SECURITY]"
        case performance = "[PERF]"
        case userAction = "[USER]"
    }
    
    // MARK: - Catégories
    public enum LogCategory: String {
        case encryption = "Encryption"
        case storage = "Storage"
        case ui = "UI"
        case network = "Network"
        case purchase = "Purchase"
        case authentication = "Authentication"
        case system = "System"
                case security = "Security"
    }
    
    // MARK: - Initialisation
    private init() {
        self.logger = Logger(subsystem: "com.silentkey.app", category: "main")
        
        // Créer répertoire de logs
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let logDirectory = appSupport.appendingPathComponent("SilentKey/Logs")
        
        try? FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        
        self.logFileURL = logDirectory.appendingPathComponent("app.log")
        
        // Log de démarrage
        log("Application démarrée", level: .info, category: .system)
    }
    
    // MARK: - Méthodes principales
    
    /// Enregistre un message de log
    /// - Parameters:
    ///   - message: Message à logger
    ///   - level: Niveau de criticité
    ///   - category: Catégorie du log
    ///   - file: Fichier source (automatique)
    ///   - function: Fonction source (automatique)
    ///   - line: Ligne source (automatique)
    public func log(
        _ message: String,
        level: LogLevel = .info,
        category: LogCategory = .system,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        let logMessage = "[\(timestamp)] \(level.rawValue) [\(category.rawValue)] \(fileName):\(line) \(function) - \(message)"
        
        // Log système
        switch level {
        case .debug:
            logger.debug("\(logMessage)")
        case .info, .userAction, .performance:
            logger.info("\(logMessage)")
        case .warning:
            logger.warning("\(logMessage)")
        case .error, .security:
            logger.error("\(logMessage)")
        case .critical:
            logger.critical("\(logMessage)")
        }
        
        // Écriture fichier
        writeToFile(logMessage)
        
        // Rotation si nécessaire
        rotateLogsIfNeeded()
    }
    
    /// Enregistre une erreur avec contexte complet
    public func logError(
        _ error: Error,
        context: String? = nil,
        category: LogCategory = .system,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var message = "Erreur: \(error.localizedDescription)"
        if let context = context {
            message += " | Contexte: \(context)"
        }
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }
    
    /// Génère un rapport de diagnostic complet
    public func generateDiagnosticReport() -> DiagnosticReport {
        let systemInfo = collectSystemInfo()
        let recentLogs = getRecentLogs(count: 100)
        let appMetrics = collectAppMetrics()
        
        return DiagnosticReport(
            timestamp: Date(),
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
            systemInfo: systemInfo,
            recentLogs: recentLogs,
            metrics: appMetrics
        )
    }
    
    /// Envoie un rapport automatique vers GitHub Issues
    /// - Parameters:
    ///   - title: Titre de l'issue
    ///   - includeFullLogs: Inclure logs complets (défaut: false)
    public func submitSupportReport(title: String, includeFullLogs: Bool = false) async throws {
        let report = generateDiagnosticReport()
        let body = formatReportForGitHub(report, includeFullLogs: includeFullLogs)
        
        // Note: Nécessite GitHub Personal Access Token dans Keychain
        // Pour production, utiliser un endpoint serveur intermédiaire
        let issueURL = "https://github.com/\(githubOwner)/\(githubRepo)/issues/new"
        let params = [
            "title": title,
            "body": body,
            "labels": "support,auto-generated"
        ]
        
        var urlComponents = URLComponents(string: issueURL)!
        urlComponents.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        if let url = urlComponents.url {
            #if os(macOS)
            NSWorkspace.shared.open(url)
            #endif
            log("Rapport de support généré", level: .info, category: .system)
        }
    }
    
    // MARK: - Méthodes privées
    
    private func writeToFile(_ message: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let data = (message + "\n").data(using: .utf8)!
            
            if FileManager.default.fileExists(atPath: self.logFileURL.path) {
                if let fileHandle = try? FileHandle(forWritingTo: self.logFileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    try? fileHandle.close()
                }
            } else {
                try? data.write(to: self.logFileURL)
            }
        }
    }
    
    private func rotateLogsIfNeeded() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if let attributes = try? FileManager.default.attributesOfItem(atPath: self.logFileURL.path),
               let fileSize = attributes[.size] as? Int,
               fileSize > self.maxLogSize {
                
                // Archiver ancien log
                let archiveURL = self.logFileURL.deletingPathExtension().appendingPathExtension("old.log")
                try? FileManager.default.removeItem(at: archiveURL)
                try? FileManager.default.moveItem(at: self.logFileURL, to: archiveURL)
                
                self.log("Logs rotated", level: .info, category: .system)
            }
        }
    }
    
    private func getRecentLogs(count: Int) -> [String] {
        guard let logData = try? Data(contentsOf: logFileURL),
              let logString = String(data: logData, encoding: .utf8) else {
            return []
        }
        
        let lines = logString.components(separatedBy: "\n")
        return Array(lines.suffix(count))
    }
    
    private func collectSystemInfo() -> SystemInfo {
        return SystemInfo(
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            deviceModel: getDeviceModel(),
            availableMemory: ProcessInfo.processInfo.physicalMemory,
            locale: Locale.current.identifier
        )
    }
    
    private func getDeviceModel() -> String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }
    
    private func collectAppMetrics() -> AppMetrics {
        return AppMetrics(
            launchCount: UserDefaults.standard.integer(forKey: "app.launchCount"),
            crashCount: UserDefaults.standard.integer(forKey: "app.crashCount"),
            lastLaunchDate: UserDefaults.standard.object(forKey: "app.lastLaunchDate") as? Date
        )
    }
    
    private func formatReportForGitHub(_ report: DiagnosticReport, includeFullLogs: Bool) -> String {
        var body = """
        ##Rapport de Diagnostic Automatique
        
        **Version:** \(report.appVersion) (\(report.buildNumber))
        **Date:** \(report.timestamp)
        
        ### nformations Système
        - **OS:** \(report.systemInfo.osVersion)
        - **Modèle:** \(report.systemInfo.deviceModel)
        - **Mémoire:** \(ByteCountFormatter.string(fromByteCount: Int64(report.systemInfo.availableMemory), countStyle: .memory))
        - **Locale:** \(report.systemInfo.locale)
        
        ### étriques Application
        - **Nombre de lancements:** \(report.metrics.launchCount)
        - **Crashs enregistrés:** \(report.metrics.crashCount)
        
        """
        
        if includeFullLogs {
            body += """
            
            ### 📝 Logs Récents
            ```
            \(report.recentLogs.joined(separator: "\n"))
            ```
            """
        }
        
        body += """
        
        
        ---
        *Ce rapport a été généré automatiquement par SilentKey*
        """
        
        return body
    }
}

// MARK: - Modèles de données

public struct DiagnosticReport {
    let timestamp: Date
    let appVersion: String
    let buildNumber: String
    let systemInfo: SystemInfo
    let recentLogs: [String]
    let metrics: AppMetrics
}

public struct SystemInfo {
    let osVersion: String
    let deviceModel: String
    let availableMemory: UInt64
    let locale: String
}

public struct AppMetrics {
    let launchCount: Int
    let crashCount: Int
    let lastLaunchDate: Date?
}

// MARK: - Extensions de commodité

public extension AppLogger {
    func debug(_ message: String, category: LogCategory = .system) {
        log(message, level: .debug, category: category)
    }
    
    func info(_ message: String, category: LogCategory = .system) {
        log(message, level: .info, category: category)
    }
    
    func warning(_ message: String, category: LogCategory = .system) {
        log(message, level: .warning, category: category)
    }
    
    func error(_ message: String, category: LogCategory = .system) {
        log(message, level: .error, category: category)
    }
    
    func critical(_ message: String, category: LogCategory = .system) {
        log(message, level: .critical, category: category)
    }
    
    func security(_ message: String) {
        log(message, level: .security, category: .security)
    }
    
    func performance(_ message: String) {
        log(message, level: .performance, category: .system)
    }
    
    func userAction(_ message: String, category: LogCategory = .ui) {
        log(message, level: .userAction, category: category)
    }
}
