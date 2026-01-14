import libdave

class Encryptor {
    private let encryptorHandle: DAVEEncryptorHandle

    init() {
        self.encryptorHandle = daveEncryptorCreate()
    }

    deinit {
        daveEncryptorDestroy(self.encryptorHandle)
    }

    func setKeyRatchet(keyRatchet: KeyRatchet) {
        daveEncryptorSetKeyRatchet(self.encryptorHandle, keyRatchet.handle)
    }

    func setPassthroughMode(enabled: Bool) {
        daveEncryptorSetPassthroughMode(self.encryptorHandle, enabled)
    }
}