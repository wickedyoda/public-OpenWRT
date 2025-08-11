# pull locally:

`sudo curl -s https://raw.githubusercontent.com/wickedyoda/public-OpenWRT/refs/heads/main/update-from_repo.sh | sudo sh`

https://github.com/wickedyoda/public-OpenWRT.git

# Fresh ROuters:
`opkg update && opkg install git git-http ca-bundle ca-certificates libcurl4 && \
wget -qO- https://raw.githubusercontent.com/wickedyoda/public-OpenWRT/refs/heads/main/update-from_repo.sh | sh`