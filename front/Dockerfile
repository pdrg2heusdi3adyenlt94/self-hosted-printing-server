# ---- Build stage ----
FROM node:20 AS builder
WORKDIR /usr/src/app
# Copy dependency manifests only so yarn install is cached as its own layer.
# yarn.lock must be included so the install is reproducible.
COPY package.json yarn.lock .yarnrc.yml ./
RUN corepack enable
RUN corepack install
RUN yarn install --immutable
COPY . .
# Build with a placeholder so the image stays generic.
# The real URL is injected at container start via docker-entrypoint.sh.
ENV PUBLIC_API_URL=__RUNTIME_PUBLIC_API_URL__
RUN yarn build

# ---- Serve stage ----
FROM node:20-alpine
WORKDIR /usr/src/app
RUN npm install --global serve
COPY --from=builder /usr/src/app/dist ./dist
COPY docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh
EXPOSE 80
ENTRYPOINT ["./docker-entrypoint.sh"]
