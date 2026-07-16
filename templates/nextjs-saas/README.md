# {{PROJECT_NAME}} — Next.js SaaS

## Purpose

A production-ready SaaS starter built with Next.js 14 (App Router), TypeScript, Tailwind CSS, shadcn/ui, NextAuth.js, Prisma, and Stripe.

## Prerequisites

- Node.js 20+
- PostgreSQL 15+
- pnpm
- Stripe account (for payments)

## Setup

1. **Install dependencies**
   ```bash
   pnpm install
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env.local
   # Fill in: DATABASE_URL, NEXTAUTH_SECRET, STRIPE_SECRET_KEY, etc.
   ```

3. **Run database migrations**
   ```bash
   pnpm prisma migrate dev
   ```

4. **Start the development server**
   ```bash
   pnpm dev
   ```

## Project Structure

```
app/
  (auth)/            # Auth routes: login, register, forgot-password
  (dashboard)/       # Protected dashboard routes
  api/               # API route handlers
  layout.tsx         # Root layout
components/
  ui/                # shadcn/ui base components
  shared/            # Shared layout components
  features/          # Feature-specific components
lib/
  auth.ts            # NextAuth configuration
  db.ts              # Prisma client singleton
  stripe.ts          # Stripe client
prisma/
  schema.prisma      # Database schema
```

## Key Features

- **Authentication**: Email/password + OAuth via NextAuth.js
- **Subscriptions**: Stripe billing with webhook handling
- **Database**: Prisma ORM with PostgreSQL
- **UI**: shadcn/ui component library with Tailwind CSS
- **Email**: Transactional email with Resend

## Available Scripts

| Command | Description |
|---------|-------------|
| `pnpm dev` | Start dev server |
| `pnpm build` | Production build |
| `pnpm test` | Run tests |
| `pnpm prisma studio` | Open Prisma database UI |
| `pnpm stripe listen` | Forward Stripe webhooks |
