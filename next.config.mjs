/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: 'standalone',
  images: {
    remotePatterns: [
      // Strapi CMS media (Azure Blob Storage)
      {
        protocol: 'https',
        hostname: 'staipatternsmedia.blob.core.windows.net',
      },
      // Strapi local development
      {
        protocol: 'http',
        hostname: 'localhost',
        port: '1337',
      },
    ],
  },
  async headers() {
    // BSW-0002: connect-src must allow the origin the app actually calls.
    // Derived from NEXT_PUBLIC_API_BASE_URL so local backends (e.g.
    // http://localhost:5255 in dev / prod-build E2E) aren't CSP-blocked.
    // NODE_ENV can't gate this: `next build` always sets it to 'production'.
    const connectSrc = [
      "'self'",
      'https://*.azurewebsites.net',
      'https://*.azurecontainerapps.io',
      'https://*.ciamlogin.com',
      'https://login.microsoftonline.com',
    ]
    if (process.env.NEXT_PUBLIC_API_BASE_URL) {
      try {
        const apiOrigin = new URL(process.env.NEXT_PUBLIC_API_BASE_URL).origin
        if (!connectSrc.includes(apiOrigin)) connectSrc.push(apiOrigin)
      } catch {
        // Unparseable URL — fall back to the static allow-list
      }
    }
    return [
      {
        source: '/(.*)',
        headers: [
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          { key: 'X-Frame-Options', value: 'DENY' },
          { key: 'X-XSS-Protection', value: '1; mode=block' },
          { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
          { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
          {
            key: 'Content-Security-Policy',
            value: [
              "default-src 'self'",
              // unsafe-eval retained: required by Next.js dev/build tooling; remove only after confirming zero CSP violations in prod
              "script-src 'self' 'unsafe-inline' 'unsafe-eval'",
              "style-src 'self' 'unsafe-inline'",
              // Narrowed from https: to specific CMS media origin
              "img-src 'self' data: https://staipatternsmedia.blob.core.windows.net",
              "font-src 'self' https://fonts.gstatic.com",
              // API backend + Azure Entra External ID endpoints
              `connect-src ${connectSrc.join(' ')}`,
              // Entra External ID hosted sign-in page is loaded in a redirect (not a frame)
              "frame-src 'none'",
              "form-action 'self' https://*.ciamlogin.com",
              "base-uri 'self'",
              "object-src 'none'",
            ].join('; ')
          },
          { key: 'Strict-Transport-Security', value: 'max-age=31536000; includeSubDomains' },
        ],
      },
    ]
  },
}

export default nextConfig
