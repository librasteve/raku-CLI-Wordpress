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
- launch a new instance of Wordpress & setup ssl certificate ```rawp setup && rawp launch```
- view your new Wordpress site frontend at https://yourdomain.com and configure basics
- setup ssl cert renewals via letsencrypt ```rawp renewal```

## wordpress-launch.yaml
```yaml
        instance:
            domain-name: furnival.net
            admin-email: 'hccs@furnival.net'
            db-image: mysql:8.0
            wordpress-image: wordpress:php8.0-fpm-alpine
            webserver-image: nginx:1.15.12-alpine
            certbot-image: certbot/certbot
            wpcli-image: wordpress:cli-php8.0
```

## WP CLI Examples
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
- [x] wp 'cmd'    # run wpcli command - viz. https://developer.wordpress.org/cli/commands/
- [x] down        # docker-compose down
- [x] ps          # docker-compose ps
- [x] connect     # docker exec to wordpress server
- [x] terminate   # rm volumes & reset

## Usage
```
  rawp <cmd> [<wp>]
  
    <cmd>     One of <setup launch renewal up wp down ps connect terminate>
    [<wp>]    A valid wp cli cmd (viz. https://developer.wordpress.org/cli/commands/)
```

### Copyright
copyright(c) 2023 Henley Cloud Consulting Ltd.
