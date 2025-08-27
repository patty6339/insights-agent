FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# System deps (security updates + tini as init)
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends tini && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -u 10001 -m appuser

WORKDIR /app
COPY app/requirements.txt /app/requirements.txt

RUN python -m pip install --upgrade pip \
    && pip install -r /app/requirements.txt

# Copy app
COPY app /app/app

# Expose Cloud Run port
EXPOSE 8080

# Change ownership and drop privileges
RUN chown -R appuser:appuser /app
USER appuser

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080", "--proxy-headers"]
