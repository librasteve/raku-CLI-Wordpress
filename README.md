[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

# Raku CLI::Wordpress

This module provides a simple abstraction to the Wordpress command line interface (wpcli) for site launch and maintenance.

If you encounter a feature you want that's not implemented by this module (and there are many), please consider sending a pull request.

## Prerequisites
- ubuntu server with docker, docker-compose, raku and zef (e.g. by using [raws-ec2](https://github.com/librasteve/raku-CLI-AWS-EC2-Simple))
- located at a static IP address (e.g. via ```raws-ec2 --eip launch```) with ssh access (e.g. via ```raws-ec2 connect```)
- domain name DNS set with A records @ and www to the target's IP address

## Getting Started
- ssh in and install CLI::Wordpress on server to get the rawp command ```zef install https://github.com/librasteve/raku-CLI-Wordpress.git``` _[or CLI::Wordpress]_
- edit ```vi ~/.rawp-config/wordpress-launch.yaml``` with your domain name and wordpress configuration
- launch a new instance of Wordpress & setup ssl certificate with ```rawp setup && rawp launch && rawp renewal```
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

## WP Git Example
More details can be found [here](./literature/wpgit.md)

Setup git & gcm (first time only)...
- ```rawp ps``` <= check that the ```git``` service is ```Up```
- ```rawp git-setup```
- ```rawp git``` <= **connect** to the git service, then...
  - ```gpg --gen-key``` <= start manual GNU GPG keygen procedure
  - ```pass init your_name```
- ```exit``` <= when done return to the main Wordpress server prompt
- ```rawp git-chown``` <= fix up Wordpress file permissions (IMPORTANT)

Typical git sequence...

- ```rawp git``` <= **connect** to the git service, then...
    - ```export GPG_TTY=$(tty)``` <= tell the gpg key which tty we are using
    - ```echo 'test' > test```
    - ```git add test```
    - ```git status```
    - ```git pull```
    - ```git commit -m 'note'```
    - ```git push```
- ```exit``` <= when done return to the main Wordpress server prompt
- ```rawp git-chown``` <= fix up Wordpress file permissions (IMPORTANT)


## CMDs
- [x] setup       # prepare config files from wordpress-launch.yaml
- [x] launch      # docker-compose up staging server, if OK then get ssl and restart
- [x] renewal     # configure crontab for ssl cert renewal
- [x] up          # docker-compose up -d
- [x] down        # docker-compose down
- [x] ps          # docker-compose ps
- [x] connect     # docker exec to _wordpress_ service (get cmd as string)
- [x] wp 'cmd'    # run wpcli command - viz. https://developer.wordpress.org/cli/commands/
- [x] git         # docker exec to _git_ service (get cmd as string)
- [x] git-setup   # install git & gcm on running git server
- [x] git-chown   # adjust file permissions
- [x] terminate   # rm volumes & reset

## Usage
```
  rawp <cmd> [<wp>]
  
    <cmd>     One of <setup launch renewal up down ps wp connect git git-setup git-chown terminate>
    [<wp>]    A valid wp cli cmd (viz. https://developer.wordpress.org/cli/commands/)
```

### Copyright
copyright(c) 2023 Henley Cloud Consulting Ltd.
