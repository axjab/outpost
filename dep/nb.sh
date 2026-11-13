# install using curl
sudo curl --fail --silent --show-error --location https://raw.githubusercontent.com/xwmx/nb/master/nb -o /usr/local/bin/nb &&
  sudo chmod +x /usr/local/bin/nb &&
  sudo env EDITOR="${EDITOR:-hx}" VISUAL="${VISUAL:-hx}" nb completions install --download
