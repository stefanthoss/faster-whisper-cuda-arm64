#!/usr/bin/env bash

python3 -m wyoming_faster_whisper \
    --uri 'tcp://0.0.0.0:10300' \
    --data-dir /data \
    --download-dir /data \
    --model "${WHISPER_MODEL:-base-int8}" \
    --language "${WHISPER_LANG:-en}" \
    --beam-size "${WHISPER_BEAM:-1}" \
    --device cuda
