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

```rawp wp 'plugin install "increase-maximum-upload-file-size"'```

```rawp wp 'plugin list'```

```text
name	status	update	version
akismet	inactive	none	5.1
hello	inactive	none	1.7.2
increase-maximum-upload-file-size	inactive	none	1.0
```
```rawp wp 'plugin activate "increase-maximum-upload-file-size"'```
```rawp wp 'plugin delete "increase-maximum-upload-file-size"'```


413
nginx.conf
client_max_body_size 100M;     <-- ok


The uploaded file exceeds the upload_max_filesize directive in php.ini.
php.ini


from https://github.com/docker-library/wordpress/issues/10
A) RUN touch /usr/local/etc/php/conf.d/uploads.ini \
&& echo "upload_max_filesize = 10M;" >> /usr/local/etc/php/conf.d/uploads.ini
  - nope (maybe need to restart?)
  
B) Set the limits with your .htaccess file thats in your wordpress data directory.
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]

php_value post_max_size 24M
php_value upload_max_filesize 8M

  - nope (no restart)
  - nope (with restart)
  
  
C) 
file_uploads = On
memory_limit = 64M
upload_max_filesize = 64M
post_max_size = 64M
max_execution_time = 600


`29     `volumes:
30       - wordpress:/var/www/html
31       - ./php-conf/uploads.ini:/usr/local/etc/php/conf.d/uploads.ini