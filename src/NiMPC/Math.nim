import SecretSharing

proc `+`*(a: Secret, b: Secret): Secret =
  assert a.party == b.party
  result = Secret(party: a.party, share: a.share + b.share)
