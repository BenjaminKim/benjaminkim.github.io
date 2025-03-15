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
    trackButtonClick('footer-rss', 'footer_rss');
    trackButtonClick('footer-linkedin', 'footer_linkedin');
    trackButtonClick('footer-threads', 'footer_threads');
    trackButtonClick('footer-twitter', 'footer_twitter');
    trackButtonClick('footer-github', 'footer_github');
    trackButtonClick('awesome-rss-button', 'awesome_button');
    trackButtonClick('jeho-email', 'jeho_email_button');
    trackButtonClick('footer-coffee-app', 'footer_coffee_app');
    trackButtonClick('footer-awesome-blogs-app', 'footer_awesome_blogs_app');
    trackButtonClick('footer-spellstart-app', 'footer_spellstart_app');
    trackButtonClick('about-coffee-app', 'about_coffee_app');
    trackButtonClick('about-building-blog', 'about_building_blog');
    trackButtonClick('about-jocoding-v1', 'about_jocoding_v1');
    trackButtonClick('about-jocoding-v2', 'about_jocoding_v2');
    trackButtonClick('about-kimdante', 'about_kimdante');
});