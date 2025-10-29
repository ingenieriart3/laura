# # FROM hexpm/elixir:1.16-alpine AS builder
# FROM hexpm/elixir:1.18.1-erlang-27.2-alpine-3.21.0 AS builder

# ENV MIX_ENV=prod

# # Instalar dependencias del sistema
# RUN apk add --upgrade --no-cache \
#     build-base \
#     git \
#     nodejs \
#     npm \
#     postgresql-client

# WORKDIR /app

# # Configurar Mix
# RUN mix local.hex --force && \
#     mix local.rebar --force

# # Instalar dependencias de Elixir
# COPY mix.exs mix.lock ./
# RUN mix deps.get --only $MIX_ENV
# RUN mix deps.compile

# # Instalar dependencias de Node.js y compilar assets
# COPY assets assets
# RUN cd assets && \
#     npm install && \
#     npm run deploy

# # Copiar resto de la aplicación
# COPY config config
# COPY lib lib
# COPY priv priv
# RUN mix compile

# # Compilar assets con Mix
# RUN mix phx.digest

# # Crear release
# RUN mix release

# # Runtime
# FROM alpine:3.19 AS runtime

# RUN apk add --no-cache \
#     openssl \
#     ncurses-libs \
#     libstdc++ \
#     postgresql-client

# WORKDIR /app
# COPY --from=builder /app/_build/prod/rel/laura ./

# CMD ["bin/laura", "start"]
# Dockerfile CORREGIDO
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

# ✅ COMANDOS CORRECTOS - usar mix en lugar de npm run deploy
RUN cd assets && npm install
RUN mix assets.deploy

COPY lib lib
COPY priv priv
RUN mix compile

RUN mix release

FROM alpine:3.21.0 AS runtime

RUN apk add --no-cache openssl ncurses libstdc++ postgresql-client bash

WORKDIR /app
COPY --from=builder /app/_build/prod/rel/laura ./

CMD ["bin/laura", "start"]