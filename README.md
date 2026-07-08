# EOS Job Summary — Full-Stack Challenge

A FastAPI backend and a Flutter (BLoC/Cubit) mobile app implementing the Job Summary feature. See [CHALLENGE.md](CHALLENGE.md) for the full brief and setup instructions.

## Note

I kept all job and region state in a single `JobsCubit` so the region filter can load independently of the jobs and stays populated across reloads, which was enough for a single screen. API failures (non-200 responses and connection errors) are converted into a typed exception with a readable message that the UI renders as an error state with a retry button. I treated the in-memory mock as representative but not production-scale, so I kept filtering on the server and left out auth and pagination; with more time I'd invest more in the UI/UX and split regions into their own cubit to give the state layer a cleaner, more modular foundation that future features could slot into.

## Quick start

```bash
# Backend  (Python 3.13 recommended)
cd backend && python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload      # http://localhost:8000/docs
pytest

# Mobile
cd mobile && flutter pub get
flutter test
flutter run                        # Android emulator: add --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```
