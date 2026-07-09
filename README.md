# Vitala 🩺

1:1 video consultations demo — built to showcase **Flutter + Agora** end to
end: room codes, secure server-signed tokens, and real-time video running in
production.

**Live demo:** [vitala.luisdelatorre.dev](https://vitala.luisdelatorre.dev) · *rooms reset nightly*

## What it does

- **Create a room** and get a shareable code like `VIT-4F2K`
- **Join from any browser or Android device** — no sign-up, no install
- 1:1 real-time video with mute, camera toggle, camera switch and hang-up
- Try it yourself: open the demo on your laptop, create a room, then join
  from your phone with the code — that's the whole pitch

## Architecture

```
Flutter UI  (Android · Web · iOS-ready)
     │
     │  HTTP (room codes)                 WebRTC (media)
     ▼                                        ▲
Cloud Functions (TypeScript)  ──── signs ───► Agora RTC
     ▼                        RTC tokens
Firestore (rooms) ── rules locked down: no client access
```

### Decisions worth reading

- **Tokens are signed server-side.** The Agora App Certificate never leaves a
  Cloud Function secret: the client asks `getRtcToken` for a short-lived token
  bound to a room code and uid. No certificate in the client, no "testing
  mode" shortcuts.
- **Rooms are validated before any token is issued** — a token for a
  non-existent room is a clean `404`, not a silent join.
- **Firestore is closed** (`allow read, write: if false`): the only door to
  data is the functions layer. Same zero-attack-surface pattern as my other
  demos.
- **Sandbox by design:** a scheduled function wipes rooms nightly, so the
  demo always starts fresh.

### Battle scar worth knowing (Flutter Web + Agora)

The `agora_rtc_engine` web target needs Agora's iris runtime loaded as a
separate `<script>` in `web/index.html` — it ships inside the binary on
mobile, but on web you bring it yourself. Symptom if you forget:
`Cannot read properties of undefined (reading 'createIrisApiEngine')`.

## Stack

Flutter · agora_rtc_engine · permission_handler · google_fonts · Firebase
(Cloud Functions/TS, Firestore, Hosting) · GitHub Actions (auto-deploy on
merge)

## Project layout

```
lib/
├── data/       API client (rooms + tokens)
├── screens/    home, call (remote view + local PiP + controls)
└── theme/      Vitala palette & typography
backend/
└── functions/  createRoom, getRtcToken, nightly resetDemo
```

## Run it

```bash
flutter pub get
flutter run -d chrome     # web
flutter run               # Android emulator/device
```

Backend (needs your own Firebase project + Agora project):

```bash
npx firebase-tools functions:secrets:set AGORA_CERT   # your App Certificate
npx firebase-tools deploy --only functions,firestore:rules
```

---

Built by [Luis Alberto De La Torre](https://luisdelatorre.dev) — Senior
Full-Stack & Mobile developer · [more projects](https://luisdelatorre.dev/proyectos)
