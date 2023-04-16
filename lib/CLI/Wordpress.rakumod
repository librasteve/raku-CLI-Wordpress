unit module CLI::Wordpress:ver<0.0.1>:auth<Steve Roe (p6steve@furnival.net)>;

use YAMLish;
use JSON::Fast;

class Config is export {
    has %.y = load-yaml("$*HOME/.rawp-config/wordpress-launch.yaml".IO.slurp)
}

class Instance is export {
    has $.c = Config.new;

    method render( $file ) {
        my %i := $!c.y<instance>;

        my $txt = $file.IO.slurp;

        $txt ~~ s:g/'%DOMAIN_NAME%'         /%i<domain-name>/;
        #nginx-conf
        $txt ~~ s:g/'%CLIENT_MAX_BODY_SIZE%'/%i<client_max_body_size>/;
        #docker-compose.yaml
        $txt ~~ s:g/'%DB-IMAGE%'            /%i<db-image>/;
        $txt ~~ s:g/'%WORDPRESS-IMAGE%'     /%i<wordpress-image>/;
        $txt ~~ s:g/'%WEBSERVER-IMAGE%'     /%i<webserver-image>/;
        $txt ~~ s:g/'%CERTBOT-IMAGE%'       /%i<certbot-image>/;
        $txt ~~ s:g/'%WPCLI-IMAGE%'         /%i<wpcli-image>/;
        #php-conf
        $txt ~~ s:g/'%FILE_UPLOADS%'        /%i<file_uploads>/;
        $txt ~~ s:g/'%MEMORY_LIMIT%'        /%i<memory_limit>/;
        $txt ~~ s:g/'%UPLOAD_MAX_FILESIZE%' /%i<upload_max_filesize>/;
        $txt ~~ s:g/'%POST_MAX_SIZE%'       /%i<post_max_size>/;
        $txt ~~ s:g/'%MAX_EXECUTION_TIME%'  /%i<max_execution_time>/;

        $file.IO.spurt: $txt;
    }

    method setup {
        chdir $*HOME;

        mkdir 'wordpress';
        mkdir 'wordpress/nginx-conf';
        mkdir 'wordpress/php-conf';
        chdir 'wordpress';

        copy %?RESOURCES<wordpress/nginx-conf/nginx.nossl>.absolute, "$*HOME/wordpress/nginx-conf/nginx.conf";
        copy %?RESOURCES<wordpress/php-conf/uploads.ini>.absolute,   "$*HOME/wordpress/php-conf/uploads.ini";
        copy %?RESOURCES<wordpress/docker-compose.yaml>.absolute,    "$*HOME/wordpress/docker-compose.yaml";
        copy %?RESOURCES<wordpress/ssl_renew.sh>.absolute,           "$*HOME/wordpress/ssl_renew.sh";
        copy %?RESOURCES<wordpress/ssl_renew>.absolute,              "$*HOME/wordpress/ssl_renew";
        copy %?RESOURCES<.dockerignore>.absolute,                    "$*HOME/.dockerignore";

        self.render( "$*HOME/wordpress/nginx-conf/nginx.conf" );
        self.render( "$*HOME/wordpress/php-conf/uploads.ini" );
        self.render( "$*HOME/wordpress/docker-compose.yaml" );

        my $text = qq:to/END/;
        MYSQL_ROOT_PASSWORD='{('0'..'z').pick(23).join}'
        MYSQL_USER={'wp_' ~ (0..9).pick(3).join}
        MYSQL_PASSWORD='{('0'..'z').pick(23).join}'
        END
        "$*HOME/wordpress/.env".IO.spurt: $text;
    }

    method launch {
        say 'start staging...';

        my %i := $!c.y<instance>;

        chdir "$*HOME/wordpress";

        #| start services in no ssl mode
        qqx`sudo docker-compose up -d`.say;

        sleep 5;
        qqx`sudo docker-compose ps`.say;

        #| set up letsencrypt certbot command
        my $certbot-cmd =
        qq`sudo docker-compose run certbot certonly --webroot --webroot-path=/var/www/html --email %i<admin-email> --agree-tos --no-eff-email --non-interactive -d %i<domain-name> -d www.%i<domain-name>`;

        #| try to load ssl cert '--staging'
        qqx`$certbot-cmd --staging`.say;

        #| check if staging was successful
        my @output = qqx`sudo docker-compose exec webserver ls -la /etc/letsencrypt/live`;
        die 'staging Failed' unless @output[*-1] ~~ /"{%i<domain-name>}"/;

        #| proceed
        say 'staging OK, now getting cert & switching to ssl nginx...';
        say 'this will use one of your 5/week lets-encrypt quota...';
        say 'you now have 5 seconds to abort (ctrl-C)';
        sleep 5;
        say '[go "zef install ..." again to revert to no ssl]';

        #| really load cert  '--force-renewal'
        qqx`$certbot-cmd --force-renewal`.say;

        #| reconfigure webserver to ssl
        qqx`sudo docker-compose stop webserver`;

        #| install certbot tls config
        qqx`sudo curl -sSLo nginx-conf/options-ssl-nginx.conf https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf`;

        #| swap in ssl variant of nginx.conf
        copy %?RESOURCES<wordpress/nginx-conf/nginx.ssl>.absolute,  "$*HOME/wordpress/nginx-conf/nginx.conf";
        self.render( "$*HOME/wordpress/nginx-conf/nginx.conf" );

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

    method wp(:$str) {
        chdir "$*HOME/wordpress";
        qqx`sudo docker exec wpcli wp $str`.say
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
        say 'sudo docker exec -it --workdir /var/www/html wordpress "/bin/bash"'
    }

    method git {
        say 'sudo docker exec -it --workdir /var/www/html git "/bin/bash"'
    }

    #| install and configure git & gcm in git service
    method git-setup {
        sub exec($cmd, $wd='/') {
            my $preamble = qq|sudo docker exec -t --workdir $wd git /bin/bash -c|;
            qqx`$preamble $cmd`.say;
        }

        exec q|"apt-get update && apt-get upgrade -y"|;
        exec q|"apt-get install vim git curl wget libicu-dev gnupg pass -y"|;
        exec q|"wget https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.0.935/gcm-linux_amd64.2.0.935.tar.gz"|;
        exec q|"tar -xvf gcm-linux_amd64.2.0.935.tar.gz -C /usr/local/bin"|;
        exec q|"git-credential-manager configure"|;
        exec q|"git config --global credential.credentialStore gpg"|;
        exec q|"git config --global init.defaultBranch main"|;
        exec q|"git config --global --add safe.directory /var/www/html"|;
        exec q|"echo 'GPG_TTY=\$(tty)' >> ~/.bashrc"|;
    }

    #| chown all wp files to www-data:www-data in wordpress service
    method git-chown {
        qqx`sudo docker exec -t --workdir /var/www/html wordpress /bin/bash -c "chown -R www-data:www-data *"`.say;
        qqx`sudo docker exec -t --workdir /var/www/html wordpress /bin/bash -c "chown -R www-data:www-data .htaccess"`.say;
    }

    method terminate {
        chdir "$*HOME/wordpress";
        qqx`sudo docker-compose down -v`.say
    }
}


