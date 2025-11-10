# GetScutumWAFAlerts
>本レポジトリは PowerShell で Scutum WAF アラートリストを取得するサンプルです

- 本スクリプトは Scutum WAF API の防御ログリストを REST API で取得して、JSON でローカルファイルに出力します。
- 防御ログリストと防御ログ詳細の違いは、HTTP リクエスト/レスポンスデータが含まれるか否かです
  - 今回はリクエスト内容は不要と判断して、ログリストを取得するサンプルになります。
- 参考 URL
  - [Scutum WAF API の概要と仕様](https://support.scutum.jp/manual/api/api-overview.html)
  - [Scutum WAF API 防御ログリストの取得](https://support.scutum.jp/manual/api/log-list.html)
  - [Scutum WAF API 防御ログ詳細の取得](https://support.scutum.jp/manual/api/log-detail.html)

# パラメータ

- スクリプト内のパラメータとして、``$ApiKey``, ``$UserId``, ``$HostFqdn`` を変数に用いています。

```powershell
$ApiKey = "<Your API Key>"
$UserId = "<Your User Id>"
$HostFqdn = "<Your Host FQDN>"
```

- 取得時間は現在から過去日時の設定で作成しています。（以下例では現時点から過去三か月）

```
$StartTime = (Get-Date).AddDays(-90).ToString("yyyy-MM-ddTHH:mm:ss")  # 例: 昨日から
$EndTime   = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")              # 例: 今まで
```

- 特定日時条件に合わせる場合は ISO 8601 形式で直接入れて下さい。
```
$StartTime = "2025-11-01T00:00:00+09:00" 
$EndTime   = "2025-11-09T23:59:59+09:00"
``` 

# スクリプト

- [ScutumWAF-Alerts.ps1](https://github.com/hisashin0728/GetScutumWAFAlerts/blob/main/ScutumWAF-Alerts.ps1)
