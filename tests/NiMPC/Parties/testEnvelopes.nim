import unittest
import json
import NiMPC/Parties/Local
import NiMPC/Parties/Envelopes

suite "envelopes":

  var party, peer: Party

  setup:
    party = newLocalParty()
    peer = newLocalParty()
    party.peers.add(peer)

  test "check whether receiver and sender are ok":
    let envelope = Envelope(
      senderId: peer.id,
      receiverId: party.id,
      message: "some message"
    )

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
