#!/bin/bash
set -euo pipefail

IMAGE_NAME="iotaledger/gas-station-tool:latest"

# Only pass -it when both stdin and stdout are TTYs.
TTY_FLAGS=()
if [[ -t 0 && -t 1 ]]; then
  TTY_FLAGS=(-it)
fi

CMD=(
  docker run "${TTY_FLAGS[@]}" --rm
  --name iota-gas-station-tool
  -v "$(pwd)":/app
  -w /app
  -u "$(id -u)":"$(id -g)"
  "${IMAGE_NAME}"
)

if [[ -n "${HOD_SKIP_DOCKER:-}" ]]; then
  echo "HOD_SKIP_DOCKER is set; skipping docker run." >&2
  printf 'Command: %q ' "${CMD[@]}" "$@"
  printf '\n'
  exit 0
fi

exec "${CMD[@]}" "$@"
