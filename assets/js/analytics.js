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

    trackButtonClick('share-button', 'share_button');
    trackButtonClick('rss-button', 'rss_button');
    trackButtonClick('awesome-rss-button', 'awesome_button');
    trackButtonClick('jeho-email', 'jeho_email_button');
    trackButtonClick('coffee-app', 'coffee_app_button');
});