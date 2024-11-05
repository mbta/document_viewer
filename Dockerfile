# First, get the elixir dependencies within an elixir container
FROM hexpm/elixir:1.17.3-erlang-27.1-alpine-3.19.4 as elixir-builder

ENV LANG="C.UTF-8" MIX_ENV=prod

WORKDIR /root
ADD . .

# Install hex, rebar, and deps
RUN mix local.hex --force && \
  mix local.rebar --force && \
  mix do deps.get --only prod

# Next, build the frontend assets within a node.js container
FROM node:20-alpine3.19 as assets-builder

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

# Finally, use an Alpine container for the runtime environment
FROM alpine:3.19.4

RUN apk add --update libstdc++ ncurses-libs bash curl dumb-init ca-certificates \
  && apk upgrade \
  && rm -rf /var/cache/apk

# Create non-root user
RUN addgroup -S document_viewer && adduser -S -G document_viewer document_viewer
USER document_viewer
WORKDIR /home/document_viewer

# Set environment
ENV MIX_ENV=prod TERM=xterm LANG="C.UTF-8" PORT=4000 REPLACE_OS_VARS=true

# Add frontend assets with manifests from app-builder container
COPY --from=app-builder --chown=document_viewer:document_viewer /root/priv/static ./priv/static

# Add application artifact compiled in app-builder container
COPY --from=app-builder --chown=document_viewer:document_viewer /root/_build/prod/rel/document_viewer .

EXPOSE 4000

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Health Check
HEALTHCHECK CMD ["bin/document_viewer", "rpc", "1 + 1"]
# Run the application
CMD ["bin/document_viewer", "start"]
