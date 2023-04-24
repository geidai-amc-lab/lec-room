mkdir /Users/amc-scripts
uri="https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init"
target="/Users/amc-scripts"
chmod u+w $target

curl -fsSL $uri/amcmac-init.sh --output $target/amcmac-init.sh
curl -fsSL $uri/amcmac-init.sh --output $target/add-login-item.sh
