#! /bin/bash

docker compose -f docker-compose.yml --env-file .env build

kind load docker-image otel-target-allocator-talk:0.1.0-py-ta-example -n otel-target-allocator-talk