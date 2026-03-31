---
name: docker-cicd
description: "Docker, Docker Compose, CI/CD pipelines (GitHub Actions), deployment patterns. Production-ready containerization."
paths:
  - "**/Dockerfile*"
  - "**/docker-compose*"
  - "**/.github/workflows/**"
  - "**/deploy*"
  - "**/.dockerignore"
---

# DevOps & Deployment Expert

Production containerization and CI/CD. Ship reliably.

## Dockerfile Best Practices

### Node.js Multi-Stage Build
```dockerfile
# Stage 1: Dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

# Stage 2: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 3: Production (minimal image)
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Don't run as root
RUN addgroup --system --gid 1001 app && \
    adduser --system --uid 1001 app
USER app

COPY --from=deps --chown=app:app /app/node_modules ./node_modules
COPY --from=builder --chown=app:app /app/dist ./dist
COPY --from=builder --chown=app:app /app/package.json ./

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

### Python Multi-Stage Build
```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim AS runner
WORKDIR /app
ENV PYTHONUNBUFFERED=1

RUN adduser --system --no-create-home app
USER app

COPY --from=builder /install /usr/local
COPY . .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Docker Compose (Development)
```yaml
# docker-compose.yml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: builder                # Use build stage for dev
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules           # Prevent overwriting node_modules
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/app_dev
      - REDIS_URL=redis://redis:6379
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: app_dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

## GitHub Actions CI/CD

### Complete CI Pipeline
```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint-and-typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run lint
      - run: npx tsc --noEmit

  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test
        ports:
          - 5432:5432
        options: >-
          --health-cmd "pg_isready -U test"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm test -- --coverage
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/test
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage
          path: coverage/

  build:
    runs-on: ubuntu-latest
    needs: [lint-and-typecheck, test]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run build

  deploy:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    needs: [build]
    environment: production
    steps:
      - uses: actions/checkout@v4
      # Add your deployment steps here
```

## Deployment Checklist

- [ ] Environment variables configured (not hardcoded)
- [ ] Health check endpoint (`/health` or `/api/health`)
- [ ] Graceful shutdown handling (SIGTERM)
- [ ] Database migrations run before app starts
- [ ] SSL/TLS configured
- [ ] Logging to stdout/stderr (container-friendly)
- [ ] Resource limits set (CPU, memory)
- [ ] Rollback strategy documented
- [ ] Monitoring/alerting configured
- [ ] Backup strategy for databases
