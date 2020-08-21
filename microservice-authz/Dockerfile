FROM ubuntu:20.04

COPY app.py /

RUN apt-get update && apt-get install --no-install-recommends -y python3-pip && \
    python3 -m pip install flask requests

ENTRYPOINT ["python3", "app.py"]