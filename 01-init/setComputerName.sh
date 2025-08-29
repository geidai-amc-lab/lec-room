# 変更したい新しい名前
NEW_NAME="AMCMAC-001"
# ComputerName を変更
sudo scutil --set ComputerName "$NEW_NAME"
# LocalHostName を変更 (Bonjour 名, xxx.local)
sudo scutil --set LocalHostName "$NEW_NAME"
# HostName を変更 (UNIX系コマンドが使う名前)
sudo scutil --set HostName "$NEW_NAME"
