#!/bin/bash
set -e

mix test
mix coveralls.json
