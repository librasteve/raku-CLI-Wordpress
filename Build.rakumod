class Build {
    method build($dist-path) {
        
        chdir $*HOME;
        mkdir '.rawp-config';
        chdir '.rawp-config';
        
        my $text = q:to/END/;
        instance:
            domain-name: your_domain
            admin-email: 'admin@your_domain'
            db-image: mysql:8.0
            wordpress-image: wordpress:6.2-php8.0-fpm-alpine
            webserver-image: nginx:1.15.12-alpine
            certbot-image: certbot/certbot
            wpcli-image: wordpress:cli-php8.0
            file_uploads: On
            memory_limit: 64M
            upload_max_filesize: 64M
            post_max_size: 64M
            max_execution_time: 600
            client_max_body_size: 64M
        END

        qqx`echo \'$text\' > wordpress-launch.yaml`;
        
        warn 'Build successful';
        
        exit 0
    }
}
