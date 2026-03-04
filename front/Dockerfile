# ---- Build stage ----
FROM node:20-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
COPY .yarnrc.yml ./
RUN corepack enable && corepack install
RUN yarn install
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
COPY serve.json ./
COPY docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh
EXPOSE 80
ENTRYPOINT ["./docker-entrypoint.sh"]
