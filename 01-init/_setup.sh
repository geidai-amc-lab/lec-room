target="/Users/amc-scripts"
resource="https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init"

mkdir $target
chmod u+w $target

curl -fsSL $resource/amcmac-init.sh --output $target/amcmac-init.sh
curl -fsSL $resource/add-login-item.sh --output $target/add-login-item.sh
curl -fsSL $resource/openLaunchAgents.command --output $target/openLaunchAgents.command

sh $target/add-login-item.sh $target/amcmac-init.sh
