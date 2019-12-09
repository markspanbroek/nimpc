import json
import monocypher
import HexString
import Identity

type
  Envelope* = object
    senderId*: Identity
    recipientId*: Identity
    message*: string
  SealedEnvelope* = object
    senderId*: Identity
    recipientId*: Identity
    nonce*: Nonce
    mac*: Mac
    ciphertext*: seq[byte]

proc parseEnvelope*(s: string): Envelope =
  let json = parseJson(s)
  result.message = json["message"].getStr()
  result.senderId = parseIdentity(json["sender"].getStr())
  result.recipientId = parseIdentity(json["recipient"].getStr())

proc `$`*(envelope: Envelope): string =
  $ %*{
    "message": envelope.message,
    "sender": $envelope.senderId,
    "recipient": $envelope.recipientId
  }

proc `$`*(sealed: SealedEnvelope): string =
  $ %*{
    "sender": $sealed.senderId,
    "recipient": $sealed.recipientId,
    "nonce": hex sealed.nonce,
    "mac": hex sealed.mac,
    "ciphertext": hex sealed.ciphertext
  }

proc parseSealedEnvelope*(s: string): SealedEnvelope =
  let json = parseJson(s)
  result.senderId = parseIdentity(json["sender"].getStr())
  result.recipientId = parseIdentity(json["recipient"].getStr())
  result.nonce = parseHexArray(json["nonce"].getStr(), sizeof(Nonce))
  result.mac = parseHexArray(json["mac"].getStr(), sizeof(Mac))
  result.ciphertext = parseHexSeq(json["ciphertext"].getStr())
