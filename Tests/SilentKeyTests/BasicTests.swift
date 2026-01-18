//
//  BasicTests.swift
//  SilentKeyTests
//

import XCTest
@testable import SilentKeyCore

final class BasicTests: XCTestCase {
    
    func testProjectItemCreation() {
        let project = ProjectItem(title: "Test Project")
        XCTAssertEqual(project.title, "Test Project")
        XCTAssertNotNil(project.id)
    }
    
    func testProjectItemWithTags() {
        let tags: Set<String> = ["ios", "swift"]
        let project = ProjectItem(title: "Test", tags: tags)
        XCTAssertEqual(project.tags, tags)
    }
}
