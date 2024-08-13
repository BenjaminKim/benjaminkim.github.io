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

    // 각 버튼에 대해 함수 호출
    trackButtonClick('share-button', 'share_button_click');
    trackButtonClick('rss-button', 'rss_button_click');
    trackButtonClick('awesome-rss-button', 'awesome_button_click');
});