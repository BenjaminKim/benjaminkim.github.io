document.addEventListener('DOMContentLoaded', function () {
    function trackButtonClick(buttonId, eventLabel) {
        const button = document.getElementById(buttonId);

        if (button) {
            button.addEventListener('click', function () {
                const pageUrl = window.location.href;
                const pageTitle = document.title;

                gtag('event', 'share', {
                    'event_category': 'Button',
                    'event_label': eventLabel,
                    'value': 1,
                    'page_title': pageTitle,
                    'page_url': pageUrl
                });
            });
        }
    }

    trackButtonClick('share-button', 'Share Button');
    trackButtonClick('rss-button', 'Rss Button');
    trackButtonClick('awesome-rss-button', 'Awesome Rss Button');
    trackButtonClick('jeho-email', 'Jeho Email Button');
    trackButtonClick('coffee-app', 'CoffeeApp Button');
});