#! /bin/bash

docker compose -f docker-compose.yml --env-file .env build

kind load docker-image otel-target-allocator-talk:0.1.0-py-otel-server -n otel-target-allocator-talk
kind load docker-image otel-target-allocator-talk:0.1.0-py-otel-client -n otel-target-allocator-talk