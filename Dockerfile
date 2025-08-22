# -------------------------------
# Build stage
# -------------------------------
FROM node:22-alpine AS build

RUN apk add --no-cache bash libc6-compat openssl
WORKDIR /app
ENV HUSKY=0

# install deps (dev 포함)
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN npm ci --include=dev || npm install

# copy source
COPY . .

# generate prisma client
RUN npx prisma generate --schema=/app/packages/prisma/schema.prisma

# build remix app (산출물: apps/remix/build)
RUN npx turbo run build --filter=@documenso/remix^... --no-daemon

# -------------------------------
# Runtime stage
# -------------------------------
FROM node:22-alpine AS runtime

RUN apk add --no-cache bash libc6-compat openssl
WORKDIR /app

ENV NODE_ENV=production

# prod deps만 가져오기
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN npm ci --omit=dev || npm install --omit=dev

# build 결과물 + prisma client 복사
COPY --from=build /app/apps/remix/build /app/apps/remix/build
COPY --from=build /app/node_modules/.prisma /app/node_modules/.prisma
COPY --from=build /app/packages/prisma /app/packages/prisma
COPY --from=build /app/apps/remix/package.json /app/apps/remix/

# 실행 디렉토리
WORKDIR /app/apps/remix

EXPOSE 3000

CMD ["npm", "run", "start"]
