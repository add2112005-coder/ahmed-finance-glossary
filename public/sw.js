// Robust PWA service worker: one missing/slow optional asset must not block installation.
const CACHE = 'ahmed-finance-glossary-v3';
const SHELL = [
  '/index.html',
  '/search.html',
  '/term.html',
  '/review-dashboard.html',
  '/manifest.webmanifest',
  '/icon-192.png',
  '/icon-512.png',
  '/apple-touch-icon.png'
];

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    // Cache resources individually. A missing file or network timeout is non-fatal.
    for (const path of SHELL) {
      try {
        const controller = new AbortController();
        const timer = setTimeout(() => controller.abort(), 7000);
        const response = await fetch(path, { cache: 'reload', signal: controller.signal });
        clearTimeout(timer);
        if (response.ok && response.type !== 'opaque') {
          await cache.put(path, response);
        }
      } catch (error) {
        // Continue installing; online navigation remains available for uncached files.
      }
    }
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter(key => key.startsWith('ahmed-finance-glossary-') && key !== CACHE)
      .map(key => caches.delete(key)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', event => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== 'GET' || url.origin !== self.location.origin || url.pathname.startsWith('/api/')) return;
  event.respondWith((async () => {
    try {
      const response = await fetch(request);
      if (response && response.ok && response.type !== 'opaque') {
        const copy = response.clone();
        caches.open(CACHE).then(cache => cache.put(request, copy)).catch(() => {});
      }
      return response;
    } catch (error) {
      const cached = await caches.match(request);
      if (cached) return cached;
      if (request.mode === 'navigate') {
        const home = await caches.match('/index.html');
        if (home) return home;
      }
      return new Response('You are offline and this page is not cached yet.', {
        status: 503,
        headers: { 'Content-Type': 'text/plain; charset=utf-8' }
      });
    }
  })());
});
