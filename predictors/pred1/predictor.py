import os

import pandas as pd
from numerapi import NumerAPI


def run():
    # NUMERAI_PUBLIC_ID and NUMERAI_SECRET_KEY are passed from Cloud Run
    numerai_public_id = os.environ["NUMERAI_PUBLIC_ID"]
    numerai_secret_key = os.environ["NUMERAI_SECRET_KEY"]
    # NUMERAI_MODEL_ID is set in main.py from path parameter
    model_id = os.environ["NUMERAI_MODEL_ID"]

    napi = NumerAPI(numerai_public_id, numerai_secret_key)

    # load live data
    LIVE_DATA_FILENAME = "live_int8.parquet"
    napi.download_dataset(f"v4/{LIVE_DATA_FILENAME}", LIVE_DATA_FILENAME)
    df_live = pd.read_parquet(LIVE_DATA_FILENAME)

    # set prediction
    df_live["prediction"] = list(range(len(df_live)))
    df_live["prediction"] = df_live["prediction"].rank(pct=True)

    # upload prediction
    napi.upload_predictions(df=df_live["prediction"].reset_index(), model_id=model_id)
