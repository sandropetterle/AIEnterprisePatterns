import { render, act, waitFor, cleanup } from '@testing-library/react'
import { LazyToaster } from '../LazyToaster'

// Mock sonner at file level (ESM package — repo convention)
jest.mock('sonner', () => ({
  Toaster: ({ position }: { position?: string }) => (
    <div data-testid="sonner-toaster" data-position={position} />
  ),
}))

type IdleCallback = () => void

describe('LazyToaster', () => {
  afterEach(() => {
    // Unmount before removing the stubs — the effect cleanup calls
    // cancelIdleCallback, which must still exist at that point.
    cleanup()
    // requestIdleCallback is not implemented by jsdom; remove any test stub
    delete (window as { requestIdleCallback?: unknown }).requestIdleCallback
    delete (window as { cancelIdleCallback?: unknown }).cancelIdleCallback
    jest.useRealTimers()
  })

  function stubIdleCallback() {
    const callbacks: IdleCallback[] = []
    const cancelIdleCallback = jest.fn()
    Object.defineProperty(window, 'requestIdleCallback', {
      configurable: true,
      writable: true,
      value: jest.fn((cb: IdleCallback) => {
        callbacks.push(cb)
        return callbacks.length
      }),
    })
    Object.defineProperty(window, 'cancelIdleCallback', {
      configurable: true,
      writable: true,
      value: cancelIdleCallback,
    })
    return { callbacks, cancelIdleCallback }
  }

  it('renders nothing until the browser is idle', () => {
    stubIdleCallback()
    const { queryByTestId } = render(<LazyToaster />)
    expect(queryByTestId('sonner-toaster')).toBeNull()
  })

  it('mounts the Toaster at bottom-right once idle', async () => {
    const { callbacks } = stubIdleCallback()
    const { queryByTestId } = render(<LazyToaster />)

    await act(async () => {
      callbacks.forEach((cb) => cb())
    })

    await waitFor(() => {
      expect(queryByTestId('sonner-toaster')).not.toBeNull()
    })
    expect(queryByTestId('sonner-toaster')).toHaveAttribute('data-position', 'bottom-right')
  })

  it('falls back to a timeout when requestIdleCallback is unavailable', async () => {
    jest.useFakeTimers()
    const { queryByTestId } = render(<LazyToaster />)
    expect(queryByTestId('sonner-toaster')).toBeNull()

    await act(async () => {
      jest.runAllTimers()
    })

    expect(queryByTestId('sonner-toaster')).not.toBeNull()
  })

  it('cancels the pending idle mount on unmount', () => {
    const { callbacks, cancelIdleCallback } = stubIdleCallback()
    const { unmount } = render(<LazyToaster />)
    unmount()
    expect(cancelIdleCallback).toHaveBeenCalled()
    // Firing the captured callback after unmount must not throw or warn
    expect(() => callbacks.forEach((cb) => cb())).not.toThrow()
  })
})
