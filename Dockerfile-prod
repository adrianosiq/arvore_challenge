ARG ALPINE_VERSION=3.17

FROM elixir:1.14-otp-25-alpine AS builder

ARG APP_NAME=arvore_challenge
ARG APP_VSN=0.1.0
ARG MIX_ENV=prod
ARG SKIP_PHOENIX=false

ENV SKIP_PHOENIX=${SKIP_PHOENIX} \
  APP_NAME=${APP_NAME} \
  APP_VSN=${APP_VSN} \
  MIX_ENV=${MIX_ENV}

WORKDIR /opt/built

RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
  alpine-sdk \
  coreutils \
  git && \
  mix local.rebar --force && \
  mix local.hex --force 

# This copies our app source code into the build container
COPY . .

RUN mix do deps.get, deps.compile, compile
RUN mix do release ${APP_NAME}
RUN cp -R _build/${MIX_ENV}/rel/${APP_NAME}/* /opt/built 

# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:${ALPINE_VERSION}

ARG APP_NAME=arvore_challenge

RUN apk update && \
  apk add --no-cache \
  bash \
  openssl-dev \
  libgcc \
  libstdc++ \
  ncurses-libs

ENV REPLACE_OS_VARS=true \
  APP_NAME=${APP_NAME} \
  MIX_ENV=${MIX_ENV} \
  PHX_SERVER=true

WORKDIR /opt/app

COPY --from=builder /opt/built .

EXPOSE 4000
CMD ["sh", "-c", "/opt/app/bin/${APP_NAME} eval 'ArvoreChallenge.ReleaseTasks.migrate'; trap 'exit' INT; /opt/app/bin/${APP_NAME} start"]
