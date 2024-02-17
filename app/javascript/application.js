import "@hotwired/turbo-rails";

document.addEventListener('turbo:load', () => {
  $('[data-toggle="dropdown"]').dropdown();
  
  function updateDate() {
    const now = new Date();
    const today = now.toLocaleDateString("ja-JP", { timeZone: "Asia/Tokyo" });
    const dateElement = document.getElementById('current-date');
    if (dateElement) {
      dateElement.textContent = today;
    }
  }

  updateDate();
  setInterval(updateDate, 60000);

  // アコーディオンの動作
  document.querySelectorAll('.part-title').forEach(title => {
    title.addEventListener('click', function(event) {
      event.stopPropagation();
      const targetId = this.getAttribute('data-target');
      const targetElement = document.querySelector(targetId);
      if (targetElement) {
        targetElement.classList.toggle('collapse');
        localStorage.setItem(targetId, targetElement.classList.contains('collapse') ? 'closed' : 'open');
      }
    });
  });

  document.querySelectorAll('.part-title').forEach(title => {
    const targetId = title.getAttribute('data-target');
    const targetElement = document.querySelector(targetId);
    const state = localStorage.getItem(targetId);
    if (state === 'open') {
      targetElement.classList.remove('collapse');
    } else if (state === 'closed') {
      targetElement.classList.add('collapse');
    }
  });
  
  // 既存および新規の削除ボタンにイベントリスナーを追加する
  addRemoveRecordEventListener();
  
  // 新しいトレーニングレコードの行を追加する機能
  const addRecordButton = document.getElementById('add-record');
  if (addRecordButton) {
    addRecordButton.addEventListener('click', (e) => {
      e.preventDefault();
      const tbody = document.getElementById('training-records');
      // 非表示にされていない行だけを対象にする
      const visibleRows = tbody.querySelectorAll('tr:not([style*="display: none"])');
      let newIndex = visibleRows.length; // 新しいインデックスは非表示にされていない行の数に基づく
  
      // 1RMの計算結果を表示するセルも含めた新しい行を追加
      const newRow = `
        <tr>
          <td>${newIndex + 1}</td>
          <td><input type="number" name="exercise[training_records_attributes][${newIndex}][weight]" class="form-control weight-input" /></td>
          <td><input type="number" name="exercise[training_records_attributes][${newIndex}][reps]" class="form-control reps-input" /></td>
          <td>
            <input type="hidden" name="exercise[training_records_attributes][${newIndex}][one_rm]" class="form-control one-rm-input" />
            <span class="one-rm-result"><!-- 1RMの計算結果がここに表示されます --></span>
          </td>
          <td><input type="text" name="exercise[training_records_attributes][${newIndex}][comment]" class="form-control" /></td>
          <td>
            <input type="hidden" name="exercise[training_records_attributes][${newIndex}][_destroy]" id="exercise_training_records_attributes_${newIndex}__destroy" value="0" class="destroy-flag">
            <button type="button" class="btn btn-danger remove-record"><i class="fas fa-trash"></i></button>
          </td>
        </tr>
      `;
      tbody.insertAdjacentHTML('beforeend', newRow);
      addRemoveRecordEventListener(); // 削除ボタンにイベントリスナーを再設定
      updateOneRMEventListener(); // 1RM計算機能のイベントリスナーを更新
    });
  }

  function addRemoveRecordEventListener() {
    document.querySelectorAll('.remove-record').forEach(button => {
      button.addEventListener('click', function(event) {
        event.preventDefault(); // デフォルトの動作を防ぐ
  
        const row = this.closest('tr');
        const tbody = row.closest('tbody');
        const destroyInput = row.querySelector('.destroy-flag');
        if (destroyInput) {
          destroyInput.value = "1"; // _destroy フィールドを "1" に設定
        }
        row.style.display = 'none'; // 行を非表示にする
  
        // 行が削除された後にセット番号を更新する
        updateSetNumbers(tbody);
      });
    });
  }
  
  function updateSetNumbers(tbody) {
    // 非表示になっていない行のみを対象にセット番号を更新
    const visibleRows = tbody.querySelectorAll('tr:not([style*="display: none"])');
    visibleRows.forEach((row, index) => {
      const setNumberCell = row.querySelector('td:first-child');
      if (setNumberCell) {
        setNumberCell.textContent = index + 1; // セット番号を1から順に更新
      }
    });
  }

  // 重量と回数の入力に基づいて1RMを計算し、表示する機能を更新する
  function updateOneRMEventListener() {
    document.querySelectorAll('.weight-input, .reps-input').forEach(input => {
      input.removeEventListener('input', calculateAndDisplayOneRM); // 既存のイベントリスナーを削除
      input.addEventListener('input', calculateAndDisplayOneRM); // 新しいイベントリスナーを追加
    });
  }

  // 重量と回数から1RMを計算し、結果を表示する関数
  function calculateAndDisplayOneRM() {
    const row = this.closest('tr');
    const weight = parseFloat(row.querySelector('.weight-input').value) || 0;
    const reps = parseInt(row.querySelector('.reps-input').value) || 0;
    // 新しい1RMの計算式に変更
    let oneRMResult = (weight * reps / 40) + weight;
    // 小数点第1位まで切り捨てる処理
    oneRMResult = Math.floor(oneRMResult * 10) / 10;
    // 表示用のspanタグに計算結果を表示
    const resultDisplay = row.querySelector('.one-rm-result');
    if (resultDisplay) {
      resultDisplay.textContent = oneRMResult; // toFixed(2)を使用しない
    }
    // hiddenフィールドに計算結果を設定
    const oneRmInput = row.querySelector('.one-rm-input');
    if (oneRmInput) {
      oneRmInput.value = oneRMResult; // 計算結果をhiddenフィールドにも設定
    }
  }
  
  function openEditModal(exerciseId) {
    // モーダルのID形式に注意してください。IDのプレフィックスが必要な場合は適宜調整してください。
    const modalSelector = `#modal-${exerciseId}`;
    openModal(modalSelector);
  }

  function openModal(modalSelector) {
    const modal = document.querySelector(modalSelector);
    if (modal) {
      modal.style.display = 'block';
    }
  }
  
  // モーダルの背景クリックで閉じる処理を追加
  document.querySelectorAll('.modal').forEach(modal => {
    modal.addEventListener('click', function(event) {
      // クリックされた要素がモーダル自体なら閉じる
      // (モーダルのコンテンツ部分のクリックは無視)
      if (event.target === modal) {
        closeModal(`#${modal.id}`);
      }
    });
  });

  // モーダルウィンドウを開く関数
  function openModal(modalSelector) {
      const modal = document.querySelector(modalSelector);
      if (modal) {
          modal.style.display = 'block';
          // モーダルウィンドウ外のクリックを検知して閉じるイベントリスナーを追加
          window.addEventListener('click', function(event) {
              if (event.target == modal) {
                  closeModal(modalSelector);
              }
          });
      }
  }

  // 既存トレーニング種目のIDをセットしてモーダルを開く関数
  window.setExerciseId = function(exerciseId) {
    const hiddenField = document.getElementById('exercise_id');
    if (hiddenField) {
      hiddenField.value = exerciseId;
    }
    openModal('#add-exercise-modal');
  };

  // フラッシュメッセージを非表示にする機能
  document.addEventListener('click', () => {
    document.querySelectorAll('.alert').forEach(alert => {
      alert.style.display = 'none';
    });
  });
});

// グローバルスコープでの関数定義
window.openModal = function(modalSelector) {
  const modal = document.querySelector(modalSelector);
  if (modal) {
    modal.style.display = 'block';
  }
};

window.closeModal = function(modalSelector) {
  const modal = document.querySelector(modalSelector);
  if (modal) {
    modal.style.display = 'none';
  }
};

// 既存トレーニング種目のIDをセットしてモーダルを開く関数
window.setExerciseId = function(exerciseId) {
  const hiddenField = document.getElementById('exercise_id');
  if (hiddenField) {
    hiddenField.value = exerciseId;
  }
  window.openModal(`#modal-${exerciseId}`);
};

// モーダル外の領域をクリックしたときにモーダルを閉じる処理
window.addEventListener('click', function(event) {
  // アクティブなモーダルを取得
  const activeModal = document.querySelector('.modal.show');
  if (activeModal && !activeModal.contains(event.target)) {
    // モーダルの内容を含まないクリックの場合、モーダルを閉じる
    activeModal.style.display = 'none';
  }
});

