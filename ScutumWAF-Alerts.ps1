# =========================
# Scutum 防御ログ一覧 取得テンプレート
# =========================
# PowerShell 7+ は既定 UTF-8 ですが、念のため明示
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Windows PowerShell (5.1) の場合はこれも設定
$OutputEncoding = [System.Text.Encoding]::UTF8

$ApiKey = "<YOUR_API_KEY>"
$UserId = "<YOUR_USER_ID>"
$HostFqdn = "<YOUR_HOST_FQDN>"

# 2) ベースURL（サポートサイトの記載に合わせて調整）
$BaseUrl = "https://api.scutum.jp/api/v1/alert"

# 3) クエリ条件（開始・終了時刻、対象サイトID等）
#$StartTime = (Get-Date).AddDays(-90).ToString("yyyy-MM-ddTHH:mm:ss")  # 例: 昨日から
#$EndTime   = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")              # 例: 今まで

$StartTime = "2025-11-01T00:00:00+09:00" 
$EndTime   = "2025-11-09T23:59:59+09:00"

# 5) HTTP ヘッダー（APIキー認証）
$Headers = @{
    "Host" = "api.scutum.jp"
    "X-Scutum-API-Key" = $ApiKey         # 仕様に合わせてヘッダー名を変更
    "Accept"    = "application/json"
}

Write-Output $StartTime
Write-Output $EndTime

# 全データを格納する配列
$allData = @()
$next_marker = $null
$truncated = $true
$loopCount = 0

# truncated が false になるまでループ
while ($truncated) {
    $loopCount++
    Write-Host "ループ ${loopCount} 回目の取得を開始..." -ForegroundColor Cyan
    
    # クエリ文字列の生成（URLエンコード適用）
    $encodedHost = [Uri]::EscapeDataString($HostFqdn)
    $encodedUserId = [Uri]::EscapeDataString($UserId)
    $encodedStartTime = [Uri]::EscapeDataString($StartTime)
    $encodedEndTime = [Uri]::EscapeDataString($EndTime)
    
    if ($null -ne $next_marker -and $next_marker -ne "") {
        $encodedMarker = [Uri]::EscapeDataString($next_marker)
        $qs = "host=$encodedHost&id=$encodedUserId&time_order=asc&from=$encodedStartTime&to=$encodedEndTime&marker=$encodedMarker"
    } else {
        $qs = "host=$encodedHost&id=$encodedUserId&time_order=asc&from=$encodedStartTime&to=$encodedEndTime"
    }
    $url = "$BaseUrl`?$qs"

    # リクエスト送信
    try {
        $obj = Invoke-RestMethod -Method GET -Uri $url -Headers $Headers -TimeoutSec 60

        # データを配列に追加
        if ($obj.data) {
            $allData += $obj.data
            Write-Host "  - 取得件数: $($obj.data.Count) 件 (累計: $($allData.Count) 件)" -ForegroundColor Green
        }

        # next_marker と truncated をチェック
        if ($obj.PSObject.Properties.Name -contains "next_marker" -and $obj.next_marker) {
            $next_marker = $obj.next_marker
            Write-Host "  - next_marker: $next_marker" -ForegroundColor Yellow
        } else {
            $next_marker = $null
        }

        # truncated フラグをチェック (存在しない場合は next_marker の有無で判断)
        if ($obj.PSObject.Properties.Name -contains "truncated") {
            $truncated = $obj.truncated
            Write-Host "  - truncated: $truncated" -ForegroundColor Yellow
        } else {
            # truncated プロパティがない場合は next_marker の有無で判断
            $truncated = ($null -ne $next_marker -and $next_marker -ne "")
        }

        # next_marker がなくなったらループ終了
        if ($null -eq $next_marker -or $next_marker -eq "") {
            $truncated = $false
            Write-Host "  - 全データ取得完了" -ForegroundColor Green
        }
    }
    catch {
        Write-Warning ("API 呼び出しエラー (ループ ${loopCount} 回目): {0}" -f $_.Exception.Message)
        break
    }
}

# 全データを結合してJSON保存
if ($allData.Count -gt 0) {
    try {
        $resultObj = @{
            total_count = $allData.Count
            data = $allData
        }
        
        $json = $resultObj | ConvertTo-Json -Depth 10

        $outfile = Join-Path $PWD ("scutum_alert_obj_{0}_{1}.json" -f (Get-Date -Format "yyyyMMddHHmmss"), $HostFqdn)
        [System.IO.File]::WriteAllText($outfile, $json, [System.Text.Encoding]::UTF8)

        Write-Host "`n=== 完了 ===" -ForegroundColor Cyan
        Write-Host "総取得件数: $($allData.Count) 件" -ForegroundColor Green
        Write-Host "ループ回数: $loopCount 回" -ForegroundColor Green
        Write-Host "保存先: $outfile" -ForegroundColor Green
    }
    catch {
        Write-Warning ("JSON保存エラー: {0}" -f $_.Exception.Message)
    }
} else {
    Write-Warning "取得データが0件でした"
}

