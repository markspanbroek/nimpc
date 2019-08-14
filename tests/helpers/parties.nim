template singleParty*(statements) =
  let party {.inject.} = Party()
  statements

template twoParties*(statements) =
  let party1 {.inject.}, party2 {.inject.} = Party()
  connect(party1, party2)
  statements

template threeParties*(statements) =
  let party1 {.inject.}, party2 {.inject.}, party3 {.inject.} = Party()
  connect(party1, party2, party3)
  statements
