#!/usr/bin/env bash
set -e

# Install asdf and link cached languages
export ASDF_DATA_DIR="${SEMAPHORE_CACHE_DIR}/.asdf"
if [[ ! -d "${ASDF_DATA_DIR}" ]]; then
  mkdir -p "${ASDF_DATA_DIR}"
  git clone https://github.com/asdf-vm/asdf.git "${ASDF_DATA_DIR}" --branch v0.8.0
fi

source "${ASDF_DATA_DIR}/asdf.sh"
asdf update

# Add asdf plugins and install tools
asdf plugin add erlang || true
asdf plugin add elixir || true
asdf plugin add nodejs || true
asdf plugin update --all

# import the Node.js release team's OpenPGP keys to main keyring
bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'

asdf install
# reshim is needed to pick up languages that were already installed in cache
asdf reshim

export MIX_ENV=test
export MIX_DEPS_PATH="${SEMAPHORE_CACHE_DIR}/mix/deps"
ln -s "${SEMAPHORE_CACHE_DIR}/mix/deps" deps

mix local.hex --force
mix local.rebar --force
mix deps.get

pushd assets && npm ci && popd
