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

# Remix 빌드 (apps/remix/build 생성되어야 정상)
RUN npx turbo run build --filter=@documenso/remix^... --no-daemon
# Remix 앱 전용 빌드 스크립트 실행 (main.js 파일 복사 포함)
WORKDIR /app/apps/remix
RUN npm run build

# (원하면) 슬림화 — 처음엔 생략 권장. 문제 없으면 나중에 추가해도 됨
# RUN npm prune --omit=dev
ENV NODE_ENV=production

# 실행: build 결과를 직접 실행 (dotenv/x-env 불필요)
WORKDIR /app
EXPOSE 3000
CMD ["node","apps/remix/build/server/main.js"]
