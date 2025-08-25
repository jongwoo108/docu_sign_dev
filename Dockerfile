FROM node:22-alpine

# 도구
RUN apk add --no-cache bash libc6-compat openssl
WORKDIR /app

# 의존성 (dev 포함 설치: 빌드를 위해 필요)
ENV HUSKY=0
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN npm ci --include=dev || npm install

# 소스 + Prisma
COPY packages/prisma ./prisma
COPY . .

# Prisma Client 생성
RUN npx prisma generate --schema=/app/prisma/schema.prisma

# Remix 앱 전용 빌드 단계별 실행
WORKDIR /app/apps/remix
RUN npm run build:app
RUN npm run build:server

# main.js 파일을 build/server/로 복사
RUN cp server/main.js build/server/main.js

# 기본 translations 디렉토리 생성 (빈 디렉토리라도)
RUN mkdir -p build/server/hono/packages/lib/translations

# (원하면) 슬림화 — 처음엔 생략 권장. 문제 없으면 나중에 추가해도 됨
# RUN npm prune --omit=dev
ENV NODE_ENV=production

# 실행: build 결과를 직접 실행 (dotenv/x-env 불필요)
WORKDIR /app
EXPOSE 3000
CMD ["node","apps/remix/build/server/main.js"]
