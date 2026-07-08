from collections import defaultdict

from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel

from app.data import JOB_SUMMARY_DATA
from app.models import JobSummaryItem

router = APIRouter(prefix="/jobs", tags=["jobs"])


class RegionStats(BaseModel):
    """Aggregate statistics for a single region."""

    region_name: str
    total_jobs: int
    average_percent_complete: float
    # Count of jobs per status_name within the region, e.g. {"Active": 2}.
    status_breakdown: dict[str, int]


@router.get("", response_model=list[JobSummaryItem])
def get_jobs(
    region: str | None = Query(default=None, description="Filter by region name"),
    status: str | None = Query(default=None, description="Filter by status name"),
) -> list[dict]:
    """
    Return all job summaries, optionally filtered by region and/or status.

    Filters are case-insensitive and combine with AND logic.
    """
    jobs = JOB_SUMMARY_DATA
    if region is not None:
        jobs = [j for j in jobs if j["region_name"].lower() == region.lower()]
    if status is not None:
        jobs = [j for j in jobs if j["status_name"].lower() == status.lower()]
    return jobs


@router.get("/regions", response_model=list[str])
def get_regions() -> list[str]:
    """Return a sorted list of unique region names across all jobs."""
    return sorted({j["region_name"] for j in JOB_SUMMARY_DATA})


@router.get("/stats", response_model=list[RegionStats])
def get_stats() -> list[RegionStats]:
    """
    Return per-region aggregate stats, sorted by region name.

    For each region: total job count, average percent_complete (rounded to two
    decimals), and a breakdown of job counts by status_name.
    """
    jobs_by_region: dict[str, list[dict]] = defaultdict(list)
    for job in JOB_SUMMARY_DATA:
        jobs_by_region[job["region_name"]].append(job)

    stats: list[RegionStats] = []
    for region_name in sorted(jobs_by_region):
        region_jobs = jobs_by_region[region_name]
        total = len(region_jobs)
        average = sum(j["percent_complete"] for j in region_jobs) / total

        breakdown: dict[str, int] = defaultdict(int)
        for job in region_jobs:
            breakdown[job["status_name"]] += 1

        stats.append(
            RegionStats(
                region_name=region_name,
                total_jobs=total,
                average_percent_complete=round(average, 2),
                status_breakdown=dict(sorted(breakdown.items())),
            )
        )
    return stats


@router.get("/{job_id}", response_model=JobSummaryItem)
def get_job(job_id: str) -> dict:
    """
    Return a single job by its job_id.

    Raises HTTP 404 if no matching job is found.
    """
    for job in JOB_SUMMARY_DATA:
        if job["job_id"] == job_id:
            return job
    raise HTTPException(status_code=404, detail=f"Job '{job_id}' not found")
