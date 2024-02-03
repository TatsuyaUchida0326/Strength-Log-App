import "@hotwired/turbo-rails";

// 1RMを計算する関数
window.calculateOneRM = function(weight, reps) {
  return (weight * (reps / 40)) + weight;
};

// 入力値が変更されたときに1RMを計算し更新する関数
window.updateOneRM = function(inputElement) {
  var row = inputElement.parentNode.parentNode;
  var weight = row.querySelector('input[name="weight[]"]').value;
  var reps = row.querySelector('input[name="reps[]"]').value;

  if (weight && reps) {
    var oneRM = window.calculateOneRM(parseFloat(weight), parseInt(reps));
    row.querySelector('.one-rm-output').textContent = oneRM.toFixed(2) + ' kg';
  }
};

window.setExerciseId = function(exerciseId) {
  console.log(exerciseId); // コンソールにIDを出力する
  document.getElementById("exercise_id_field").value = exerciseId;
};

// 現在のセット数を追跡する変数
window.currentSetNumber = 1;

// 新しいトレーニング記録の行を追加する関数
window.addTrainingRecordRow = function() {
  var table = document.querySelector('.table.table-bordered tbody');
  
  // 既存のすべての削除ボタンを取り除く
  var existingButtons = table.querySelectorAll('button.remove-btn');
  existingButtons.forEach(function(button) {
    button.remove();
  });

  // 新しい行を作成
  var newRow = document.createElement('tr');
  newRow.innerHTML = '<td>' + window.currentSetNumber + '</td>' +
                     '<td><input type="number" name="weight[]" class="input-centered" oninput="updateOneRM(this)"><span class="unit-text">kg</span></td>' +
                     '<td><input type="number" name="reps[]" class="input-centered" oninput="updateOneRM(this)"><span class="unit-text">回</span></td>' +
                     '<td class="one-rm-output"></td>' + // 1RMの計算結果を表示する部分
                     '<td><input type="text" name="comment[]"></td>' +
                     '<td><button class="remove-btn" onclick="removeTrainingRecordRow(this)">削除</button></td>';
  table.appendChild(newRow);
  window.currentSetNumber++; // セット数をインクリメント
};

// 指定された行を削除する関数
window.removeTrainingRecordRow = function(button) {
  var row = button.parentNode.parentNode;
  var tbody = row.parentNode;
  tbody.removeChild(row);
  window.currentSetNumber--; // セット数をデクリメント

  // 削除後の最後尾に削除ボタンを追加する
  var lastRow = tbody.querySelector('tr:last-child');
  if (lastRow) {
    var lastCell = lastRow.querySelector('td:last-child');
    lastCell.innerHTML = '<button class="remove-btn" onclick="removeTrainingRecordRow(this)">削除</button>';
  }
};

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

  // フラッシュメッセージを非表示にする機能の追加
  document.addEventListener('click', () => {
    document.querySelectorAll('.alert').forEach(alert => {
      alert.style.display = 'none';
    });
  });

  // 新しいセットを追加するボタンにイベントリスナーを設定
  const addRecordButton = document.querySelector('#add-record');
  if (addRecordButton) {
    addRecordButton.addEventListener('click', () => {
      const recordsContainer = document.querySelector('#training-records');
      const allRecords = recordsContainer.querySelectorAll('.training-record-fields');
      const newSetNumber = allRecords.length + 1; // 新しいセット番号
      let newRecordFields = document.querySelector('.training-record-fields').cloneNode(true);

      // 新しいセット番号を設定
      let setField = newRecordFields.querySelector('input[id="set"]');
      setField.value = newSetNumber;
      setField.id = `set-${newSetNumber}`;

      // 新しいレコードフィールドにユニークなIDを与えます
      newRecordFields.querySelectorAll('input').forEach(input => {
        const inputType = input.id.replace(/-\d+$/, '');
        input.id = `${inputType}-${newSetNumber}`; // 新しいID
        if (inputType !== 'set') {
          input.value = ''; // セット番号以外は空にする
        }
      });

      // 新しいレコードフィールドを追加
      recordsContainer.appendChild(newRecordFields);

      // 既存のすべての削除ボタンを非表示にする
      document.querySelectorAll('.remove-record').forEach(button => {
        button.style.display = 'none';
      });

      // 新しいレコードの削除ボタンを表示
      newRecordFields.querySelector('.remove-record').style.display = 'inline-block';
    });
  }
  
  document.querySelectorAll('.btn-add').forEach(button => {
    button.addEventListener('click', (event) => {
      event.preventDefault(); // デフォルトの動作を停止
      const modalId = '#add-exercise-modal';
      openModal(modalId); // モーダルを開く
    });
  });
  
  function setExerciseId(exerciseId) {
      console.log(exerciseId); // 追加したログ出力
      document.getElementById("exercise_id_field").value = exerciseId;
  }

  // レコードの削除ボタンにイベントリスナーを設定
  document.addEventListener('click', (event) => {
    if (event.target.matches('.remove-record')) {
      event.target.closest('.training-record-fields').remove();

      // 削除後に最後のレコードの削除ボタンを表示する
      const allRecords = document.querySelectorAll('.training-record-fields');
      if (allRecords.length > 0) {
        // 以前の最後のレコードの削除ボタンを非表示にする
        allRecords.forEach((record, index) => {
          if (index !== allRecords.length - 1) {
            record.querySelector('.remove-record').style.display = 'none';
          } else {
            record.querySelector('.remove-record').style.display = 'inline-block';
          }
        });
      }
    }
  });
});

