/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: 'standalone', // Optimized build for Docker and Azure App Service
}

export default nextConfig
