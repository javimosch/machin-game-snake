#!/usr/bin/env bash
set -euo pipefail
MACHIN="${MACHIN:-machin}"
"$MACHIN" encode snake.src > snake.mfl
"$MACHIN" build snake.mfl -o machin-game-snake
echo "built ./machin-game-snake"
