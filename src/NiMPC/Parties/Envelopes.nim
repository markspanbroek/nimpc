import json
import sysrandom
import monocypher
import HexString
import Identity
import Basics
import Local

type
  Envelope* = object
    senderId*: Identity
    receiverId*: Identity
    message*: string
  SealedEnvelope* = object
    senderId*: Identity
    receiverId*: Identity
    nonce*: Nonce
    mac*: Mac
    ciphertext*: seq[byte]

proc parseEnvelope*(s: string): Envelope =
  let json = parseJson(s)
  result.message = json["message"].getStr()
  result.senderId = parseIdentity(json["sender"].getStr())
  result.receiverId = parseIdentity(json["receiver"].getStr())

proc checkSenderId(party: Party, senderId: Identity): bool =
  try:
    discard party.peers[senderId]
    return true
  except IndexError:
    return false

proc checkReceiverId(party: Party, receiverId: Identity): bool =
  return party.id == receiverId

proc checkEnvelope*(party: Party, envelope: Envelope): bool =
  return
    party.checkSenderId(envelope.senderId) and
    party.checkReceiverId(envelope.receiverId)

proc `$`*(envelope: Envelope): string =
  $ %*{
    "message": envelope.message,
    "sender": $envelope.senderId,
    "receiver": $envelope.receiverId
  }

proc encrypt*(sender: LocalParty, envelope: Envelope): SealedEnvelope =
  assert(sender.id == envelope.senderId)

  let key = crypto_key_exchange(sender.secretKey, Key(envelope.receiverId))
  defer: crypto_wipe(key)

  let plaintext = cast[seq[byte]](envelope.message)
  let nonce = getRandomBytes(sizeof(Nonce))
  let (mac, ciphertext) = crypto_lock(key, nonce, plaintext)

  result.senderId = envelope.senderId
  result.receiverId = envelope.receiverId
  result.ciphertext = ciphertext
  result.mac = mac
  result.nonce = nonce

proc decrypt*(receiver: LocalParty, sealed: SealedEnvelope): Envelope =
  let key = crypto_key_exchange(receiver.secretKey, Key(sealed.senderId))
  defer: crypto_wipe(key)

  let nonce = sealed.nonce
  let mac = sealed.mac
  let ciphertext = sealed.ciphertext
  let decrypted = crypto_unlock(key, nonce, mac, ciphertext)

  result.senderId = sealed.senderId
  result.receiverId = sealed.receiverId
  result.message = cast[string](decrypted)

proc `$`*(sealed: SealedEnvelope): string =
  $ %*{
    "sender": $sealed.senderId,
    "receiver": $sealed.receiverId,
    "nonce": hex sealed.nonce,
    "mac": hex sealed.mac,
    "ciphertext": hex sealed.ciphertext
  }
