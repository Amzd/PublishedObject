import XCTest
import Combine
@testable import PublishedObject

class Outer: ObservableObject {
    @PublishedObject var innerPublishedObject: Inner
    @Published var innerPublished: Inner

    init(_ value: Int) {
        self.innerPublishedObject = Inner(value)
        self.innerPublished = Inner(value)
    }
}

class Inner: ObservableObject {
    @Published var value: Int

    init(_ int: Int) {
        self.value = int
    }
}

final class PublishedObjectTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    
    func testObjectWillChange() throws {
        let outer = Outer(1)
        
        // Setting property on Outer (This will send an update with either @Published or @PublishedObject)

        let exp1 = XCTestExpectation(description: "outer.objectWillChange will be called")
        outer.objectWillChange.first().sink { exp1.fulfill() } .store(in: &cancellables)
        outer.innerPublishedObject = Inner(2)
        wait(for: [exp1], timeout: 0.1)
        
        let exp2 = XCTestExpectation(description: "outer.objectWillChange will be called")
        outer.objectWillChange.first().sink { exp2.fulfill() } .store(in: &cancellables)
        outer.innerPublished = Inner(2)
        wait(for: [exp2], timeout: 0.1)

        // Setting property on Inner (This will only send an update when using @PublishedObject)
        
        let exp3 = XCTestExpectation(description: "outer.objectWillChange will be called")
        outer.objectWillChange.first().sink { exp3.fulfill() } .store(in: &cancellables)
        outer.innerPublishedObject.value = 3
        wait(for: [exp3], timeout: 0.1)
        
        let exp4 = XCTestExpectation(description: "outer.objectWillChange will NOT be called")
        exp4.isInverted = true
        outer.objectWillChange.first().sink { exp4.fulfill() } .store(in: &cancellables)
        outer.innerPublished.value = 3
        wait(for: [exp4], timeout: 0.1)
    }
    
    func testProjectedValue() throws {
        let outer = Outer(1)
        
        // Initial value
        
        let exp0 = XCTestExpectation(description: "projectedValue will be called")
        outer.$innerPublishedObject.first().sink { inner in
            if inner.value == 1 {
                exp0.fulfill()
            }
        }.store(in: &cancellables)
        wait(for: [exp0], timeout: 0.1)
        
        let exp1 = XCTestExpectation(description: "projectedValue will be called")
        outer.$innerPublished.first().sink { inner in
            if inner.value == 1 {
                exp1.fulfill()
            }
        }.store(in: &cancellables)
        wait(for: [exp1], timeout: 0.1)
        
        
        // Setting property on Outer (This will send an update with either @Published or @PublishedObject)
        
        let exp2 = XCTestExpectation(description: "projectedValue will be called")
        outer.$innerPublishedObject.dropFirst().first().sink { inner in
            if inner.value == 2 {
                exp2.fulfill()
            }
        }.store(in: &cancellables)
        outer.innerPublishedObject = Inner(2)
        wait(for: [exp2], timeout: 0.1)
        
        let exp3 = XCTestExpectation(description: "projectedValue will be called")
        outer.$innerPublished.dropFirst().first().sink { inner in
            if inner.value == 2 {
                exp3.fulfill()
            }
        }.store(in: &cancellables)
        outer.innerPublished = Inner(2)
        wait(for: [exp3], timeout: 0.1)

        // Setting property on Inner (This will only send an update when using @PublishedObject)
        
        let exp4 = XCTestExpectation(description: "projectedValue will be called")
        outer.$innerPublishedObject.dropFirst().first().sink { inner in
            if inner.value == 3 {
                exp4.fulfill()
            }
        }.store(in: &cancellables)
        outer.innerPublishedObject.value = 3
        wait(for: [exp4], timeout: 0.1)
        
        let exp5 = XCTestExpectation(description: "projectedValue will NOT be called")
        exp5.isInverted = true
        outer.$innerPublished.dropFirst().first().sink { inner in
            if inner.value == 3 {
                exp5.fulfill()
            }
        }.store(in: &cancellables)
        outer.innerPublished.value = 3
        wait(for: [exp5], timeout: 0.1)
    }

    static var allTests = [
        ("testObjectWillChange", testObjectWillChange),
        ("testProjectedValue", testProjectedValue),
    ]
}
