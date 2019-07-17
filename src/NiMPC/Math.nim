import SecretSharing
import bigints

proc `+`*(a: Secret, b: Secret): Secret =
  Secret(share: a.share + b.share)
