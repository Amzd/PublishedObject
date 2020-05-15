class Outer: ObservableObject {
    @NestedPublished var inner: Inner

    init(_ inner: Inner) {
        self.inner = inner
    }
}

class Inner: ObservableObject {
    @Published var value: Int

    init(_ int: Int) {
        self.value = int
    }
}

var cancellable: AnyCancellable?
func testExample() {
    let outer = Outer(Inner(1))
    cancellable = outer.objectWillChange.sink {
        print("Outer willChange called")
    }
    print("Setting property on Outer (This will send an update with either @Published or @NestedPublished)")
    outer.inner = Inner(2)

    print("Setting property on Inner (This will only send an update with @NestedPublished)")
    outer.inner.value = 3
}