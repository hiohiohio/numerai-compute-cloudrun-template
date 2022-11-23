FROM python:3.11-slim-bullseye

ARG PREDICTOR
ARG PREDICTOR_DIR=predictors/${PREDICTOR}

ARG APPDIR=/opt/numerai-compute
WORKDIR ${APPDIR}

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY ${PREDICTOR_DIR}/requirements.txt /tmp/requirements.txt

RUN python3 -m pip install --no-cache-dir -r /tmp/requirements.txt

COPY common/* ${APPDIR}/
COPY ${PREDICTOR_DIR}/resources ${APPDIR}/resources
COPY ${PREDICTOR_DIR}/predictor.py ${APPDIR}/

CMD ["python3", "-u", "main.py"]
