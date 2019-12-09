import unittest
import NiMPC/Parties/Local
import NiMPC/Parties/Envelopes
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
      receiverId: party.id,
      message: "some message"
    ))

  test "check whether receiver and sender are ok":
    check party.checkEnvelope(envelope)

  test "do not accept wrong sender":
    let wrong = newLocalParty()

    let envelope = wrong.encrypt(Envelope(
      senderId: wrong.id,
      receiverId: party.id,
      message: "some message"
    ))

    check party.checkEnvelope(envelope) == false

  test "do not accept wrong receiver":
    let wrong = newLocalParty()

    let envelope = peer.encrypt(Envelope(
      senderId: peer.id,
      receiverId: wrong.id,
      message: "some message"
    ))

    check party.checkEnvelope(envelope) == false
