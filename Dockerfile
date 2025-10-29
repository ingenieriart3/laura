# Dockerfile
FROM hexpm/elixir:1.15.7-erlang-26.2.2-alpine-3.18.4

RUN apk add --no-cache build-base git npm postgresql-client

# Preparar directorio de trabajo
RUN mkdir /app
WORKDIR /app

# Instalar Hex y Rebar
RUN mix local.hex --force && mix local.rebar --force

# Copiar archivos de configuración de Mix
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

# Copiar configuración
COPY config config

# Compilar dependencias
RUN mix deps.compile

# Build de assets
COPY assets assets
RUN cd assets && npm install
RUN mix assets.deploy

# Copiar código de la aplicación
COPY lib lib
COPY priv priv

# Compilar aplicación
RUN mix compile

# Crear release
RUN MIX_ENV=prod mix release

# Runtime
FROM alpine:3.18.4

RUN apk add --no-cache openssl ncurses libstdc++ postgresql-client

WORKDIR /app
COPY --from=0 /app/_build/prod/rel/laura ./

CMD ["bin/laura", "start"]