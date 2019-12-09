import unittest
import json
import monocypher
import NiMPC/Parties/HexString
import NiMPC/Parties/Local
import NiMPC/Parties/Envelopes

suite "envelopes":

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

  test "can be serialized to json":
    check $envelope == $ %*{
      "message": envelope.message,
      "sender": $envelope.senderId,
      "receiver": $envelope.receiverId
    }

  test "check whether receiver and sender are ok":
    check party.checkEnvelope(envelope)

  test "do not accept wrong sender":
    let wrong = newLocalParty()

    let envelope = Envelope(
      senderId: wrong.id,
      receiverId: party.id,
      message: "some message"
    )

    check party.checkEnvelope(envelope) == false

  test "do not accept wrong receiver":
    let wrong = newLocalParty()

    let envelope = Envelope(
      senderId: peer.id,
      receiverId: wrong.id,
      message: "some message"
    )

    check party.checkEnvelope(envelope) == false

  test "raises error when message is missing":
    let wrong = %*{
      "sender": $peer.id,
      "receiver": $party.id
    }

    expect ValueError:
      discard parseEnvelope($wrong)

  test "raises error when sender is missing":
    let wrong = %*{
      "message": "some message",
      "receiver": $party.id
    }

    expect ValueError:
      discard parseEnvelope($wrong)

  test "raises error when receiver is missing":
    let wrong = %*{
      "message": "some message",
      "sender": $peer.id
    }

    expect ValueError:
      discard parseEnvelope($wrong)

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

  test "sealed envelope can be serialized to json":
    let sealed = peer.encrypt(envelope)
    check $sealed == $ %*{
      "sender": $sealed.senderId,
      "receiver": $sealed.receiverId,
      "nonce": hex sealed.nonce,
      "mac": hex sealed.mac,
      "ciphertext": hex sealed.ciphertext
    }

  test "parses a sealed envelope":
    let sealed = peer.encrypt(envelope)
    check parseSealedEnvelope($sealed) == sealed

  test "parsing fails when field is wrong":
    let sealed = peer.encrypt(envelope)
    for field in ["sender", "receiver", "nonce", "mac", "ciphertext"]:
      var json = parseJson($sealed)
      json[field] = %"wrong"
      expect ValueError:
        discard parseSealedEnvelope($json)

