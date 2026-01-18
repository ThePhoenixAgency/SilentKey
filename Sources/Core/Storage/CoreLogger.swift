//
//  CoreLogger.swift
//  SilentKey
//
//  Simple logger pour le module Core
//

import Foundation
import os.log

/// Logger simple pour le module Core
public class Logger {
    public static let shared = Logger()
    
    public enum Level {
        case debug, info, warning, error
    }
    
    public enum Category {
        case storage, security, encryption, general, system
    }
    
    private init() {}
    
    /// Enregistre un message de log
    public func log(_ message: String, level: Level, category: Category) {
        let logger = os.Logger(subsystem: "com.silentkey.core", category: "\(category)")
        switch level {
        case .debug:
            logger.debug("\(message)")
        case .info:
            logger.info("\(message)")
        case .warning:
            logger.warning("\(message)")
        case .error:
            logger.error("\(message)")
        }
    }
}
