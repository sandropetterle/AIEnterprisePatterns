import { defineConfig } from 'eslint/config';
import nextCoreWebVitals from 'eslint-config-next/core-web-vitals';
import nextTypescript from 'eslint-config-next/typescript';
import security from 'eslint-plugin-security';

// Flat config (ESLint 9 / Next 16). Next 16 removed `next lint`, and the
// legacy eslintrc bridge (@eslint/eslintrc) is broken by the repo-wide
// ajv@8 override, so this config must stay FlatCompat-free (issue #69).
export default defineConfig([
  ...nextCoreWebVitals,
  ...nextTypescript,
  {
    plugins: { security },
    rules: {
      'security/detect-object-injection': 'off',
      'security/detect-eval-with-expression': 'error',
      'security/detect-unsafe-regex': 'warn',
      'security/detect-non-literal-regexp': 'warn',
      'security/detect-possible-timing-attacks': 'warn',
    },
  },
]);
