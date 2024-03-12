FROM node:20.11.1-alpine AS base

ENV APP_HOME=/docker-ecs-test
WORKDIR $APP_HOME

###########################################################################
# Build image stage
FROM base AS build

# Install dependencies
RUN set -xe \
    && apk update \
    && apk add --no-cache dumb-init

# Install node dependencies
COPY --link package.json yarn.lock $APP_HOME
RUN yarn install --frozen-lockfile

# Copy project files
COPY src $APP_HOME/src

###########################################################################
# Production image stage
FROM base AS production

ENV NODE_ENV=production
ENV USER=node

COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init
COPY --from=build $APP_HOME/node_modules $APP_HOME/node_modules
COPY --from=build $APP_HOME/src $APP_HOME/src

USER $USER
EXPOSE 3000
CMD ["dumb-init", "node", "src/index.js"]
