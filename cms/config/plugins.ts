export default ({ env }) => {
  const config: Record<string, unknown> = {};

  // Azure Blob Storage upload provider — enabled when AZURE_STORAGE_ACCOUNT is set (production).
  // Falls back to local filesystem in development (default Strapi behaviour).
  if (env('AZURE_STORAGE_ACCOUNT')) {
    config.upload = {
      config: {
        provider: 'strapi-provider-upload-azure-storage-v5',
        providerOptions: {
          account: env('AZURE_STORAGE_ACCOUNT'),
          accountKey: env('AZURE_STORAGE_ACCOUNT_KEY'),
          containerName: env('AZURE_STORAGE_CONTAINER'),
          defaultPath: env('AZURE_STORAGE_DEFAULT_PATH', 'assets'),
          serviceBaseURL: env(
            'AZURE_STORAGE_URL',
            `https://${env('AZURE_STORAGE_ACCOUNT')}.blob.core.windows.net`
          ),
          sasToken: env('AZURE_STORAGE_SAS_TOKEN', ''),
          sizeLimit: env.int('AZURE_UPLOAD_SIZE_LIMIT', 10 * 1024 * 1024),
        },
        actionOptions: {
          upload: {},
          uploadStream: {},
          delete: {},
        },
      },
    };
  }

  return config;
};
