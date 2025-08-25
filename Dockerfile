FROM node:22-alpine

# 도구
RUN apk add --no-cache bash libc6-compat openssl
WORKDIR /app

# 의존성 (dev 포함 설치: 빌드를 위해 필요)
ENV HUSKY=0
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN npm ci --include=dev || npm install
# cross-env 글로벌 설치 (npm start 스크립트에서 필요)
RUN npm install -g cross-env

# 소스 + Prisma
COPY packages/prisma ./prisma
COPY . .

# Prisma Client 생성
RUN npx prisma generate --schema=/app/prisma/schema.prisma

# 간단한 빌드 과정: turbo만 실행
RUN npx turbo run build --filter=@documenso/remix^... --no-daemon

# 기본 작업 디렉토리 설정
WORKDIR /app/apps/remix

# (원하면) 슬림화 — 처음엔 생략 권장. 문제 없으면 나중에 추가해도 됨
# RUN npm prune --omit=dev
ENV NODE_ENV=production

# 실행: npm start 사용 (cross-env가 설치되어 있으므로 정상 작동)
EXPOSE 3000
CMD ["npm", "run", "start"]
