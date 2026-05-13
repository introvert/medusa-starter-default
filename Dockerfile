FROM node:23 AS builder

WORKDIR /app/medusa

COPY . .

RUN rm -rf node_modules

RUN apt-get update && apt-get install -y python3 python3-pip python-is-python3

RUN npm i -g pnpm@9.4.0

RUN pnpm install --frozen-lockfile

RUN NODE_OPTIONS="--max-old-space-size=4096" pnpm build


FROM node:23

# Runtime environment variables — set these via docker run -e or docker-compose environment:
ENV NODE_ENV="production"
ENV COOKIE_SECRET=""
ENV JWT_SECRET=""
ENV STORE_CORS=""
ENV ADMIN_CORS=""
ENV AUTH_CORS=""
ENV DISABLE_MEDUSA_ADMIN="false"
ENV MEDUSA_WORKER_MODE="server"
ENV MEDUSA_BACKEND_URL=""
ENV DATABASE_URL=""
ENV REDIS_URL=""
ENV STRIPE_API_KEY=""
ENV PORT="9000"

WORKDIR /app/medusa

RUN apt-get update && apt-get install -y python3 python3-pip python-is-python3

RUN npm i -g pnpm@9.4.0

COPY --from=builder /app/medusa/.medusa/server .

RUN pnpm install --prod

EXPOSE 9000

CMD ["pnpm", "start"]
