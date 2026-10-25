(function () {
    'use strict';

    const banner = document.querySelector('[data-post-banner]');
    if (!banner) return;

    const link = banner.querySelector('a');
    const image = banner.querySelector('img');
    const options = banner.querySelector('[data-banner-options]');
    if (!link || !image || !options) return;

    let banners;
    try {
        banners = JSON.parse(options.textContent);
    } catch (_) {
        return;
    }
    if (!Array.isArray(banners) || banners.length === 0) return;

    // Share one selection across all posts and tabs in this browser.
    const storageKey = 'jeho.page.post-banner.v1';
    const cacheDuration = 5 * 60 * 1000;

    function updateBanner() {
        let storage;
        let cached;
        try {
            storage = window.localStorage;
            cached = storage.getItem(storageKey);
        } catch (_) {
            // Keep the HTML fallback when browser storage is unavailable.
            return;
        }

        try {
            cached = JSON.parse(cached);
        } catch (_) {
            cached = null;
        }

        const now = Date.now();
        let selected;
        if (cached && Number.isFinite(cached.expiresAt) &&
            cached.expiresAt > now && cached.expiresAt <= now + cacheDuration) {
            selected = banners.find(function (option) {
                return option.id === cached.id;
            });
        }

        if (!selected) {
            selected = banners[Math.floor(Math.random() * banners.length)];
            try {
                storage.setItem(storageKey, JSON.stringify({
                    id: selected.id,
                    expiresAt: now + cacheDuration
                }));
            } catch (_) {
                return;
            }
        }

        link.setAttribute('href', selected.url);
        image.setAttribute('alt', selected.alt);
        image.setAttribute('src', selected.image);
        banner.setAttribute('aria-label', selected.name + ' 소개');
        banner.dataset.bannerId = selected.id;
    }

    updateBanner();

    // Recheck on back/forward restoration, without changing an open page on a timer.
    window.addEventListener('pageshow', function (event) {
        if (event.persisted) updateBanner();
    });
}());
