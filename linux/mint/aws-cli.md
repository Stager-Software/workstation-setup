### AWS CLI
Our Release Management Tool relies on the AWS CLI to do various tasks. For Mint, the AWS CLI can be installed using Homebrew, which can be installed with the following command:
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

> **_NOTE:_** This can throw a `connection terminated by remote host` error. This has something to do with your current git settings, but can be fixed by temporarily changing the DNS server to `8.8.8.8`. Do this by opening **Network**, going to your current network, be it wireless or wired, and then clicking the gearwheel in the bottom right corner. There you can go to IPv4, disable automatic DNS and enter `8.8.8.8`. Disable IPv6 fully as we do not have the IPv6 server address of that DNS. Then re-run the command, see it finish and reset you DNS settings. 

Next, add Homebrew to path, install the AWS CLI and permanently add both to PATH by running the following commands. We update the path in `.zshrc` to keep removal as easy as possible in case this AWS-CLI version and Homebrew are no longer needed in the future. If you do not have zsh, you can replace it by `.bashrc` (although zsh is always recommended).
```sh
PATH="/home/linuxbrew/.linuxbrew/bin/brew:$PATH"
brew install awscli
echo 'export PATH="/home/linuxbrew/.linuxbrew/opt/awscli@1/bin:/home/linuxbrew/.linuxbrew/bin/brew:$PATH"' >> ~/.zshrc  
```