#!/bin/bash

# 遍歷所有 .rej 檔案
find . -name "*.rej" | while read rej; do
    # 找出對應的原始檔案名稱
    orig_file="${rej%.rej}"

    # 如果對應檔案不存在就略過
    [ ! -f "$orig_file" ] && echo "找不到 $orig_file，略過 $rej" && continue

    echo "處理 $rej ..."

    # 執行 wiggle 並捕捉輸出
    output=$(wiggle "$orig_file" "$rej" 2>&1)

    # 顯示 wiggle 輸出（可選）
    #echo "$output"

    # 判斷是否是 only already-applied
    if echo "$output" | grep -q "already-applied changes"; then
        if ! echo "$output" | grep -q "unresolved conflicts found"; then
            echo "✅ 已套用，無衝突，刪除 $rej"
            rm -f "$rej"
            rm -f "$orig_file.porig"
            #rm -f "${orig_file}.conflict"  # 若有多餘 conflict 檔也可順便清掉
        else
            echo "⚠️ 有衝突，保留 $rej"
        fi
    else
        echo "❌ Wiggle 無法處理，保留 $rej"
    fi
done
