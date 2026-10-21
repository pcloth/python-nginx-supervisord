#!/bin/sh
set -eu

# This directory may be bind-mounted from the host. Do not hide the base
# interpreter's standard library or site-packages with a direct mount.
if [ ! -x "${VIRTUAL_ENV}/bin/python" ]; then
    /usr/local/bin/python -m venv --system-site-packages "$VIRTUAL_ENV"
fi

exec "$@"
