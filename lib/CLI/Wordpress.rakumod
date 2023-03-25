unit module CLI::Wordpress:ver<0.0.1>:auth<Steve Roe (p6steve@furnival.net)>;

use YAMLish;
use JSON::Fast;

class Config is export {
    has %.y;
    has $.domain-name;
    has $.admin-email;

    method TWEAK {
        my %config-yaml := load-yaml("$*HOME/.rawp-config/wordpress-launch.yaml".IO.slurp);

        %!y := %config-yaml;
        $!domain-name := %!y<instance><domain-name>;
        $!admin-email := %!y<instance><admin-email>;
    }
}

class Instance is export {
    has $.c = Config.new;

    sub render($file) {

        dd $!c.domain-name;
        my $txt = $file.IO.slurp;

        $txt ~~ s:g/'%DOMAIN_NAME%'/booboo/;
        $file.IO.spurt: $txt;
    }

    method setup {
        chdir $*HOME;

        mkdir 'wordpress';
        mkdir 'wordpress/nginx-conf';
        chdir 'wordpress';

        copy %?RESOURCES<wordpress/nginx-conf/nginx.nossl>.absolute, "$*HOME/wordpress/nginx-conf/nginx.conf";
        copy %?RESOURCES<wordpress/docker-compose.yaml>.absolute,    "$*HOME/wordpress/docker-compose.yaml";
        copy %?RESOURCES<wordpress/ssl_renew.sh>.absolute,           "$*HOME/wordpress/ssl_renew.sh";
        copy %?RESOURCES<wordpress/ssl_renew>.absolute,              "$*HOME/wordpress/ssl_renew";

        render( "$*HOME/wordpress/nginx-conf/nginx.conf" );

        my $text = qq:to/END/;
        MYSQL_ROOT_PASSWORD='{('0'..'z').pick(23).join}'
        MYSQL_USER={'wp_' ~ (0..9).pick(3).join}
        MYSQL_PASSWORD='{('0'..'z').pick(23).join}'
        END
        "$*HOME/wordpress/.env".IO.spurt: $text;
    }

    method launch {
        say 'start staging...';

        chdir "$*HOME/wordpress";

        #| start services in no ssl mode
        qqx`sudo docker-compose up -d`.say;

        sleep 5;
        qqx`sudo docker-compose ps`.say;

        #| try to load ssl cert '--staging'
        qqx`sudo docker-compose run certbot certonly --webroot --webroot-path=/var/www/html --email steve@furnival.net --agree-tos --no-eff-email --staging --non-interactive -d furnival.net -d www.furnival.net`.say;

        #| check if staging was successful
        my @output = qqx`sudo docker-compose exec webserver ls -la /etc/letsencrypt/live`;

        die 'staging Failed' unless @output[*-1] ~~ /'furnival.net'/;     #FIXME dehardwire

        #| proceed
        say 'staging OK, now getting cert & switching to ssl nginx...';
        say 'this will use one of your 5/week lets-encrypt quota...';
        say 'you now have 5 seconds to abort (ctrl-C)';
        sleep 5;
        say '[go "zef install ..." again to revert to no ssl]';

        #| really load cert  '--force-renewal'
        qqx`sudo docker-compose run certbot certonly --webroot --webroot-path=/var/www/html --email steve@furnival.net --agree-tos --no-eff-email --force-renewal --non-interactive -d furnival.net -d www.furnival.net`.say;

        #| reconfigure webserver to ssl
        qqx`sudo docker-compose stop webserver`;

        qqx`sudo curl -sSLo nginx-conf/options-ssl-nginx.conf https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf`;

        #| swap in ssl variant of nginx.conf
        copy %?RESOURCES<wordpress/nginx-conf/nginx.ssl>.absolute,  "$*HOME/wordpress/nginx-conf/nginx.conf";

        #| restart webserver with ssl certificates
        qqx`sudo docker-compose up -d --force-recreate --no-deps webserver`;

        #| start wpcli
        qqx`sudo docker-compose up -d --force-recreate --no-deps wpcli`;
    }

    method renewal {
        say 'setting up cert renewals...';
        say '[go "sudo tail -f /var/log/cron.log" to review]';

        chdir "$*HOME/wordpress";

        #| setup cert renewal
        qqx`sudo chmod +x ssl_renew.sh`;
        qqx`sudo crontab ssl_renew`;
    }

    method up {
        chdir "$*HOME/wordpress";
        qqx`sudo docker-compose up -d`.say;

        #| start wpcli
        qqx`sudo docker-compose up -d --force-recreate --no-deps wpcli`;
    }

    method wp(:$wp) {
        chdir "$*HOME/wordpress";
        qqx`sudo docker exec wpcli wp $wp`.say
    }

    method down {
        chdir "$*HOME/wordpress";
        qqx`sudo docker-compose down`.say
    }

    method ps {
        chdir "$*HOME/wordpress";
        qqx`sudo docker-compose ps`.say
    }

    method connect {
        say 'sudo docker exec -it wordpress "/bin/bash"'
    }

    method terminate {
        chdir "$*HOME/wordpress";
        qqx`sudo docker-compose down -v`.say
    }
}


