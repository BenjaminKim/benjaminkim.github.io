document.addEventListener('DOMContentLoaded', function () {
    function trackButtonClick(buttonId, eventName) {
        const button = document.getElementById(buttonId);

        if (button) {
            button.addEventListener('click', function () {
                const pageUrl = window.location.href;
                const pageTitle = document.title;

                gtag('event', eventName, {
                    'value': 1,
                    'page_title': pageTitle,
                    'page_url': pageUrl
                });
            });
        }
    }

    trackButtonClick('share-button', 'share_button_click');
    trackButtonClick('rss-button', 'rss_button_click');
    trackButtonClick('awesome-rss-button', 'awesome_button_click');
    trackButtonClick('coffee-app', 'coffee_button_click');
    trackButtonClick('jeho-email', 'email_button_click');
});