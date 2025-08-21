FROM node:22-alpine
RUN apk add --no-cache bash libc6-compat openssl
ENV NODE_ENV=production
WORKDIR /app

COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN npm ci || npm install

# 여기가 핵심 (packages/prisma)
COPY packages/prisma ./prisma
COPY . .

# Prisma client 생성
RUN npx prisma generate --schema=/app/prisma/schema.prisma

RUN npm run build

WORKDIR /app/apps/remix
EXPOSE 3000
CMD ["npm","run","start"]
