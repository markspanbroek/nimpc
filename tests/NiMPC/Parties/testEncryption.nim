import unittest
import monocypher
import NiMPC/Parties/Local
import NiMPC/Parties/Envelopes
import NiMPC/Parties/Encryption

suite "encryption":

  var party, peer: LocalParty
  var envelope: Envelope

  setup:
    party = newLocalParty()
    peer = newLocalParty()
    party.peers.add(peer)
    envelope = Envelope(
      senderId: peer.id,
      receiverId: party.id,
      message: "some message"
    )

  test "encrypts an envelope":
    let sealed = peer.encrypt(envelope)

    let key = crypto_key_exchange(party.secretKey, Key(peer.id))
    let ciphertext = sealed.ciphertext
    let mac = sealed.mac
    let nonce = sealed.nonce
    let decrypted = crypto_unlock(key, nonce, mac, ciphertext)
    check cast[string](decrypted) == "some message"

  test "refused to encrypt an envelope where the sender does not match":
    let wrong = newLocalParty()

    let envelope = Envelope(
      senderId: wrong.id,
      receiverId: party.id,
      message: "some message"
    )

    expect Exception:
      discard party.encrypt(envelope)

  test "writes correct sender and receiver on sealed envelope":
    let sealed = peer.encrypt(envelope)
    check sealed.senderId == envelope.senderId
    check sealed.receiverId == envelope.receiverId

  test "decrypts a sealed envelope":
    let sealed = peer.encrypt(envelope)
    let decrypted = party.decrypt(sealed)
    check decrypted == envelope
