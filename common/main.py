import os

import uvicorn
from fastapi import Body, FastAPI, Path
from predictor import run
from pydantic import BaseModel


class NumeraiComputeWebhookRequest(BaseModel):
    roundNumber: int | str
    dataVersion: int
    triggerId: str
    isTest: bool | None = None


app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)


@app.post("/pred/{model_id}")
def numerai_compute_webhook(
    model_id: str = Path(
        default=...,
        title="Model ID",
        min_length=36,
        max_length=36,
        regex="^[^-]{8}-[^-]{4}-[^-]{4}-[^-]{4}-[^-]{12}$",
    ),
    request_body: NumeraiComputeWebhookRequest = Body(),
):
    print(f"{model_id=}, {request_body=}")

    # set env vars using provided model_id
    os.environ["NUMERAI_MODEL_ID"] = model_id

    run()

    return "OK"


if __name__ == "__main__":
    server_port = int(os.environ.get("PORT", 8080))
    uvicorn.run("main:app", host="0.0.0.0", port=server_port, log_level="info")
