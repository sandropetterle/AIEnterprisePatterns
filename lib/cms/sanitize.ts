import DOMPurify from 'isomorphic-dompurify';

/**
 * Sanitizes CMS-provided HTML before rendering via dangerouslySetInnerHTML.
 * Defense-in-depth: strips XSS vectors even from the trusted admin-only CMS.
 */
export function sanitizeCmsHtml(html: string): string {
  return DOMPurify.sanitize(html);
}
