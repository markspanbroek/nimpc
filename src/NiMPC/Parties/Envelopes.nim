import json
import monocypher
import HexString
import Identity

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

proc `$`*(envelope: Envelope): string =
  $ %*{
    "message": envelope.message,
    "sender": $envelope.senderId,
    "receiver": $envelope.receiverId
  }

proc `$`*(sealed: SealedEnvelope): string =
  $ %*{
    "sender": $sealed.senderId,
    "receiver": $sealed.receiverId,
    "nonce": hex sealed.nonce,
    "mac": hex sealed.mac,
    "ciphertext": hex sealed.ciphertext
  }

proc parseSealedEnvelope*(s: string): SealedEnvelope =
  let json = parseJson(s)
  result.senderId = parseIdentity(json["sender"].getStr())
  result.receiverId = parseIdentity(json["receiver"].getStr())
  result.nonce = parseHexArray(json["nonce"].getStr(), sizeof(Nonce))
  result.mac = parseHexArray(json["mac"].getStr(), sizeof(Mac))
  result.ciphertext = parseHexSeq(json["ciphertext"].getStr())
