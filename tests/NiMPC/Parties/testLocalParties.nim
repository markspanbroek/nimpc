import unittest
import monocypher
import NiMPC/Parties/Basics
import NiMPC/Parties/Local

suite "local parties":

  test "can be created":
    check newLocalParty() != nil

  test "wipe their secret key when destroyed":
    var secretKeyPtr: ptr Key
    block:
      let party = newLocalParty()
      defer: party.destroy()
      secretKeyPtr = addr party.secretKey
    var empty: Key
    check secretKeyPtr[] == empty

  test "refer to their peers by id":
    let party, peer1, peer2: Party = newLocalParty()
    party.peers.add([peer1, peer2])

    check party.peers[peer1.id] == peer1
    check party.peers[peer2.id] == peer2

  test "raise IndexError when a peer can not be found":
    let party, peer1, peer2: Party = newLocalParty()
    party.peers.add(peer1)
    expect IndexError:
      discard party.peers[peer2.id]
