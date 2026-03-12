# ─────────────────────────────────────────
# Stage: Base Image
# Why python:3.11-slim?
# Minimal image = faster builds + less vulnerabilities
# Full python image is 900MB, slim is 130MB
# ─────────────────────────────────────────
FROM python:3.11-slim

# ─────────────────────────────────────────
# Working Directory
# All commands run from /app inside container
# Keeps container filesystem organized
# ─────────────────────────────────────────
WORKDIR /app

# ─────────────────────────────────────────
# Copy requirements FIRST (layer caching!)
# This layer only rebuilds if requirements.txt changes
# Code changes don't trigger library reinstall
# Saves 3-4 mins on every pipeline run
# ─────────────────────────────────────────
COPY app/requirements.txt .

# ─────────────────────────────────────────
# Install dependencies
# --no-cache-dir removes pip cache after install
# Reduces image size by ~50MB
# ─────────────────────────────────────────
RUN pip install --no-cache-dir -r requirements.txt

# ─────────────────────────────────────────
# Copy application code
# Done AFTER pip install for layer caching
# ─────────────────────────────────────────
COPY app/ .

# ─────────────────────────────────────────
# Security — Non-root user
# NEVER run containers as root in production
# If container is compromised →
# attacker has limited permissions only
# ─────────────────────────────────────────
RUN adduser --disabled-password --gecos "" appuser
USER appuser

# ─────────────────────────────────────────
# Expose port
# Flask runs on 5000
# K8s Service routes traffic to this port
# ─────────────────────────────────────────
EXPOSE 5000

# ─────────────────────────────────────────
# Start command
# List format handles K8s SIGTERM gracefully
# Allows clean shutdown when pod is stopped
# ─────────────────────────────────────────
CMD ["python", "app.py"]