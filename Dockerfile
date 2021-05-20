# First, get the elixir dependencies within an elixir container
FROM hexpm/elixir:1.11.3-erlang-23.2.5-alpine-3.13.1 AS elixir-builder

ENV LANG="C.UTF-8" MIX_ENV=prod

WORKDIR /root
ADD . .

# Install hex, rebar, and deps
RUN mix local.hex --force && \
  mix local.rebar --force && \
  mix do deps.get --only prod

# Next, build the frontend assets within a node.js container
FROM node:14.15-alpine as assets-builder

WORKDIR /root
ADD . .

# Copy in elixir deps required to build node modules for phoenix
COPY --from=elixir-builder /root/deps ./deps

RUN npm --prefix assets ci
RUN npm --prefix assets run deploy

# Now, build the application back in the elixir container
FROM elixir-builder as app-builder

ENV LANG="C.UTF-8" MIX_ENV=prod

WORKDIR /root

# Add frontend assets compiled in node container, required by phx.digest
COPY --from=assets-builder /root/priv/static ./priv/static

RUN mix do compile --force, phx.digest, release

# Finally, use a Debian container for the runtime environment
FROM alpine:latest

RUN apk add --update libssl1.1 ncurses-libs \
  && rm -rf /var/cache/apk

WORKDIR /root
EXPOSE 4000
ENV MIX_ENV=prod TERM=xterm LANG="C.UTF-8" PORT=4000

# Add frontend assets with manifests from app-builder container
COPY --from=app-builder /root/priv/static ./priv/static

# Add application artifact compiled in app-builder container
COPY --from=app-builder /root/_build/prod/rel/document_viewer .

# Run the application
CMD ["bin/document_viewer", "start"]
