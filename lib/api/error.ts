/**
 * API Error Handling
 * Custom error class and error handling utilities for API requests
 */

/**
 * Custom error class for API-related errors
 */
export class ApiError extends Error {
  constructor(
    message: string,
    public statusCode?: number,
    public endpoint?: string
  ) {
    super(message)
    this.name = 'ApiError'
  }
}

/**
 * Handles API error responses and throws appropriate ApiError
 */
export async function handleApiError(
  response: Response,
  endpoint: string
): Promise<never> {
  let errorMessage = `API request failed: ${response.statusText}`

  try {
    const errorData = await response.json()
    if (errorData.message) {
      errorMessage = errorData.message
    } else if (errorData.detail) {
      errorMessage = errorData.detail
    }
  } catch {
    // If JSON parsing fails, use default error message
  }

  throw new ApiError(errorMessage, response.status, endpoint)
}
