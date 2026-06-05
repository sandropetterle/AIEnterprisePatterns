'use client'

import { useEffect, useState, type ComponentType } from 'react'

type ToasterComponent = ComponentType<{ position?: 'bottom-right' }>

/**
 * Idle-mounted sonner Toaster.
 *
 * Sonner is only needed once a toast actually fires (always after user
 * interaction), so loading it eagerly puts ~50KB of script on the home page's
 * startup path for nothing. Deferring the dynamic import until the browser is
 * idle keeps sonner out of the first-load bundle and off the LCP/TBT-critical
 * main-thread window (see TDL: home-page LCP on constrained CPUs).
 *
 * Sharing note: `toast()` callers (VotingButton, PatternForm, …) statically
 * import sonner into their own chunks, but Turbopack registers the module
 * under one ID, so this lazy import resolves the exact same instance —
 * verified via chunk module-ID inspection + a live toast end-to-end check.
 */
export function LazyToaster() {
  const [Toaster, setToaster] = useState<ToasterComponent | null>(null)

  useEffect(() => {
    let cancelled = false
    const load = () => {
      import('sonner').then((mod) => {
        if (!cancelled) setToaster(() => mod.Toaster)
      })
    }

    if (typeof window.requestIdleCallback === 'function') {
      const id = window.requestIdleCallback(load)
      return () => {
        cancelled = true
        window.cancelIdleCallback(id)
      }
    }

    // Safari has no requestIdleCallback — mount shortly after hydration
    const id = window.setTimeout(load, 2000)
    return () => {
      cancelled = true
      window.clearTimeout(id)
    }
  }, [])

  return Toaster ? <Toaster position="bottom-right" /> : null
}
