---
profile: expo-react-native
role: mobile
check-root: node
status: written
---

# `expo-react-native` (mobile)

- **Root files**: `package.json` (`"main": "expo-router/entry"`), `pnpm-lock.yaml`, `.npmrc`
  (`node-linker=hoisted` unless the current Expo SDK docs say isolated pnpm installs are
  supported; check at scaffold time), `tsconfig.json`, `app.config.ts`,
  `eas.json`, `eslint.config.js`, `jest.config.js`, `babel.config.js` and `metro.config.js`
  only if customized. Expo/Metro create `.expo/` (ignored).
- **Source**: `src/app/` (expo-router routes; Expo supports `src/app`) · `src/features/<area>/`
  · `src/lib/` (API client on `{{scope}}/contracts`, TanStack Query) · `src/ui/` ·
  `src/auth/` (OIDC + PKCE via `expo-auth-session`, tokens in `expo-secure-store`) ·
  `src/assets/` (referenced from `app.config.ts`).
- **Boundaries**: same as `react-vite` (contracts only; fetch only in `lib/`; `ui/` generic);
  no secrets in `app.config.ts` (use EAS secrets).
- **Tests**: Jest via `jest-expo` + React Native Testing Library (Expo's supported runner);
  `tests/unit/app/index.test.tsx` renders the home route.
- **Container**: none (mobile builds run on EAS Build or locally). No `docker/` folder.
- **CI**: install · lint · typecheck · test · check-root · `npx expo-doctor`; on a release
  tag, `eas build` (needs `EXPO_TOKEN`; ask before adding) and optional `eas submit`.
- **Verify**: `pnpm install && pnpm lint && pnpm typecheck && pnpm test && pnpm check:root
  && npx expo-doctor`; `npx expo export --platform ios` as a build smoke test if time allows.
- **Health path**: home route renders and calls the api `/healthz` (mocked in tests).
