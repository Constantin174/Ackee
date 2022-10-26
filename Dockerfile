# Start with first build stage

FROM node:14-alpine AS build
WORKDIR /srv/app/

# Add dependencies first so that Docker can use the cache as long as the dependencies stay unchanged

COPY package.json yarn.lock /srv/app/
RUN yarn install --production --frozen-lockfile --network-timeout 120000

# Copy source after the dependency step as it's more likely that the source changes

COPY build.js /srv/app/
COPY src /srv/app/src
COPY dist /srv/app/dist

# Start with second build stage

FROM node:14-alpine
EXPOSE 3000

USER root

ENV USER=node
ENV WORKDIR="/home/$USER"
ENV APP_DIR="$WORKDIR/srv/app"

WORKDIR $APP_DIR

# Copy the source from the build stage to the second stage

COPY --chown=node --from=build /srv/app/ "$APP_DIR/"
COPY --chown=node /entrypoint $APP_DIR/entrypoint

RUN chmod 777 $APP_DIR/entrypoint

USER $USER

# Start Ackee

ENTRYPOINT "$APP_DIR/entrypoint"
