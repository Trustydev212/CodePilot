---
name: i18n
description: "Internationalization management. Extract strings, sync translations, detect missing keys, set up i18n frameworks."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /i18n — Internationalization Management

Manage translations, extract strings, sync locales, detect missing keys.

## Usage

```
/i18n setup                    # Set up i18n framework (next-intl, react-i18next, vue-i18n)
/i18n extract                  # Extract hardcoded strings from components
/i18n sync                     # Sync translation files across locales
/i18n check                    # Detect missing/unused translation keys
/i18n add <locale>             # Add a new locale with all existing keys
```

## Execution Protocol

### Phase 1: Detect i18n Stack

Auto-detect from dependencies:
- `next-intl` → Next.js App Router i18n
- `react-i18next` / `i18next` → React i18n
- `vue-i18n` → Vue/Nuxt i18n
- `@formatjs/intl` → FormatJS/react-intl
- None found → recommend and set up

### Phase 2: Execute Command

#### Setup (`/i18n setup`)

1. Install appropriate i18n library
2. Create translation directory structure:
   ```
   messages/
   ├── en.json
   ├── vi.json
   └── ja.json
   ```
3. Configure provider/middleware
4. Add locale switching component pattern

**Next.js (next-intl):**
```typescript
// i18n/config.ts
export const locales = ['en', 'vi', 'ja'] as const
export const defaultLocale = 'en' as const
export type Locale = (typeof locales)[number]

// middleware.ts
import createMiddleware from 'next-intl/middleware'
import { locales, defaultLocale } from './i18n/config'

export default createMiddleware({ locales, defaultLocale })
export const config = { matcher: ['/((?!api|_next|.*\\..*).*)'] }
```

**React (react-i18next):**
```typescript
import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import en from '../messages/en.json'

i18n.use(initReactI18next).init({
  resources: { en: { translation: en } },
  lng: 'en',
  fallbackLng: 'en',
  interpolation: { escapeValue: false }
})
```

#### Extract (`/i18n extract`)

1. Scan all component files for hardcoded strings
2. Skip: code comments, console.log, class names, data-testid
3. Generate translation keys (dot notation by component)
4. Replace hardcoded strings with `t('key')` calls
5. Add necessary imports

#### Sync (`/i18n sync`)

1. Read source locale (default: `en.json`)
2. Compare keys with each target locale
3. Add missing keys with `[NEEDS TRANSLATION]` marker
4. Flag extra keys

#### Check (`/i18n check`)

1. Find all `t('key')` calls in code
2. Cross-reference with translation files
3. Report missing, unused, and inconsistent keys

## Rules

- NEVER delete existing translations
- Use dot notation for key hierarchy
- Source locale must always be 100% complete
- Mark untranslated strings with `[NEEDS TRANSLATION]`
- Preserve interpolation variables
- Sort keys alphabetically
