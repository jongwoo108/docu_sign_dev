FROM node:22-alpine

RUN apk add --no-cache bash libc6-compat openssl

WORKDIR /app

COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./

RUN npm install

COPY prisma ./prisma
COPY . .

RUN npm run build
ARG DATABASE_URL
ENV DATABASE_URL=${DATABASE_URL}
RUN npx prisma generate \
 && npm run prisma:migrate-deploy

# Documenso Remix 앱 경로 기준으로 실행 (기존 환경과 동일)
WORKDIR /app/apps/remix
EXPOSE 3000
CMD ["npm","run","start"]
