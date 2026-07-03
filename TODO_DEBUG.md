# TODO_DEBUG (White screen / crash investigation)

## Goal
- Find why app shows white screen and then closes.

## Steps
- [ ] Add debugPrint + error logging in:
  - [ ] SplashScreen._initializeApp
  - [ ] AuthProvider.initialize
  - [ ] CustomerProvider.initialize
- [ ] Run `flutter run` and check console for last printed line before white screen/band.
- [ ] Use result to fix root cause.

