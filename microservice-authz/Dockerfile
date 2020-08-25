FROM ubuntu:20.04

RUN apt-get update && apt-get install --no-install-recommends -y curl python3-pip && \
    python3 -m pip install flask requests

COPY app.py /

ENTRYPOINT ["python3", "app.py"]