document.addEventListener('DOMContentLoaded', function () {
    function trackButtonClick(buttonId, eventLabel) {
        const button = document.getElementById(buttonId);

        if (button) {
            button.addEventListener('click', function () {
                const pageUrl = window.location.href; // 현재 페이지 URL
                const pageTitle = document.title; // 현재 페이지 제목

                // Google Analytics 이벤트 전송
                gtag('event', 'click', {
                    'event_category': 'Button',
                    'event_label': eventLabel,
                    'value': 1,
                    'page_title': pageTitle,
                    'page_url': pageUrl
                });
            });
        }
    }

    // 각 버튼에 대해 함수 호출
    trackButtonClick('share-button', 'Share Button');
    trackButtonClick('rss-button', 'Rss Button');
    trackButtonClick('awesome-rss-button', 'Awesome Rss Button');
});