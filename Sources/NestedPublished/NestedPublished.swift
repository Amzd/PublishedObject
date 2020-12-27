import Combine

/// Just like @Published this sends willSet events to the enclosing ObservableObject's ObjectWillChangePublisher
/// but unlike @Published it also sends the wrapped value's published changes on to the enclosing ObservableObject
@propertyWrapper @available(iOS 13.0, *)
public struct NestedPublished<Value: ObservableObject> where Value.ObjectWillChangePublisher == ObservableObjectPublisher {

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
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, NestedPublished>
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

    private let parent = Holder()
    private var cancellable: AnyCancellable?
    private class Holder {
        var objectWillChange: (() -> Void)?
        init() {}
    }
    
    private mutating func setParent<Parent: ObservableObject>(_ parentObject: Parent) where Parent.ObjectWillChangePublisher == ObservableObjectPublisher {
        guard parent.objectWillChange == nil else { return }
        parent.objectWillChange = { [weak parentObject] in
            parentObject?.objectWillChange.send()
        }
    }
    
    private mutating func startListening(to wrappedValue: Value) {
        cancellable = wrappedValue.objectWillChange.sink { [parent] in
            parent.objectWillChange?()
        }
    }
}

/// Force NestedPublished when using ObservableObjects
@available(iOS 13.0, *)
extension Published where Value: ObservableObject {
    public init(wrappedValue: Value) {
        fatalError("Use NestedPublished with ObservableObjects")
    }
}
