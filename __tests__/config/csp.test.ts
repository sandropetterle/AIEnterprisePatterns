/**
 * CSP connect-src Tests (BSW-0002: vote-csp-connect-src-blocked)
 *
 * The Content-Security-Policy in `next.config.mjs` allow-lists the production
 * API origins (`*.azurecontainerapps.io`, `*.azurewebsites.net`) but the app
 * actually calls whatever `NEXT_PUBLIC_API_BASE_URL` points at. When that is
 * a local backend (`http://localhost:5255/api` in dev, prod-build E2E, and
 * Lighthouse CI), client-side fetches — e.g. the vote POST — were blocked by
 * `connect-src`. The configured API origin must therefore always be derived
 * into the allow-list. Note: gating on NODE_ENV cannot express "non-prod"
 * here because `next build` forces NODE_ENV=production.
 */

import nextConfig from '@/next.config.mjs'

/** Resolve the connect-src directive of the global CSP header. */
async function getConnectSrc(): Promise<string> {
  const routes = await nextConfig.headers!()
  const globalRoute = routes.find((route) => route.source === '/(.*)')
  const csp = globalRoute?.headers.find(
    (header) => header.key === 'Content-Security-Policy'
  )
  const directive = csp?.value
    .split('; ')
    .find((d) => d.startsWith('connect-src'))
  if (!directive) throw new Error('connect-src directive not found in CSP')
  return directive
}

describe('CSP connect-src derives the configured API origin', () => {
  const originalApiBaseUrl = process.env.NEXT_PUBLIC_API_BASE_URL

  afterEach(() => {
    if (originalApiBaseUrl === undefined) {
      delete process.env.NEXT_PUBLIC_API_BASE_URL
    } else {
      process.env.NEXT_PUBLIC_API_BASE_URL = originalApiBaseUrl
    }
  })

  it('includes the origin of NEXT_PUBLIC_API_BASE_URL (path stripped)', async () => {
    process.env.NEXT_PUBLIC_API_BASE_URL = 'http://localhost:5255/api'

    const connectSrc = await getConnectSrc()

    expect(connectSrc.split(' ')).toContain('http://localhost:5255')
    expect(connectSrc).not.toContain('http://localhost:5255/api')
  })

  it('keeps the static production allow-list intact alongside the derived origin', async () => {
    process.env.NEXT_PUBLIC_API_BASE_URL = 'http://localhost:5255/api'

    const connectSrc = await getConnectSrc()

    expect(connectSrc).toContain("'self'")
    expect(connectSrc).toContain('https://*.azurewebsites.net')
    expect(connectSrc).toContain('https://*.azurecontainerapps.io')
    expect(connectSrc).toContain('https://*.ciamlogin.com')
    expect(connectSrc).toContain('https://login.microsoftonline.com')
  })

  it('does not duplicate an origin already in the allow-list', async () => {
    process.env.NEXT_PUBLIC_API_BASE_URL = 'https://login.microsoftonline.com/api'

    const connectSrc = await getConnectSrc()

    const occurrences = connectSrc
      .split(' ')
      .filter((src) => src === 'https://login.microsoftonline.com')
    expect(occurrences).toHaveLength(1)
  })

  it('falls back to the static allow-list when NEXT_PUBLIC_API_BASE_URL is unset', async () => {
    delete process.env.NEXT_PUBLIC_API_BASE_URL

    const connectSrc = await getConnectSrc()

    expect(connectSrc).not.toContain('localhost')
    expect(connectSrc).toContain('https://*.azurecontainerapps.io')
  })

  it('ignores an unparseable NEXT_PUBLIC_API_BASE_URL instead of throwing', async () => {
    process.env.NEXT_PUBLIC_API_BASE_URL = 'not-a-valid-url'

    const connectSrc = await getConnectSrc()

    expect(connectSrc).not.toContain('not-a-valid-url')
    expect(connectSrc).toContain('https://*.azurecontainerapps.io')
  })
})
