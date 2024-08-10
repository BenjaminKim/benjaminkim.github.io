const shareButton = document.getElementById("share-button");
shareButton?.addEventListener("click", () => {
    const url = window.location.href;
    if (navigator.share) {
        navigator.share({
            title: document.title,
            url: url,
        });
    } else {
        navigator.clipboard
            .writeText(url)
            .then(() => {
                alert("링크를 복사했어요.");
            })
            .catch((error) => {
                console.error("클립보드에 복사 실패:", error);
                prompt("아래 링크를 복사하세요!", url);
            });
    }
});