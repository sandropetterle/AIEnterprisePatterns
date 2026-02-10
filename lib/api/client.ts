/**
 * Base HTTP Client
 * Generic fetch wrapper with timeout, error handling, and base URL configuration
 */

import { apiConfig } from './config'
import { handleApiError } from './error'

/**
 * Creates an AbortSignal that triggers after the specified timeout
 */
function createTimeoutSignal(timeout: number): AbortSignal {
  const controller = new AbortController()
  setTimeout(() => controller.abort(), timeout)
  return controller.signal
}

/**
 * Generic GET request
 */
async function get<T>(
  endpoint: string,
  options?: { timeout?: number }
): Promise<T> {
  const url = `${apiConfig.baseUrl}${endpoint}`
  const timeout = options?.timeout || apiConfig.timeout

  try {
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
      credentials: 'include',
      signal: createTimeoutSignal(timeout),
    })

    if (!response.ok) {
      await handleApiError(response, endpoint)
    }

    return await response.json()
  } catch (error) {
    if (error instanceof Error && error.name === 'AbortError') {
      throw new Error(`Request timeout after ${timeout}ms: ${endpoint}`)
    }
    throw error
  }
}

/**
 * Generic POST request
 */
async function post<T>(
  endpoint: string,
  body?: unknown,
  options?: { timeout?: number }
): Promise<T> {
  const url = `${apiConfig.baseUrl}${endpoint}`
  const timeout = options?.timeout || apiConfig.timeout

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      credentials: 'include',
      body: body ? JSON.stringify(body) : undefined,
      signal: createTimeoutSignal(timeout),
    })

    if (!response.ok) {
      await handleApiError(response, endpoint)
    }

    // Handle 204 No Content
    if (response.status === 204) {
      return {} as T
    }

    return await response.json()
  } catch (error) {
    if (error instanceof Error && error.name === 'AbortError') {
      throw new Error(`Request timeout after ${timeout}ms: ${endpoint}`)
    }
    throw error
  }
}

/**
 * Generic PUT request
 */
async function put<T>(
  endpoint: string,
  body: unknown,
  options?: { timeout?: number }
): Promise<T> {
  const url = `${apiConfig.baseUrl}${endpoint}`
  const timeout = options?.timeout || apiConfig.timeout

  try {
    const response = await fetch(url, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      credentials: 'include',
      body: JSON.stringify(body),
      signal: createTimeoutSignal(timeout),
    })

    if (!response.ok) {
      await handleApiError(response, endpoint)
    }

    return await response.json()
  } catch (error) {
    if (error instanceof Error && error.name === 'AbortError') {
      throw new Error(`Request timeout after ${timeout}ms: ${endpoint}`)
    }
    throw error
  }
}

/**
 * Generic DELETE request
 */
async function del(
  endpoint: string,
  options?: { timeout?: number }
): Promise<void> {
  const url = `${apiConfig.baseUrl}${endpoint}`
  const timeout = options?.timeout || apiConfig.timeout

  try {
    const response = await fetch(url, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
      },
      credentials: 'include',
      signal: createTimeoutSignal(timeout),
    })

    if (!response.ok) {
      await handleApiError(response, endpoint)
    }
  } catch (error) {
    if (error instanceof Error && error.name === 'AbortError') {
      throw new Error(`Request timeout after ${timeout}ms: ${endpoint}`)
    }
    throw error
  }
}

/**
 * Exported API client with HTTP methods
 */
export const apiClient = {
  get,
  post,
  put,
  delete: del,
}
