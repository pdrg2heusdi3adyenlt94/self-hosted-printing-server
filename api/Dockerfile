FROM node:20
RUN apt-get update && apt-get install -y \
    libreoffice \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev \
    pkg-config \
    --no-install-recommends && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/src/app
COPY package*.json ./
COPY .yarnrc.yml ./
RUN corepack enable
RUN corepack install
RUN yarn install
COPY . .
RUN yarn build
EXPOSE 3001
CMD ["sh", "-c", "npx prisma db push && node dist/src/main"]
