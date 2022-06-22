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

WORKDIR $WORKDIR/srv/app/

# Copy the source from the build stage to the second stage

COPY --chown=node --from=build /srv/app/ $WORKDIR/srv/app/

USER $USER

# Start Ackee

CMD yarn start
