import unittest
import NiMPC/Parties/Local
import NiMPC/Parties/Envelopes
import NiMPC/Parties/Encryption
import NiMPC/Parties/CheckEnvelope

suite "check envelope":

  var party, peer: LocalParty
  var envelope: SealedEnvelope

  setup:
    party = newLocalParty()
    peer = newLocalParty()
    party.peers.add(peer)
    envelope = peer.encrypt(Envelope(
      senderId: peer.id,
      recipientId: party.id,
      message: "some message"
    ))

  test "check whether recipient and sender are ok":
    check party.checkEnvelope(envelope)

  test "do not accept wrong sender":
    let wrong = newLocalParty()

    let envelope = wrong.encrypt(Envelope(
      senderId: wrong.id,
      recipientId: party.id,
      message: "some message"
    ))

    check party.checkEnvelope(envelope) == false

  test "do not accept wrong recipient":
    let wrong = newLocalParty()

    let envelope = peer.encrypt(Envelope(
      senderId: peer.id,
      recipientId: wrong.id,
      message: "some message"
    ))

    check party.checkEnvelope(envelope) == false
