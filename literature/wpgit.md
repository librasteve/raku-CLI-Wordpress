## WP Git Capabilities

Three rawp commands are provided to help manage the Wordpress files in /var/www/html with https://github.com. 

These underpin git command line operations such as:
- git clone
- git status
- git commit
- git push
- git pull
- etc.

#git
## setup
### config
```yaml
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
```

## commands
- [x] ```rawp git``` will give this connection str=> ```sudo docker exec -it --workdir /var/www/html git "/bin/bash"```
- [ ] ```rawp git-setup``` includes manual gpg keygen steps for [git credentials manager](https://docs.github.com/en/get-started/getting-started-with-git/caching-your-github-credentials-in-git)
- [ ] ```rawp git-chown``` applies user www-data:www-data via wordpress service

## git-setup

### install and configure git & gcm
apt-get update && apt-get upgrade -y
apt-get install vim git curl wget libicu-dev gnupg pass -y
wget https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.0.935/gcm-linux_amd64.2.0.935.tar.gz
tar -xvf gcm-linux_amd64.2.0.935.tar.gz -C /usr/local/bin
git-credential-manager configure
git config --global credential.credentialStore gpg
git config --global init.defaultBranch main
git config --global --add safe.directory /var/www/html
echo 'GPG_TTY=$(tty)' >> ~/.bashrc

#### manual keygen
gpg --gen-key
pass init p6steve


## push wordpress files to (new) base repo

### make new empty repo (via github web)

### push wp to gh
git init
git branch -m main
git config --global --add safe.directory /var/www/html
git add --all
git commit -m "clone from image"
git remote add origin https://github.com/p6steve/wordpress-6.2-php8.0-fpm-alpine.git
git push -u origin main

## pull modified wordpress files

### fork base repo (via github web)

### pull wp to gh
cd /var/www/html
rm -rf *
git init .
git remote add -t \* -f origin https://github.com/p6steve/wp6.2-sarahroeassociates.co.uk.git
git checkout main

### then always (in wordpress service)
chown -R www-data:www-data *
chown -R www-data:www-data .htaccess


### operation
echo 'test' | test
git push
## manual credential entry (first time)


rawp git ===> sudo docker exec -it --workdir /var/www/html git "/bin/bash"



sudo docker exec -t --workdir /var/www/html git /bin/bash -c "echo 'test3' > test3 && ls"
sudo docker exec -t --workdir /var/www/html git /bin/bash -c "git add test2"
sudo docker exec -t --workdir /var/www/html git /bin/bash -c "git status"
sudo docker exec -t --workdir /var/www/html git /bin/bash -c "git commit -m 'ho'"

sudo docker exec -t --workdir /var/www/html git tty   ($TTY)
sudo docker exec -t --workdir /var/www/html git /bin/bash -c "export GPG_TTY=$TTY"
sudo docker exec -t --workdir /var/www/html git /bin/bash -c "git push"


https://stackoverflow.com/questions/9864728/how-to-get-git-to-clone-into-current-directory







viz. https://developer.wordpress.org/cli/commands/

```rawp wp '--help'```

Run ```rawp wp 'help <command>'``` to get more information on a specific command.

```rawp wp 'core version'```

6.2

```rawp wp '--info'```

```yaml
OS:	Linux 5.15.0-1031-aws #35-Ubuntu SMP Fri Feb 10 02:07:18 UTC 2023 x86_64
Shell:	
PHP binary:	/usr/local/bin/php
PHP version:	8.0.28
php.ini used:	
MySQL binary:	/usr/bin/mysql
MySQL version:	mysql  Ver 15.1 Distrib 10.6.12-MariaDB, for Linux (x86_64) using readline 5.1
SQL modes:	
WP-CLI root dir:	phar://wp-cli.phar/vendor/wp-cli/wp-cli
WP-CLI vendor dir:	phar://wp-cli.phar/vendor
WP_CLI phar path:	/var/www/html
WP-CLI packages dir:	
WP-CLI cache dir:	/.wp-cli/cache
WP-CLI global config:	
WP-CLI project config:	
WP-CLI version:	2.7.1
```

```rawp wp 'search-replace "test" "experiment" --dry-run'```

```text
Table	Column	Replacements	Type
wp_commentmeta	meta_key	0	SQL
wp_commentmeta	meta_value	0	SQL
wp_comments	comment_author	0	SQL
...
wp_links	link_rss	0	SQL
wp_options	option_name	0	SQL
wp_options	option_value	3	PHP
wp_options	autoload	0	SQL
...
wp_users	display_name	0	SQL
Success: 3 replacements to be made.
```



### Plugins

Zip file plugins need to be manually uploaded via the front end.

```rawp wp 'plugin list'```

```text
name	status	update	version
akismet	inactive	none	5.1
hello	inactive	none	1.7.2
updraftplus	inactive	none	2.23.3.1
```
```rawp wp 'plugin activate "increase-maximum-upload-file-size"'```
```rawp wp 'plugin delete "increase-maximum-upload-file-size"'```

### Volumes

Use ```rawp connect``` to get this hint... ```sudo docker exec -it --working-dir /var/www/html wordpress "/bin/bash"``` to enter the running wordpress filesystem

rawp wp 'plugin activate updraftplus'
rawp wp 'plugin get updraftplus'
rawp wp 'option list --search="updraft*"'