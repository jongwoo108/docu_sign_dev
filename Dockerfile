FROM node:22-alpine

# base tools
RUN apk add --no-cache bash libc6-compat openssl
WORKDIR /app

# devDeps 포함 설치 (husky 훅 차단)
ENV HUSKY=0
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
# lockfile이 맞으면 ci, 아니면 install로 우회
RUN npm ci --include=dev || npm install

# Prisma 스키마 (정답 경로)
COPY packages/prisma ./prisma

# 앱 소스
COPY . .

# Prisma Client 생성
RUN npx prisma generate --schema=/app/prisma/schema.prisma

# 빌드(여기서 turbo 사용됨 → devDeps 필요)
RUN npx turbo run build --filter=@documenso/remix^... --no-daemon

# 런타임 슬림화: devDeps 제거 후 prod 모드
RUN npm prune --omit=dev
ENV NODE_ENV=production

# 실행
WORKDIR /app/apps/remix
EXPOSE 3000
CMD ["npm","run","start"] 
