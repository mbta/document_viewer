#!/bin/bash
set -e

# Elixir code
mix format --check-formatted
mix credo --strict

# JS code
npm run --prefix assets check
