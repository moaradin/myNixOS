#!/usr/bin/env bash
# Assuming noctalia-shell is in your PATH. 
# If not, replace with the absolute path to the binary.
for i in $(seq 1 50); do
    noctalia-shell ipc call lockScreen lock > /dev/null 2>&1 && break || sleep 0.1
done
