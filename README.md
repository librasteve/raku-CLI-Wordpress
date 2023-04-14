[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

# Raku CLI::Wordpress

This module provides a simple abstraction to the Wordpress command line interface (wpcli) for site launch and maintenance.

If you encounter a feature you want that's not implemented by this module (and there are many), please consider sending a pull request.

## Prerequisites
- ubuntu server with docker, docker-compose, raku and zef (e.g. by using [raws-ec2](https://github.com/p6steve/raku-CLI-AWS-EC2-Simple))
- located at a static IP address (e.g. ```raws-ec2 --eip launch```) with ssh access (e.g. via ```raws-ec2 connect```)
- domain name DNS set with A records @ and www to the target's IP address

## Getting Started
- ssh in and install CLI::Wordpress on server to get the rawp command ```zef install https://github.com/p6steve/raku-CLI-Wordpress.git``` _[or CLI::Wordpress]_
- edit ```vi ~/.rawp-config/wordpress-launch.yaml``` with your domain name and wordpress configuration
- launch a new instance of Wordpress & setup ssl certificate ```rawp setup && rawp launch && rawp renewal```
- configure your new Wordpress site frontend at https://yourdomain.com

## wordpress-launch.yaml
```yaml
instance:
  domain-name: your_domain
  admin-email: 'admin@your_domain'
  db-image: mysql:8.0
  wordpress-image: wordpress:php8.0-fpm-alpine
  webserver-image: nginx:1.15.12-alpine
  certbot-image: certbot/certbot
  wpcli-image: wordpress:cli-php8.0
  file_uploads: On
  memory_limit: 64M
  upload_max_filesize: 64M
  post_max_size: 64M
  max_execution_time: 600
  client_max_body_size: 64M
```

## WP CLI Examples
More examples can be found [here](./literature/wpcli.md)

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

## CMDs
- [x] setup       # position all config files for docker-compose and render wordpress-launch.yaml info
- [x] launch      # docker-compose up staging server, if OK then get ssl and restart
- [x] renewal     # configure crontab for ssl cert renewal
- [x] up          # docker-compose up -d
- [x] down        # docker-compose down
- [x] ps          # docker-compose ps
- [x] connect     # docker exec to wordpress server (get cmd as string)
- [x] wp 'cmd'    # run wpcli command - viz. https://developer.wordpress.org/cli/commands/
- [x] terminate   # rm volumes & reset

## Usage
```
  rawp <cmd> [<wp>]
  
    <cmd>     One of <setup launch renewal up down ps connect wp terminate>
    [<wp>]    A valid wp cli cmd (viz. https://developer.wordpress.org/cli/commands/)
```

## TODOs
- [ ] add git repo for /var/www/html (rawp git setup, clone, status, commit, push && pull)

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

### install git
apt-get update && apt-get upgrade -y
apt-get install vim git curl wget libicu-dev gnupg pass -y

### install gcm
cd ~
wget https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.0.935/gcm-linux_amd64.2.0.935.tar.gz
tar -xvf gcm-linux_amd64.2.0.935.tar.gz -C /usr/local/bin
git-credential-manager configure
git config --global credential.credentialStore gpg
gpg --gen-key
#### manual keygen
pass init p6steve
git config --global init.defaultBranch main
git config --global --add safe.directory /var/www/html
echo 'GPG_TTY=$(tty)' >> ~/.bashrc

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



iamerejh sort out wp-config && .htaccess
... git upload fpm (live) version

in wordpress service after chown
bash-5.1# ls -al
total 240
drwxr-xr-x    6 www-data www-data      4096 Apr 14 13:50 .
drwxr-xr-x    1 root     root          4096 Mar 29 22:51 ..
drwxr-xr-x    8 root     root          4096 Apr 14 13:51 .git
-rw-r--r--    1 xfs      xfs            261 Apr 14 13:50 .htaccess
-rw-r--r--    1 xfs      xfs            405 Apr 14 13:50 index.php
-rw-r--r--    1 xfs      xfs           7402 Apr 14 13:50 readme.html
-rw-r--r--    1 xfs      xfs           7205 Apr 14 13:50 wp-activate.php
drwxr-xr-x    9 xfs      xfs           4096 Apr 14 13:50 wp-admin
-rw-r--r--    1 xfs      xfs            351 Apr 14 13:50 wp-blog-header.php
-rw-r--r--    1 xfs      xfs           2338 Apr 14 13:50 wp-comments-post.php
-rw-r--r--    1 xfs      xfs           5492 Apr 14 13:50 wp-config-docker.php

in wordpress service before chown
root@dc0b10090647:/var/www/html# ls -al
total 260
drwxr-xr-x  5   82   82  4096 Apr 14 14:08 .
drwxr-xr-x  3 root root  4096 Apr 14 14:07 ..
-rw-r--r--  1   82   82   261 Mar 31 00:20 .htaccess
-rw-r--r--  1   82   82   405 Feb  6  2020 index.php
-rw-r--r--  1   82   82 19915 Jan  1 00:06 license.txt
-rw-r--r--  1   82   82  7402 Mar  5 00:52 readme.html
-rw-r--r--  1   82   82  7205 Sep 16  2022 wp-activate.php
drwxr-xr-x  9   82   82  4096 Mar 29 17:48 wp-admin
-rw-r--r--  1   82   82   351 Feb  6  2020 wp-blog-header.php
-rw-r--r--  1   82   82  2338 Nov  9  2021 wp-comments-post.php
-rw-rw-r--  1   82   82  5492 Mar 31 00:20 wp-config-docker.php
-rw-r--r--  1   82   82  3013 Feb 23 10:38 wp-config-sample.php
-rw-r--r--  1   82   82  5596 Apr 14 14:07 wp-config.php
drwxr-xr-x  6   82   82  4096 Apr 14 14:12 wp-content
-rw-r--r--  1   82   82  5536 Nov 23 15:43 wp-cron.php
drwxr-xr-x 28   82   82 16384 Mar 29 17:48 wp-includes
-rw-r--r--  1   82   82  2502 Nov 26 21:01 wp-links-opml.php
-rw-r--r--  1   82   82  3792 Feb 23 10:38 wp-load.php
-rw-r--r--  1   82   82 49330 Feb 23 10:38 wp-login.php
-rw-r--r--  1   82   82  8541 Feb  3 13:35 wp-mail.php
-rw-r--r--  1   82   82 24993 Mar  1 15:05 wp-settings.php
-rw-r--r--  1   82   82 34350 Sep 17  2022 wp-signup.php
-rw-r--r--  1   82   82  4889 Nov 23 15:43 wp-trackback.php
-rw-r--r--  1   82   82  3238 Nov 29 15:51 xmlrpc.php


in git service before chown
root@dc0b10090647:/var/www/html# ls -al
total 240
drwxr-xr-x  6   82   82  4096 Apr 14 14:28 .
drwxr-xr-x  3 root root  4096 Apr 14 14:07 ..
drwxr-xr-x  8 root root  4096 Apr 14 14:28 .git
-rw-r--r--  1 root root   261 Apr 14 14:28 .htaccess
-rw-r--r--  1 root root   405 Apr 14 14:28 index.php
-rw-r--r--  1 root root  7402 Apr 14 14:28 readme.html
-rw-r--r--  1 root root  7205 Apr 14 14:28 wp-activate.php
drwxr-xr-x  9 root root  4096 Apr 14 14:28 wp-admin
-rw-r--r--  1 root root   351 Apr 14 14:28 wp-blog-header.php
-rw-r--r--  1 root root  2338 Apr 14 14:28 wp-comments-post.php
-rw-r--r--  1 root root  5492 Apr 14 14:28 wp-config-docker.php



### Copyright
copyright(c) 2023 Henley Cloud Consulting Ltd.
