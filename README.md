[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

# Raku CLI::Wordpress

This module provides a simple abstraction to the Wordpress command line interface (wpcli) for site launch and maintenance.

If you encounter a feature you want that's not implemented by this module (and there are many), please consider sending a pull request.

## Getting Started
- install rawp on target
```zef install https://github.com/p6steve/raku-CLI-Wordpress.git``` _[or CLI::Wordpress]_
- launch new instance of Wordpress & set up ssl certificate
```rawp launch```
- setup ssl cert renewals via letsencrypt
```rwap renewal```

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
- [x] launch
- [x] renewal
- [x] up
- [x] wp 'cmd'    #run wpcli command - viz. https://developer.wordpress.org/cli/commands/
- [x] down
- [x] ps
- [x] connect
- [x] terminate   #rm volumes & reset

## Usage
```
  rawp <cmd> [<wp>]
  
    <cmd>     One of <launch renewal up wp down ps connect terminate>
    [<wp>]    A valid wp cli cmd (viz. https://developer.wordpress.org/cli/commands/)
```

##commands
###1. launch

This follows the advice on viz. https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose with a few exceptions:
- docker-compose.yaml
  - put in port 443 from the get go (even if not used)
  - certbot does not run a command on docker-compose up -d to avoid exceeding the (5/week) limit of let's encrypt, instead the cerbot image is started (and allowed to exit) when it can be re-run with the needed commands:
     - ```sudo docker-compose run certbot certonly --webroot --webroot-path=/var/www/html --email steve@furnival.net --agree-tos --no-eff-email --staging -d furnival.net -d www.furnival.net``` (once on launch, eg. after termination)
     - ```sudo docker-compose run certbot renew --dry-run```




### Copyright
copyright(c) 2023 Henley Cloud Consulting Ltd.
