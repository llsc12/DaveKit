import CLibdave
import Foundation

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

    func setExternalSenderPackage(externalSenderPackage: Data) {
        externalSenderPackage.withUnsafeBytes { externalSenderPackage in
            let externalSenderPackage = externalSenderPackage.bindMemory(to: UInt8.self)
            daveSessionSetExternalSender(
                self.sessionHandle,
                externalSenderPackage.baseAddress!,
                externalSenderPackage.count,
            )
        }
    }

    func initialize(version: UInt16, groupId: UInt64, selfUserId: String) {
        daveSessionInit(self.sessionHandle, version, groupId, selfUserId)
    }

    func getKeyPackage() -> Data {
        var outputLength: Int = 0
        var data: UnsafeMutablePointer<UInt8>?
        daveSessionGetMarshalledKeyPackage(
            self.sessionHandle,
            &data,
            &outputLength,
        )

        return Data(bytes: data!, count: outputLength)
    }

    func getProtocolVersion() -> UInt16 {
        return daveSessionGetProtocolVersion(self.sessionHandle)
    }

    func processProposals(proposals: Data, knownUserIds: [String]) -> Data? {
//        var welcomeData: UnsafeMutablePointer<UInt8>?
//        var welcomeDataLength = 0
//        var knownUserIds = knownUserIds
//        let knownUserIdCount = knownUserIds.count
//        knownUserIds.withUnsafeMutableBytes { knownUserIds in
//            return proposals.withUnsafeBytes { proposals in
//                let proposals = proposals.bindMemory(to: UInt8.self)
//                let knownUserIds = knownUserIds.bindMemory(
//                    to: UnsafePointer<CChar>?.self)
//                return daveSessionProcessProposals(
//                    self.sessionHandle,
//                    proposals.baseAddress!,
//                    proposals.count,
//                    knownUserIds.baseAddress!,
//                    knownUserIdCount,
//                    &welcomeData,
//                    &welcomeDataLength,
//                )
//            }
//        }
//
//        if let result = welcomeData {
//            return Data(bytes: result, count: welcomeDataLength)
//        } else {
//            return nil
//        }
	  // the above handles passing swift strings badly. we should convert to
	  // cstrings before passing to the c++ libdave.
	  
		var welcomeData: UnsafeMutablePointer<UInt8>?
		var welcomeDataLength = 0

		// Allocate C strings
		var cStrings: [UnsafePointer<CChar>?] = knownUserIds.map {
			UnsafePointer(strdup($0))
		}

		defer {
			for ptr in cStrings {
				if let ptr = ptr {
					free(UnsafeMutablePointer(mutating: ptr))
				}
			}
		}

		cStrings.withUnsafeMutableBufferPointer { buffer in
			proposals.withUnsafeBytes { proposals in
				let proposals = proposals.bindMemory(to: UInt8.self)

				daveSessionProcessProposals(
					self.sessionHandle,
					proposals.baseAddress!,
					proposals.count,
					buffer.baseAddress,
					buffer.count,
					&welcomeData,
					&welcomeDataLength
				)
			}
		}

		if let welcomeData {
			return Data(bytes: welcomeData, count: welcomeDataLength)
		}
	  
	    // free the welcome data since libdave allocates it
	    if let welcomeData {
	        daveFree(welcomeData)
	    }

		return nil
    }

  func processWelcome(welcome: Data, knownUserIds: [String]) -> Welcome? {

	  var cStrings: [UnsafePointer<CChar>?] = knownUserIds.map { .init(strdup($0)) }

	  defer {
		  for ptr in cStrings {
			  if let ptr = ptr {
				  free(UnsafeMutablePointer(mutating: ptr))
			  }
		  }
	  }

	  let handle: DAVEWelcomeResultHandle? =
		  cStrings.withUnsafeMutableBufferPointer { buffer in
			  welcome.withUnsafeBytes { welcomeBytes in
				  guard let base =
					  welcomeBytes.baseAddress?.assumingMemoryBound(to: UInt8.self)
				  else { return DAVEWelcomeResultHandle(bitPattern: 0)! }


				  return daveSessionProcessWelcome(
					  self.sessionHandle,
					  base,
					  welcomeBytes.count,
					  buffer.baseAddress,
					  buffer.count
				  )
			  }
		  }

	  if let handle {
		  return Welcome(handle: handle)
	  } else {
		  return nil
	  }
  }

    func processCommit(commit: Data) -> Commit? {
        let handle = commit.withUnsafeBytes { commit in
            let commit = commit.bindMemory(to: UInt8.self)
            return daveSessionProcessCommit(
                self.sessionHandle,
                commit.baseAddress!,
                commit.count,
            )
        }

        if let handle = handle {
            return Commit(handle: handle)
        } else {
            return nil
        }
    }
}
