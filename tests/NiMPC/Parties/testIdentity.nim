import unittest
import sequtils
import algorithm
import sysrandom
import monocypher
import NiMPC/Parties/Identity

suite "Identity":

  proc randomKey: Key =
    getRandomBytes(sizeof(Key))

  test "identities can be created from a public key":
    let key1, key2 = randomKey()
    check initIdentity(key1) == initIdentity(key1)
    check initIdentity(key1) != initIdentity(key2)

  test "identities can be compared using <, and <=":
    var identities = newSeqWith(10, initIdentity(randomKey()))
    sort(identities)
    check identities.allIt(it <= identities[len(identities)-1])

  test "identities are hashable":
    let key1, key2 = randomKey()
    check hash(initIdentity(key1)) == hash(initIdentity(key1))
    check hash(initIdentity(key1)) != hash(initIdentity(key2))

  test "identities expose their public keys":
    let key = randomKey()
    check initIdentity(key).publicKey == key

  test "identities can be converted to/from a string":
    let identity = initIdentity(randomKey())
    check parseIdentity($identity) == identity

  test "parsing an identity of wrong lenght raises a value error":
    expect ValueError:
      discard parseIdentity("DEADBEEF")

  test "parsing an identity string that is not hex raises a value error":
    var wrong = $initIdentity(randomKey())
    wrong[^1] = '!'
    expect ValueError:
      discard parseIdentity(wrong)
