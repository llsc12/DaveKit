import libdave

class DaveSession {
    private let sessionHandle: DAVESessionHandle
    init() {
        sessionHandle = daveSessionCreate(nil, nil, { _, _, _ in }, nil);
    }

    deinit {
        daveSessionDestroy(self.sessionHandle)
    }

    func getKeyRatchet(userId: String) -> KeyRatchet {
        KeyRatchet(handle: daveSessionGetKeyRatchet(self.sessionHandle, userId))
    }

    func reset() {
        daveSessionReset(self.sessionHandle)
    }
}