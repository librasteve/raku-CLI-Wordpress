chdir $*HOME;

mkdir '.rawp-config';
copy %?RESOURCES<.wordpress-launch.yaml>.absolute,          "$*HOME/.rawp-config/wordpress-launch.yaml";

mkdir 'wordpress';
mkdir 'wordpress/nginx-conf';
chdir 'wordpress';

copy %?RESOURCES<wordpress/nginx-conf/nginx.nossl>.absolute, "$*HOME/wordpress/nginx-conf/nginx.conf";
copy %?RESOURCES<wordpress/docker-compose.yaml>.absolute,   "$*HOME/wordpress/docker-compose.yaml";
copy %?RESOURCES<wordpress/ssl_renew.sh>.absolute,          "$*HOME/wordpress/ssl_renew.sh";
copy %?RESOURCES<wordpress/ssl_renew>.absolute,             "$*HOME/wordpress/ssl_renew";

my $text = q:to/END/;
    MYSQL_ROOT_PASSWORD=borisyo
    MYSQL_USER=wp_007
    MYSQL_PASSWORD='g0ldf1nger'
END

"$*HOME/wordpress/.env".spurt.$text;
