// app/javascript/application.js
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener('turbo:load', () => {
  // ドロップダウンを初期化
  $('[data-toggle="dropdown"]').dropdown();

  function updateDate() {
    const now = new Date();
    const today = now.toLocaleDateString("ja-JP", { timeZone: "Asia/Tokyo" });
    // 日付が表示されるDOM要素を更新
    const dateElement = document.getElementById('current-date');
    if (dateElement) {
      dateElement.textContent = today;
    }
  }

  // ページ読み込み時に日付を更新
  updateDate();

  // 1分ごとに日付を更新
  setInterval(updateDate, 60000);
});