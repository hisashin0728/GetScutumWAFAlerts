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
スクリプト内のパラメータとして、``$ApiKey``, ``$UserId``, ``$HostFqdn`` を変数に用いています。

```powershell
$ApiKey = "<Your API Key>"
$UserId = "<Your User Id>"
$HostFqdn = "<Your Host FQDN>"
```
