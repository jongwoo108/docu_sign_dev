FROM node:22-alpine AS base

# 기본 툴 설치
RUN apk add --no-cache bash libc6-compat openssl

WORKDIR /app

# husky 훅 방지
ENV HUSKY=0

# 패키지 메타 복사
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./

# 의존성 설치 (devDeps 포함)
RUN npm ci --include=dev || npm install

# Prisma 스키마 복사
COPY packages/prisma ./prisma

# 전체 소스 복사
COPY . .

# Prisma Client 생성
RUN npx prisma generate --schema=/app/prisma/schema.prisma

# Remix 앱 빌드 (turbo 이용, remix 및 관련 워크스페이스만)
RUN npx turbo run build --filter=@documenso/remix^... --no-daemon

# -------------------------------
# 런타임 단계 (슬림화)
# -------------------------------
FROM node:22-alpine AS runtime

WORKDIR /app

RUN apk add --no-cache bash libc6-compat openssl

# 소스 + node_modules 복사
COPY --from=base /app /app

# devDependencies 제거
RUN npm prune --omit=dev

ENV NODE_ENV=production

# Remix 앱 기준 디렉토리
WORKDIR /app/apps/remix

EXPOSE 3000

# 기본 실행 (npm start → remix 패키지의 "start" 스크립트 실행)
CMD ["npm", "run", "start"]
