from fastapi.testclient import TestClient

from app.data import JOB_SUMMARY_DATA
from app.main import app

client = TestClient(app)


def test_get_jobs_returns_all():
    """GET /api/jobs with no filters returns every job."""
    resp = client.get("/api/jobs")
    assert resp.status_code == 200
    assert len(resp.json()) == len(JOB_SUMMARY_DATA)


def test_get_jobs_filters_by_region():
    """GET /api/jobs?region=Permian returns only Permian jobs."""
    resp = client.get("/api/jobs", params={"region": "Permian"})
    assert resp.status_code == 200
    jobs = resp.json()
    assert len(jobs) == 2
    assert {j["job_id"] for j in jobs} == {"job-001", "job-004"}
    assert all(j["region_name"] == "Permian" for j in jobs)


def test_get_jobs_filter_is_case_insensitive_and_combinable():
    """Region and status filters match regardless of case and combine with AND."""
    resp = client.get("/api/jobs", params={"region": "permian", "status": "ACTIVE"})
    assert resp.status_code == 200
    jobs = resp.json()
    assert {j["job_id"] for j in jobs} == {"job-001", "job-004"}

    # AND logic: Permian + Complete has no matches.
    resp = client.get("/api/jobs", params={"region": "Permian", "status": "Complete"})
    assert resp.status_code == 200
    assert resp.json() == []


def test_get_regions_returns_sorted_unique_list():
    """GET /api/jobs/regions returns a sorted, deduplicated list."""
    resp = client.get("/api/jobs/regions")
    assert resp.status_code == 200
    assert resp.json() == ["Eagle Ford", "Haynesville", "Marcellus", "Permian"]


def test_get_job_returns_correct_job():
    """GET /api/jobs/{job_id} returns the matching job."""
    resp = client.get("/api/jobs/job-003")
    assert resp.status_code == 200
    body = resp.json()
    assert body["job_id"] == "job-003"
    assert body["pad_name"] == "Haynesville Gamma"
    assert body["percent_complete"] == 100


def test_get_job_returns_404_for_unknown_id():
    """GET /api/jobs/{job_id} returns 404 when the job does not exist."""
    resp = client.get("/api/jobs/does-not-exist")
    assert resp.status_code == 404


def test_get_stats_shape_and_values():
    """GET /api/jobs/stats returns per-region aggregates, sorted by region."""
    resp = client.get("/api/jobs/stats")
    assert resp.status_code == 200
    stats = resp.json()

    # One entry per region, sorted alphabetically.
    assert [s["region_name"] for s in stats] == [
        "Eagle Ford",
        "Haynesville",
        "Marcellus",
        "Permian",
    ]

    by_region = {s["region_name"]: s for s in stats}

    # Permian: job-001 (Active, 62), job-004 (Active, 35).
    permian = by_region["Permian"]
    assert permian["total_jobs"] == 2
    assert permian["average_percent_complete"] == 48.5
    assert permian["status_breakdown"] == {"Active": 2}

    # Eagle Ford: job-002 (Planned, 0), job-006 (On Hold, 18).
    eagle_ford = by_region["Eagle Ford"]
    assert eagle_ford["total_jobs"] == 2
    assert eagle_ford["average_percent_complete"] == 9.0
    assert eagle_ford["status_breakdown"] == {"On Hold": 1, "Planned": 1}
