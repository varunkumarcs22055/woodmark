#!/usr/bin/env bash
# Render build command. Runs before each deploy.
#
# 1. Install dependencies
# 2. Collect static files (admin assets etc.) for WhiteNoise to serve
# 3. Apply any pending migrations against the production DB
#
# Fail-fast — any non-zero exit aborts the deploy so we don't push broken code.
set -o errexit

pip install --upgrade pip
pip install -r requirements.txt

python manage.py collectstatic --no-input
python manage.py migrate --no-input
