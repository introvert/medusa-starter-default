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
ENV MEDUSA_FF_TRANSLATION="false"

WORKDIR /app/medusa

RUN apt-get update && apt-get install -y python3 python3-pip python-is-python3 curl

RUN npm i -g pnpm@9.4.0

COPY --from=builder /app/medusa/.medusa/server .
COPY --from=builder /app/medusa/pnpm-lock.yaml .

# Keep all deps (including ts-node) to match expected runtime environment
RUN pnpm install --frozen-lockfile

COPY start.sh .
RUN chmod +x start.sh

EXPOSE 9000

# Medusa health endpoint is /health not /
HEALTHCHECK --interval=10s --timeout=5s --start-period=60s --retries=5 \
  CMD curl -f http://localhost:${PORT}/health || exit 1

CMD ["./start.sh"]
