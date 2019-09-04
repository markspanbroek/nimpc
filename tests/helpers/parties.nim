template singleParty*(statements) =
  let party {.inject.} = LocalParty()
  statements

template twoParties*(statements) =
  let party1 {.inject.}, party2 {.inject.} = LocalParty()
  connect(party1, party2)
  statements

template threeParties*(statements) =
  let party1 {.inject.}, party2 {.inject.}, party3 {.inject.} = LocalParty()
  connect(party1, party2, party3)
  statements
