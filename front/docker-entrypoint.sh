#!/bin/sh
set -e

# Replace the build-time placeholder with the runtime PUBLIC_API_URL env var.
# This allows a single pre-built image to work with any API endpoint.
if [ -n "$PUBLIC_API_URL" ]; then
  echo "Injecting PUBLIC_API_URL: $PUBLIC_API_URL"
  find /usr/src/app/dist -type f -name "*.js" \
    -exec sed -i "s|__RUNTIME_PUBLIC_API_URL__|${PUBLIC_API_URL}|g" {} \;
else
  echo "WARNING: PUBLIC_API_URL is not set. API calls will fail."
fi

exec serve --config serve.json dist
