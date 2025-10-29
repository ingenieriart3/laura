# FROM hexpm/elixir:1.18.1-erlang-27.2-alpine-3.21.0 AS builder

# ENV MIX_ENV=prod

# RUN apk add --no-cache build-base git nodejs npm postgresql-client

# RUN mkdir /app
# WORKDIR /app

# RUN mix local.hex --force && mix local.rebar --force

# COPY mix.exs mix.lock ./
# RUN mix deps.get --only $MIX_ENV
# RUN mix deps.compile

# COPY config config
# COPY assets assets

# RUN cd assets && npm install
# RUN mix assets.deploy

# COPY lib lib
# COPY priv priv
# RUN mix compile

# RUN mix release

# FROM alpine:3.21.0 AS runtime

# RUN apk add --no-cache openssl ncurses libstdc++ postgresql-client bash

# WORKDIR /app
# COPY --from=builder /app/_build/prod/rel/laura ./

# CMD ["bin/laura", "start"]

FROM hexpm/elixir:1.18.1-erlang-27.2-alpine-3.21.0 AS builder

ENV MIX_ENV=prod

RUN apk add --no-cache build-base git nodejs npm postgresql-client

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

COPY config config
COPY assets assets

RUN cd assets && npm install
RUN mix assets.deploy

COPY lib lib
COPY priv priv
RUN mix compile

RUN mix release

# --- Runtime stage ---
FROM alpine:3.21.0 AS runtime

RUN apk add --no-cache openssl ncurses libstdc++ postgresql-client bash

WORKDIR /app
COPY --from=builder /app/_build/prod/rel/laura ./

# Agregamos script de arranque
COPY <<EOF /app/start.sh
#!/bin/sh
set -e

echo "🔄 Running database migrations..."
/app/bin/laura eval "Laura.Release.migrate"

echo "🚀 Starting Laura..."
exec /app/bin/laura start
EOF

RUN chmod +x /app/start.sh

ENTRYPOINT ["/app/start.sh"]
