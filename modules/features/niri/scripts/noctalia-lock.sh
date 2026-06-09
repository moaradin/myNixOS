#!/usr/bin/env bash
# Lock the screen via Noctalia v5's session IPC.
# Retries for up to 5 s to give noctalia time to finish starting.
for i in $(seq 1 50); do
    noctalia msg session lock > /dev/null 2>&1 && break || sleep 0.1
done
