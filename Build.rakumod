class Build {
    method build($dist-path) {
        
        chdir $*HOME;
        mkdir '.rawp-config';
        chdir '.rawp-config';
        
        my $text = q:to/END/;
        instance:
            domain-name: furnival.net
            admin-email: 'hccs@furnival.net'
            db-image: mysql:8.0
            wordpress-image: wordpress:php8.0-fpm-alpine
            webserver-image: nginx:1.15.12-alpine
            certbot-image: certbot/certbot
            wpcli-image: wordpress:cli-php8.0
        END

        qqx`echo \'$text\' > wordpress-launch.yaml`;
        
        warn 'Build successful';
        
        exit 0
    }
}
