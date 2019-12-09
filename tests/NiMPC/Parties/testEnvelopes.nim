import unittest
import json
import NiMPC/Parties/HexString
import NiMPC/Parties/Local
import NiMPC/Parties/Encryption
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
      recipientId: party.id,
      message: "some message"
    )

  test "can be serialized to json":
    check $envelope == $ %*{
      "message": envelope.message,
      "sender": $envelope.senderId,
      "recipient": $envelope.recipientId
    }

  test "raises error when message is missing":
    let wrong = %*{
      "sender": $peer.id,
      "recipient": $party.id
    }

    expect ValueError:
      discard parseEnvelope($wrong)

  test "raises error when sender is missing":
    let wrong = %*{
      "message": "some message",
      "recipient": $party.id
    }

    expect ValueError:
      discard parseEnvelope($wrong)

  test "raises error when recipient is missing":
    let wrong = %*{
      "message": "some message",
      "sender": $peer.id
    }

    expect ValueError:
      discard parseEnvelope($wrong)

  test "sealed envelope can be serialized to json":
    let sealed = peer.encrypt(envelope)
    check $sealed == $ %*{
      "sender": $sealed.senderId,
      "recipient": $sealed.recipientId,
      "nonce": hex sealed.nonce,
      "mac": hex sealed.mac,
      "ciphertext": hex sealed.ciphertext
    }

  test "parses a sealed envelope":
    let sealed = peer.encrypt(envelope)
    check parseSealedEnvelope($sealed) == sealed

  test "parsing fails when field is wrong":
    let sealed = peer.encrypt(envelope)
    for field in ["sender", "recipient", "nonce", "mac", "ciphertext"]:
      var json = parseJson($sealed)
      json[field] = %"wrong"
      expect ValueError:
        discard parseSealedEnvelope($json)

# TODO: remove code for serializing/deserializing plain Envelopes
