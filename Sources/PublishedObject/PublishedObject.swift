import Combine
import Foundation

/// Just like @Published this sends willSet events to the enclosing ObservableObject's ObjectWillChangePublisher
/// but unlike @Published it also sends the wrapped value's published changes on to the enclosing ObservableObject
@propertyWrapper @available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct PublishedObject<Value: ObservableObject> where Value.ObjectWillChangePublisher == ObservableObjectPublisher {

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        self.cancellable = nil
        startListening(to: wrappedValue)
    }

    public var wrappedValue: Value {
        willSet { parent.objectWillChange?() }
        didSet { startListening(to: wrappedValue) }
    }
    
    public static subscript<EnclosingSelf: ObservableObject>(
        _enclosingInstance observed: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, PublishedObject>
    ) -> Value where EnclosingSelf.ObjectWillChangePublisher == ObservableObjectPublisher {
        get {
            observed[keyPath: storageKeyPath].setParent(observed)
            return observed[keyPath: storageKeyPath].wrappedValue
        }
        set {
            observed[keyPath: storageKeyPath].setParent(observed)
            observed[keyPath: storageKeyPath].wrappedValue = newValue
        }
    }
    
    public static subscript<EnclosingSelf: ObservableObject>(
        _enclosingInstance observed: EnclosingSelf,
        projected wrappedKeyPath: KeyPath<EnclosingSelf, Publisher>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, PublishedObject>
    ) -> Publisher where EnclosingSelf.ObjectWillChangePublisher == ObservableObjectPublisher {
        get {
            observed[keyPath: storageKeyPath].setParent(observed)
            return observed[keyPath: storageKeyPath].projectedValue
        }
    }

    private let parent = Holder()
    private var cancellable: AnyCancellable?
    private class Holder {
        var objectWillChange: (() -> Void)?
        init() {}
    }
    
    private func setParent<Parent: ObservableObject>(_ parentObject: Parent) where Parent.ObjectWillChangePublisher == ObservableObjectPublisher {
        guard parent.objectWillChange == nil else { return }
        parent.objectWillChange = { [weak parentObject] in
            parentObject?.objectWillChange.send()
        }
    }
    
    private mutating func startListening(to wrappedValue: Value) {
        let publisher = _projectedValue
        cancellable = wrappedValue.objectWillChange.sink { [parent] in
            parent.objectWillChange?()
            DispatchQueue.main.async {
                publisher.send(wrappedValue)
            }
        }
        publisher.send(wrappedValue)
    }
    
    public typealias Publisher = AnyPublisher<Value, Never>
    
    private lazy var _projectedValue = CurrentValueSubject<Value, Never>(wrappedValue)
    public var projectedValue: Publisher {
        mutating get { _projectedValue.eraseToAnyPublisher() }
    }
}

#if FORCE_PUBLISHED_OBJECT_WRAPPER
/// Force PublishedObject when using ObservableObjects
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Published where Value: ObservableObject {
    public init(wrappedValue: Value) {
        fatalError("Use PublishedObject with ObservableObjects")
    }
}
#endif
