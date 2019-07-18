import SecretSharing

proc `+`*(a: Secret, b: Secret): Secret =
  Secret(party: a.party, share: a.share + b.share)
