import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener('turbo:load', () => {
  // 既存のドロップダウン初期化コード
  $('[data-toggle="dropdown"]').dropdown();

  // 既存の日付更新機能
  function updateDate() {
    const now = new Date();
    const today = now.toLocaleDateString("ja-JP", { timeZone: "Asia/Tokyo" });
    const dateElement = document.getElementById('current-date');
    if (dateElement) {
      dateElement.textContent = today;
    }
  }

  updateDate(); // ページ読み込み時に日付を更新
  setInterval(updateDate, 60000); // 1分ごとに日付を更新

  // アコーディオン機能の追加
  document.querySelectorAll('.part-title').forEach(title => {
    title.addEventListener('click', function(event) {
      event.stopPropagation(); // イベント伝播を停止
      const targetId = this.getAttribute('data-target');
      const targetElement = document.querySelector(targetId);
      if (targetElement) {
        // 開いている場合は閉じる、閉じている場合は開く
        targetElement.classList.toggle('collapse');
      }
    });
  });

  // モーダルを開く関数
  window.openModal = function(modalId) {
    var modal = document.querySelector(modalId);
    modal.style.display = "block";
  }

  // モーダルを閉じる関数
  window.closeModal = function(modalId) {
    var modal = document.querySelector(modalId);
    modal.style.display = "none";
  }

  // ウィンドウの外側をクリックしたときにモーダルを閉じる
  window.onclick = function(event) {
    if (event.target.classList.contains('modal')) {
      event.target.style.display = "none";
    }
  }
});