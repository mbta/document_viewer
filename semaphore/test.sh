#!/bin/bash
set -e

mix test
mix coveralls.json
bash <(curl -s https://codecov.io/bash) || exit 0
