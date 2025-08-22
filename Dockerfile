# ---- Builder ----
FROM node:22-alpine AS builder

RUN apk add --no-cache bash libc6-compat openssl
WORKDIR /app

ENV HUSKY=0
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN npm ci --include=dev || npm install

# Prisma 스키마 복사
COPY packages/prisma ./prisma

# 전체 소스 복사
COPY . .

# Prisma Client 생성
RUN npx prisma generate --schema=/app/prisma/schema.prisma

# Remix 앱 빌드
RUN npx turbo run build --filter=@documenso/remix^... --no-daemon

# ---- Runtime ----
FROM node:22-alpine AS runner

WORKDIR /app

# 런타임에 필요한 최소 툴만
RUN apk add --no-cache bash openssl

ENV NODE_ENV=production
ENV HUSKY=0

# package.json과 lock 파일 복사
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./

# production deps만 설치
RUN npm ci --omit=dev || npm install --omit=dev

# 빌드 산출물 복사
COPY --from=builder /app/apps/remix ./apps/remix
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/node_modules ./node_modules

WORKDIR /app/apps/remix
EXPOSE 3000

CMD ["npm","run","start"]
