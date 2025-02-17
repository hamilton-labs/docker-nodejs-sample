# syntax=docker/dockerfile:1

ARG NODE_VERSION=20

FROM node:${NODE_VERSION}-alpine

# Use production node environment by default.
ENV NODE_ENV production

WORKDIR /usr/src/app
# Expose the port that the application listens on.
EXPOSE 3000
# Copy the source files like package.json & package-lock.json instead of bind mounting them into the image.
#COPY . .
#
#RUN 	--mount=type=cache,target=/root/.npm \
# Ran npm install to the cache mount
#	npm i

FROM base as dev
RUN 	--mount=type=cache,target=/root/.npm \
	npm ci --include=dev

USER node
COPY . .
CMD npm run dev
# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.npm to speed up subsequent builds.
# Leverage a bind mounts to package.json and package-lock.json to avoid having to copy them into
# into this layer.

FROM base as prod
RUN --mount=type=cache,target=/root/.npm \
	npm ci --omit=dev
USER node	
COPY . .

# Run the application.
CMD node src/index.js
