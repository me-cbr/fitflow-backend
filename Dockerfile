FROM python:3.13-slim AS builder
LABEL maintainer="mecoelhodev@gmail.com"

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN pip install --upgrade pip
COPY ./requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.13-slim

RUN useradd -m -u 1000 -r vitality_track
WORKDIR /app

COPY --from=builder /usr/local/lib/python3.13/site-packages/ /usr/local/lib/python3.13/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/

COPY --chown=vitality_track:vitality_track . .

RUN mkdir -p /app/static /app/media /app/logs && \
    chown -R vitality_track:vitality_track /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

USER vitality_track

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "wsgi:application"]