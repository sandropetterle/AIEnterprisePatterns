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
              "script-src 'self' 'unsafe-inline' 'unsafe-eval'",
              "style-src 'self' 'unsafe-inline'",
              "img-src 'self' data: https:",
              "font-src 'self' https://fonts.gstatic.com",
              // API backend + Azure Entra External ID endpoints
              "connect-src 'self' https://*.azurewebsites.net https://*.azurecontainerapps.io https://*.ciamlogin.com https://login.microsoftonline.com",
              // Entra External ID hosted sign-in page is loaded in a redirect (not a frame)
              "frame-src 'none'",
              "form-action 'self' https://*.ciamlogin.com",
            ].join('; ')
          },
          { key: 'Strict-Transport-Security', value: 'max-age=31536000; includeSubDomains' },
        ],
      },
    ]
  },
}

export default nextConfig
