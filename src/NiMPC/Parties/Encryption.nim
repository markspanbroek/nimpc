import Local
import Envelopes
import sysrandom
import monocypher

proc encrypt*(sender: LocalParty, envelope: Envelope): SealedEnvelope =
  assert(sender.id == envelope.senderId)

  let key = sender.peerEncryptionKey(envelope.recipientId)
  defer: crypto_wipe(key)

  let plaintext = cast[seq[byte]](envelope.message)
  let nonce = getRandomBytes(sizeof(Nonce))
  let (mac, ciphertext) = crypto_lock(key, nonce, plaintext)

  result.senderId = envelope.senderId
  result.recipientId = envelope.recipientId
  result.ciphertext = ciphertext
  result.mac = mac
  result.nonce = nonce

proc decrypt*(recipient: LocalParty, sealed: SealedEnvelope): Envelope =
  let key  = recipient.peerEncryptionKey(sealed.senderId)
  defer: crypto_wipe(key)

  let nonce = sealed.nonce
  let mac = sealed.mac
  let ciphertext = sealed.ciphertext
  let decrypted = crypto_unlock(key, nonce, mac, ciphertext)

  result.senderId = sealed.senderId
  result.recipientId = sealed.recipientId
  result.message = cast[string](decrypted)

