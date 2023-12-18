// app/javascript/controllers/training_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link"]

  connect() {
    // 初期化時に必要な処理があればここに書く
  }

  setActive(event) {
    event.preventDefault(); // デフォルトのリンク動作を停止
    this.linkTargets.forEach((link) => {
      link.classList.remove("active"); // すべてのタグから "active" クラスを削除
    });
    event.currentTarget.classList.add("active"); // クリックされたタグに "active" クラスを追加
  }
}
