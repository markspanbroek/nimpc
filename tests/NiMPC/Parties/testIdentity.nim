import unittest
import sequtils
import algorithm
import sysrandom
import monocypher
import NiMPC/Parties/Identity

suite "Identity":

  test "identities are unique":
    check initIdentity() != initIdentity()

  test "identities can be created from a secret key":
    let secret: Key = getRandomBytes(sizeof(Key))
    check initIdentity(secret) == initIdentity(secret)

  test "identities can be compared using <, and <=":
    var identities = newSeqWith(10, initIdentity())
    sort(identities)
    check identities.allIt(it <= identities[len(identities)-1])

  test "identities are hashable":
    check hash(initIdentity()) != hash(initIdentity())

  test "identities have secret keys":
    check initIdentity().secretKey != initIdentity().secretKey

  test "identities have public keys":
    check initIdentity().publicKey != initIdentity().publicKey

  test "after destroying an identity, its secret key is wiped":
    let identity = initIdentity()
    destroyIdentity(identity)
    var empty: Key
    check identity.secretKey == empty
