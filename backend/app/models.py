from pydantic import BaseModel


class JobSummaryItem(BaseModel):
    job_id: str
    pad_name: str
    status_name: str
    region_name: str
    plan_start_date: str
    days_planned: int
    percent_complete: int
