# EOS — Full-Stack Coding Challenge

## Overview

Build a **Job Summary** feature across two projects: a FastAPI backend and a Flutter mobile frontend. Starter scaffolding and mock data are provided for both — the implementation is up to you.

---

## Setup

### Backend

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload   # API at http://localhost:8000
```

Interactive docs are available at `http://localhost:8000/docs`.

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

> **Android Emulator note:** The emulator cannot reach `localhost` on your host machine.
> Use `http://10.0.2.2:8000/api` as your base URL instead of `http://localhost:8000/api`.

---

## What's provided

### Backend (`backend/`)

| File                  | Purpose                                          |
| --------------------- | ------------------------------------------------ |
| `app/main.py`         | FastAPI app with CORS configured (do not modify) |
| `app/models.py`       | Pydantic response schema (do not modify)         |
| `app/data.py`         | In-memory mock dataset                           |
| `app/routers/jobs.py` | Incomplete router — your implementation goes here |

### Mobile (`mobile/lib/`)

| File                            | Purpose                                              |
| ------------------------------- | ---------------------------------------------------- |
| `models/job_summary.dart`       | Dart model with `fromJson` (do not modify)           |
| `mock/job_summary_mock.dart`    | Local copy of mock data matching the backend dataset (do not modify) |
| `services/job_service.dart`     | Stub — implement the three API methods here          |
| `cubits/jobs_cubit.dart`        | Stub — implement cubit logic here                    |
| `cubits/jobs_state.dart`        | Partial stub — define your state fields here         |
| `screens/job_list_screen.dart`  | Stub — implement the list UI here                    |
| `screens/job_detail_screen.dart`| Stub — implement the detail UI here                  |
| `main.dart`                     | App shell with `BlocProvider` wired up               |

---

## The Tasks

### Backend

Implement the three stubbed endpoints in `app/routers/jobs.py` and one new aggregation endpoint. Each stub raises `NotImplementedError` and has a docstring describing the expected behavior.

| Endpoint                     | Description                                                                                              |
| ---------------------------- | -------------------------------------------------------------------------------------------------------- |
| `GET /api/jobs`              | Return all jobs. Support optional `?region=` and `?status=` query filters (case-insensitive, AND logic). |
| `GET /api/jobs/regions`      | Return a sorted list of unique region names.                                                             |
| `GET /api/jobs/{job_id}`     | Return a single job by ID. Return 404 if not found.                                                      |
| `GET /api/jobs/stats`        | Return per-region aggregate stats: total job count, average `percent_complete`, and a breakdown of job counts by `status_name`. You will need to add this endpoint and define its response model. |

Write at least **two `pytest` tests** covering the behavior of your endpoints. Place them in `backend/tests/`.

### Mobile

Implement the full job summary feature using the BLoC/Cubit pattern scaffolded in the project.

**State (`cubits/jobs_state.dart`)**
Define the fields each state class needs. Think about what data the UI requires in each case before writing any other code.

**Service (`services/job_service.dart`)**
Implement the three methods using the `http` package to call your backend. Handle non-200 responses with a meaningful exception.

**Cubit (`cubits/jobs_cubit.dart`)**
Implement `loadJobs` and `loadRegions`, emitting the appropriate states. The two methods should be callable independently so the region filter can be populated before jobs are fetched.

**List screen (`screens/job_list_screen.dart`)**
Display a filterable list of job summaries. The region filter should call `loadJobs` with the selected region when changed. Show a loading indicator and a meaningful error state. Each list item should display at minimum: `pad_name`, `status_name`, `region_name`, and `percent_complete`. Use your judgment on layout and visual style.

**Detail screen (`screens/job_detail_screen.dart`)**
Tapping a job in the list should navigate to a detail screen that fetches and displays the full job record from `GET /api/jobs/{job_id}`.

Write at least **two tests** — one cubit unit test and one widget test. The existing `test/widget_test.dart` is a placeholder; replace or extend it as needed.

---

## Submission

Please submit either:

- A ZIP of the project (excluding `.venv/`, `build/`, and `.dart_tool/`), or
- A link to a Git branch / fork

Include a short note (3–5 sentences) describing tradeoffs or assumptions you made — particularly around state design, error handling, and anything you would do differently with more time.
