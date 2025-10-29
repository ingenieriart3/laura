# Dockerfile CORREGIDO
FROM hexpm/elixir:1.16-alpine AS builder

# Configurar environment de producción
ENV MIX_ENV=prod

RUN apk add --no-cache build-base git npm postgresql-client

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

# Copiar archivos de configuración primero
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# Copiar configuración y compilar assets
COPY config config
COPY assets assets
RUN cd assets && npm install
RUN mix assets.deploy

# Copiar código y compilar
COPY lib lib
COPY priv priv
RUN mix compile

# Crear release
RUN mix release

# Runtime image
FROM alpine:3.19 AS runtime

RUN apk add --no-cache openssl ncurses libstdc++ postgresql-client bash

WORKDIR /app
COPY --from=builder /app/_build/prod/rel/laura ./

CMD ["bin/laura", "start"]