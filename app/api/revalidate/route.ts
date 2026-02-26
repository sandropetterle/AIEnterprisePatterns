/**
 * Strapi on-demand revalidation webhook.
 *
 * Strapi calls this endpoint when content is published/updated/deleted.
 * We map the content type (model) to the Next.js paths that should be
 * revalidated, then call revalidatePath() to purge the ISR cache immediately.
 *
 * Configure in Strapi: Settings → Webhooks → Create webhook
 *   URL: https://<your-domain>/api/revalidate?secret=<REVALIDATE_SECRET>
 *   Events: Entry (publish, unpublish, update, delete)
 */

import { NextRequest, NextResponse } from 'next/server';
import { revalidatePath } from 'next/cache';

type RevalidationEntry = { path: string; type?: 'page' | 'layout' };

/**
 * Maps Strapi Single Type API IDs → Next.js paths to revalidate.
 * Use type='layout' to revalidate all pages nested under a path.
 */
const MODEL_PATHS: Record<string, RevalidationEntry[]> = {
  // Global (nav, footer) — revalidates every page via layout
  global: [{ path: '/', type: 'layout' }],

  // Marketing pages
  'home-page': [{ path: '/' }],
  'about-page': [{ path: '/about' }],
  'docs-page': [{ path: '/docs' }],

  // System pages
  'login-page': [{ path: '/login' }],
  'not-found-page': [{ path: '/' }],
  'error-page': [{ path: '/' }],

  // UI labels — revalidate entire /patterns subtree (listing + detail + forms)
  'pattern-listing-labels': [{ path: '/patterns', type: 'layout' }],
  'pattern-detail-labels': [{ path: '/patterns', type: 'layout' }],
  'pattern-form-labels': [{ path: '/patterns', type: 'layout' }],
};

const HANDLED_EVENTS = new Set([
  'entry.publish',
  'entry.update',
  'entry.unpublish',
  'entry.delete',
  'entry.create',
]);

export async function POST(request: NextRequest) {
  // Validate secret to prevent unauthorized cache busting
  const secret = request.nextUrl.searchParams.get('secret');
  if (!process.env.REVALIDATE_SECRET || secret !== process.env.REVALIDATE_SECRET) {
    return NextResponse.json({ message: 'Invalid or missing secret' }, { status: 401 });
  }

  let body: { model?: string; event?: string };
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ message: 'Invalid JSON body' }, { status: 400 });
  }

  const { model, event } = body;

  // Ignore non-content events (e.g. media uploads, relation changes)
  if (!event || !HANDLED_EVENTS.has(event)) {
    return NextResponse.json({ message: 'Event not handled', event }, { status: 200 });
  }

  const entries = model ? MODEL_PATHS[model] : undefined;
  if (!entries) {
    return NextResponse.json({ message: 'Model not handled', model }, { status: 200 });
  }

  for (const { path, type } of entries) {
    revalidatePath(path, type);
  }

  const paths = entries.map((e) => e.path);
  console.log(`[revalidate] model=${model} event=${event} paths=${paths.join(', ')}`);

  return NextResponse.json({ revalidated: true, model, event, paths });
}
