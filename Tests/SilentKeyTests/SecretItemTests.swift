//
//  SecretItemTests.swift
//  SilentKeyTests
//
//  Tests complets pour SecretItem avec tous les cas limites
//

import XCTest
@testable import SilentKeyApp

final class SecretItemTests: XCTestCase {
    
    // MARK: - Tests de création basique
    
    func testCreateBasicSecret() {
        let secret = SecretItem(
            name: "Test Secret",
            category: .apiKey,
            value: "test_value_123"
        )
        
        XCTAssertEqual(secret.name, "Test Secret")
        XCTAssertEqual(secret.category, .apiKey)
        XCTAssertEqual(secret.value, "test_value_123")
        XCTAssertFalse(secret.isFavorite)
        XCTAssertNil(secret.notes)
    }
    
    // MARK: - Tests des cas limites - Noms
    
    func testEmptyName() {
        let secret = SecretItem(
            name: "",
            category: .apiKey,
            value: "test"
        )
        XCTAssertEqual(secret.name, "")
    }
    
    func testVeryLongName() {
        let longName = String(repeating: "a", count: 10000)
        let secret = SecretItem(
            name: longName,
            category: .apiKey,
            value: "test"
        )
        XCTAssertEqual(secret.name.count, 10000)
    }
    
    func testNameWithSpecialCharacters() {
        let specialName = "Test!@#$%^&*()_+-=[]{}|;':,.<>?/~`"
        let secret = SecretItem(
            name: specialName,
            category: .apiKey,
            value: "test"
        )
        XCTAssertEqual(secret.name, specialName)
    }
    
    func testNameWithEmojis() {
        let emojiName = "🔐 Test Secret 🔑"
        let secret = SecretItem(
            name: emojiName,
            category: .apiKey,
            value: "test"
        )
        XCTAssertEqual(secret.name, emojiName)
    }
    
    func testNameWithUnicodeCharacters() {
        let unicodeName = "测试秘密 тест секрет 🇫🇷"
        let secret = SecretItem(
            name: unicodeName,
            category: .apiKey,
            value: "test"
        )
        XCTAssertEqual(secret.name, unicodeName)
    }
    
    func testNameWithNewlines() {
        let nameWithNewlines = "Test\nSecret\nName"
        let secret = SecretItem(
            name: nameWithNewlines,
            category: .apiKey,
            value: "test"
        )
        XCTAssertEqual(secret.name, nameWithNewlines)
    }
    
    func testNameWithOnlyWhitespace() {
        let whitespace = "     "
        let secret = SecretItem(
            name: whitespace,
            category: .apiKey,
            value: "test"
        )
        XCTAssertEqual(secret.name, whitespace)
    }
    
    // MARK: - Tests des cas limites - Valeurs
    
    func testEmptyValue() {
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: ""
        )
        XCTAssertEqual(secret.value, "")
    }
    
    func testVeryLargeValue() {
        // Test avec 1 MB de données
        let largeValue = String(repeating: "x", count: 1_000_000)
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: largeValue
        )
        XCTAssertEqual(secret.value.count, 1_000_000)
    }
    
    func testValueWithBinaryData() {
        let binaryValue = "\u{0000}\u{0001}\u{0002}\u{0003}"
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: binaryValue
        )
        XCTAssertEqual(secret.value, binaryValue)
    }
    
    func testValueWithJSON() {
        let jsonValue = "{\"key\":\"value\",\"nested\":{\"data\":123}}"
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: jsonValue
        )
        XCTAssertEqual(secret.value, jsonValue)
    }
    
    func testValueWithBase64() {
        let base64Value = "SGVsbG8gV29ybGQhCg=="
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: base64Value
        )
        XCTAssertEqual(secret.value, base64Value)
    }
    
    // MARK: - Tests des catégories
    
    func testAllCategoryTypes() {
        let categories: [SecretCategory] = [
            .apiKey, .password, .token, .sshKey,
            .certificate, .credential, .other
        ]
        
        for category in categories {
            let secret = SecretItem(
                name: "Test",
                category: category,
                value: "test"
            )
            XCTAssertEqual(secret.category, category)
        }
    }
    
    // MARK: - Tests des tags
    
    func testEmptyTags() {
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: "test",
            tags: []
        )
        XCTAssertTrue(secret.tags.isEmpty)
    }
    
    func testMultipleTags() {
        let tags = ["production", "critical", "aws", "api"]
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: "test",
            tags: tags
        )
        XCTAssertEqual(secret.tags.count, 4)
        XCTAssertEqual(secret.tags, tags)
    }
    
    func testDuplicateTags() {
        let tags = ["test", "test", "production"]
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: "test",
            tags: tags
        )
        // Devrait conserver les doublons si non filtré
        XCTAssertEqual(secret.tags.count, 3)
    }
    
    func testVeryLongTag() {
        let longTag = String(repeating: "a", count: 1000)
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: "test",
            tags: [longTag]
        )
        XCTAssertEqual(secret.tags.first?.count, 1000)
    }
    
    func testTagsWithSpecialCharacters() {
        let specialTags = ["tag-1", "tag_2", "tag.3", "tag@4"]
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: "test",
            tags: specialTags
        )
        XCTAssertEqual(secret.tags, specialTags)
    }
    
    // MARK: - Tests des notes
    
    func testNilNotes() {
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: "test",
            notes: nil
        )
        XCTAssertNil(secret.notes)
    }
    
    func testEmptyNotes() {
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: "test",
            notes: ""
        )
        XCTAssertEqual(secret.notes, "")
    }
    
    func testVeryLongNotes() {
        let longNotes = String(repeating: "Note ", count: 10000)
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: "test",
            notes: longNotes
        )
        XCTAssertEqual(secret.notes?.count, longNotes.count)
    }
    
    func testNotesWithMarkdown() {
        let markdownNotes = """# Title\n\n## Subtitle\n\n- Item 1\n- Item 2\n\n**Bold** and *italic*"""
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: "test",
            notes: markdownNotes
        )
        XCTAssertEqual(secret.notes, markdownNotes)
    }
    
    // MARK: - Tests de modification
    
    func testToggleFavorite() {
        var secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: "test"
        )
        
        XCTAssertFalse(secret.isFavorite)
        secret.isFavorite = true
        XCTAssertTrue(secret.isFavorite)
        secret.isFavorite = false
        XCTAssertFalse(secret.isFavorite)
    }
    
    func testUpdateTimestamps() {
        let secret = SecretItem(
            name: "Test",
            category: .apiKey,
            value: "test"
        )
        
        XCTAssertNotNil(secret.createdAt)
        XCTAssertNotNil(secret.modifiedAt)
        
        // Les dates devraient être très proches
        let timeDifference = secret.modifiedAt.timeIntervalSince(secret.createdAt)
        XCTAssertLessThan(timeDifference, 1.0)
    }
    
    // MARK: - Tests d'ID
    
    func testUniqueIDs() {
        let secret1 = SecretItem(name: "Test1", category: .apiKey, value: "test1")
        let secret2 = SecretItem(name: "Test2", category: .apiKey, value: "test2")
        
        XCTAssertNotEqual(secret1.id, secret2.id)
    }
    
    func testIDPersistence() {
        let secret = SecretItem(name: "Test", category: .apiKey, value: "test")
        let originalID = secret.id
        
        // L'ID ne devrait pas changer
        XCTAssertEqual(secret.id, originalID)
    }
    
    // MARK: - Tests de copie
    
    func testCopySecret() {
        let original = SecretItem(
            name: "Original",
            category: .apiKey,
            value: "test_value",
            tags: ["tag1", "tag2"],
            notes: "Some notes"
        )
        
        var copy = original
        copy.name = "Copy"
        
        // Les IDs devraient être différents si c'est une vraie copie
        // ou identiques si c'est une référence
        XCTAssertNotEqual(original.name, copy.name)
    }
    
    // MARK: - Tests de performance
    
    func testCreationPerformance() {
        measure {
            for i in 0..<1000 {
                _ = SecretItem(
                    name: "Secret \(i)",
                    category: .apiKey,
                    value: "value_\(i)"
                )
            }
        }
    }
    
    func testLargeDataHandling() {
        measure {
            let largeValue = String(repeating: "x", count: 100_000)
            _ = SecretItem(
                name: "Large Secret",
                category: .apiKey,
                value: largeValue
            )
        }
    }
}
