## WP CLI Examples
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