FROM hexpm/elixir:1.15.7-erlang-26.2.2-alpine-3.18.4

RUN apk add --no-cache build-base git npm postgresql-client

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY config config
RUN mix deps.compile

COPY assets assets
RUN cd assets && npm install
RUN mix assets.deploy

COPY lib lib
COPY priv priv

RUN mix compile

RUN MIX_ENV=prod mix release

FROM alpine:3.18.4

RUN apk add --no-cache openssl ncurses libstdc++ postgresql-client

WORKDIR /app
COPY --from=0 /app/_build/prod/rel/laura ./

CMD ["bin/laura", "start"]