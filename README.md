# PublishedObject

A property wrapper that forwards the objectWillChange of the wrapped ObservableObject to the enclosing ObservableObject's objectWillChange.


Just like @Published this sends willSet events to the enclosing ObservableObject's ObjectWillChangePublisher but unlike @Published it also sends the wrapped value's published changes on to the enclosing ObservableObject.

```swift
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

func example() {
    let outer = Outer(1)
    
    // Setting property on Outer (This will send an update with either @Published or @PublishedObject)
    outer.innerPublishedObject = Inner(2) // outer.objectWillChange will be called 
    outer.innerPublished = Inner(2)       // outer.objectWillChange will be called

    // Setting property on Inner (This will only send an update when using @PublishedObject)
    outer.innerPublishedObject.value = 3  // outer.objectWillChange will be called !!!
    outer.innerPublished.value = 3        // outer.objectWillChange will NOT be called 
}
```

It's only one file so you could just copy it. Also has Swift Package Manager support.
