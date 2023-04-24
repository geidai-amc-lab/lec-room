# 起動時スクリプト


#### Setup
```
mkdir /Users/amc-scripts

curl -fsSL https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init/amcmac-init.sh --output /Users/amc-scripts/amcmac-init.sh
curl -fsSL https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init/add-login-item.sh --output /Users/amc-scripts/add-login-item.sh
sh /Users/amc-scripts/add-login-item.sh /Users/amc-scripts/amcmac-init.sh
```

#### Test
```
  sh -c "$(curl -fsSl https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init/amcmac-remote-init.sh
)"
```
