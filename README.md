# lec-room
AMC演習室PCを管理するためのスクリプトなどを置いていくリポジトリです。(2023.04 川田)

# 運用方針
- このリポジトリにはpublicにしてよいものだけを置く。
  - パスワードが記載されたファイルをアップロードしない。（.gitignoreする）
  - ネットワーク構成などが類推できそうなものは出来るだけ置かない。
  
# よく使う （コピペ用）

```
## DeepFreeze解除
/Library/Zool/sbin/df_disable.sh

## DeepFreeze保護
/Library/Zool/sbin/df_enable.sh
```

# テクニック
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ytr0/setup/main/AllowFullDiskAccessTerminal.sh)"
