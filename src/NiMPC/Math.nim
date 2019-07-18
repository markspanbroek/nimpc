import SecretSharing

proc `+`*(a: Secret, b: Secret): Secret =
  Secret(share: a.share + b.share)
