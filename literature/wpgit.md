# CLI::Wordpress Git Details

## Commands
Three ```rawp``` commands are provided to help manage the Wordpress files in /var/www/html with [github]( https://github.com)
- [x] ```rawp git``` get the git service connection string ```sudo docker exec -it --workdir /var/www/html git "/bin/bash"```
- [x] ```rawp git-setup``` installs the git cli and [git credentials manager](https://docs.github.com/en/get-started/getting-started-with-git/caching-your-github-credentials-in-git) 
- [x] ```rawp git-chown``` adjusts file permissions to ```www-data:www-data``` in the wordpress service

## Operation

This typical sequence of git operations can be performed from the command line of your Wordpress host server:
- ```rawp ps``` <= check that the ```git``` service is ```Up```
- ```rawp git``` <= use the result to connect to the git service, then for example...
  - ```export GPG_TTY=$(tty)``` <= tell the gpg key which tty we are using
  - ```echo 'test' > test```
  - ```git add test```
  - ```git status```
  - ```git pull```
  - ```git commit -m 'note'```
  - ```git push```
- ```exit``` <= when done return to the main Wordpress server prompt
- ```rawp git-chown``` <= fix up Wordpress file permissions (IMPORTANT)

You may need to provide your gpg key passphrase for commands that write to github and to complete manual credential entry (first time) like this...

```text
Select an authentication method for 'https://github.com/':
  1. Device code (default)
  2. Personal access token
option (enter for default): 2
---
Enter GitHub personal access token for 'https://github.com/'...
Token: 
```

## Setup

When you ```rawp launch``` a Wordpress installation, it uses the docker-compose.yaml file which contains a git service (see below). Before the first use of rawp git, the following additional steps are needed at the Wordpress host server prompt:

- ```rawp git-setup```
- ```gpg --gen-key``` <= start manual GNU GPG keygen procedure
- ```pass init your_name```

## Handy Examples

### Pull (modified) Wordpress files from a GitHub repo

The default rawp Wordpress installation is based on the ```wordpress:php8.0-fpm-alpine``` Docker [image](https://hub.docker.com/_/wordpress) which is available as a base github repo [here](https://github.com/p6steve/wordpress-6.2-php8.0-fpm-alpine)

You are welcome to fork this base repo (via github web), or to overwrite one of your own via these steps at the git server prompt:

```shell
export GPG_TTY=$(tty)
rm -rf *
git init .
git remote add -t \* -f origin https://github.com/p6steve/wordpress-6.2-php8.0-fpm-alpine.git
git checkout main
````

Don't forget to ```rawp git-chown``` when you exit.

### Push (modified) Wordpress files to a (new) GitHub repo

First make an empty repo via GitHub web, then:

```shell
export GPG_TTY=$(tty)
git init .
git branch -m main
git config --global --add safe.directory /var/www/html
git add --all
git commit -m "clone from image"
git remote add origin https://github.com/p6steve/wordpress-6.2-php8.0-fpm-alpine.git
git push -u origin main
```

_This is the sequence used to build the base repo from the Docker image install set_

## Underlying Mechanisms
This section is for informational purposes only... this is the bit that CLI::Wordpress automates for you.

### Configuration Details
The git service is a vanilla ubuntu VM which has access to the shared volume containing the Wordpress files:

```yaml
#`/wordpress/docker-compose.yaml EXTRACT
# ...
git:
  depends_on:
  - wordpress
  image: ubuntu:latest
  container_name: git
  restart: unless-stopped
  command: tail -f /dev/null
  volumes:
  - wordpress:/var/www/html
  networks:
  - app-network
# ...
```

## Setup Details

After the Wordpress installation is launched and running, ```rawp git-setup``` will load dependency apt-get modules, install git command line and github credential manager and configure the git service:

```shell
apt-get update && apt-get upgrade -y
apt-get install vim git curl wget libicu-dev gnupg pass -y
wget https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.0.935/gcm-linux_amd64.2.0.935.tar.gz
tar -xvf gcm-linux_amd64.2.0.935.tar.gz -C /usr/local/bin
git-credential-manager configure
git config --global credential.credentialStore gpg
git config --global init.defaultBranch main
git config --global --add safe.directory /var/www/html
echo 'GPG_TTY=$(tty)' >> ~/.bashrc
```

## Permissions Details

The ```rawp git-chown``` command applies these operation on the _wordpress_ docker service
```shell
chown -R www-data:www-data *
chown -R www-data:www-data .htaccess
````










