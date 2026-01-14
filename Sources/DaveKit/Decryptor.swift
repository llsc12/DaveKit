import libdave

class Decryptor {
    private let decryptorHandle: DAVEDecryptorHandle

    init() {
        self.decryptorHandle = daveDecryptorCreate()
    }

    deinit {
        daveDecryptorDestroy(self.decryptorHandle)
    }

    func transitionToKeyRatchet(keyRatchet: KeyRatchet) {
        daveDecryptorTransitionToKeyRatchet(self.decryptorHandle, keyRatchet.handle)
    }

    func transitionToPassthroughMode(enabled: Bool) {
        daveDecryptorTransitionToPassthroughMode(self.decryptorHandle, enabled)
    }
}