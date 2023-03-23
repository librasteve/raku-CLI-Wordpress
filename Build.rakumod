class Build {
    method build($dist-path) {

        #FIXME - move up
        my $elastic-ip   = '35.177.143.49';
        my $domain-name  = 'furnival.net';
        my $admin-email  = 'hccs@furnival.net';

        chdir $*HOME;
        mkdir 'wordpress';
        mkdir 'wordpress/nginx-conf';
        chdir 'wordpress';

    #FIXME - just make .env random in production
my $text0 = q:to/END0/;
MYSQL_ROOT_PASSWORD=boris
MYSQL_USER=wp_007
MYSQL_PASSWORD='g0ldf1nger'
END0

        qqx`echo \'$text0\' > .env`;

my $text1 = q:to/END1/;
.env
.git
.dockerignore
END1

        qqx`echo \'$text1\' > .gitignore`;

my $text2 = q:to/END2/;
server {
    listen 80;
    listen [::]:80;

    #server_name your_domain www.your_domain;
    #server_name $domain-name www.$domain-name;
    server_name furnival.net www.furnival.net;

    index index.php index.html index.htm;

    root /var/www/html;

    location ~ /.well-known/acme-challenge {
        allow all;
        root /var/www/html;
    }

    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location ~ /\.ht {
        deny all;
    }

    location = /favicon.ico {
        log_not_found off; access_log off;
    }
    location = /robots.txt {
        log_not_found off; access_log off; allow all;
    }
    location ~* \.(css|gif|ico|jpeg|jpg|js|png)$ {
        expires max;
        log_not_found off;
    }
}
END2

        qqx`echo \'$text2\' > nginx-conf/nginx.conf`;

my $text3 = q:to/END3/;
server {
	listen 80;
	listen [::]:80;

	#server_name your_domain www.your_domain;
	server_name furnival.net www.furnival.net;

	location ~ /.well-known/acme-challenge {
		allow all;
		root /var/www/html;
	}

	location / {
		rewrite ^ https://$host$request_uri? permanent;
	}
}

server {
	listen 443 ssl http2;
	listen [::]:443 ssl http2;
	server_name furnival.net www.furnival.net;

	index index.php index.html index.htm;

	root /var/www/html;

	server_tokens off;

	ssl_certificate /etc/letsencrypt/live/furnival.net/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/furnival.net/privkey.pem;

	include /etc/nginx/conf.d/options-ssl-nginx.conf;

	add_header X-Frame-Options "SAMEORIGIN" always;
	add_header X-XSS-Protection "1; mode=block" always;
	add_header X-Content-Type-Options "nosniff" always;
	add_header Referrer-Policy "no-referrer-when-downgrade" always;
	add_header Content-Security-Policy "default-src * data: 'unsafe-eval' 'unsafe-inline'" always;
	# add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
	# enable strict transport security only if you understand the implications

	location / {
		try_files $uri $uri/ /index.php$is_args$args;
	}

	location ~ \.php$ {
		try_files $uri =404;
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_pass wordpress:9000;
		fastcgi_index index.php;
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		fastcgi_param PATH_INFO $fastcgi_path_info;
	}

	location ~ /\.ht {
		deny all;
	}

	location = /favicon.ico {
		log_not_found off; access_log off;
	}
	location = /robots.txt {
		log_not_found off; access_log off; allow all;
	}
	location ~* \.(css|gif|ico|jpeg|jpg|js|png)$ {
		expires max;
		log_not_found off;
	}
}
END3

        qqx`echo \'$text3\' > nginx-conf/nginx.ssl`;

my $text4 = q:to/END4/;
version: "3"

services:
  db:
    image: mysql:8.0
    container_name: db
    restart: unless-stopped
    env_file: .env
    environment:
      - MYSQL_DATABASE=wordpress
    volumes:
      - dbdata:/var/lib/mysql
    command: "--default-authentication-plugin=mysql_native_password"
    networks:
      - app-network

  wordpress:
    depends_on:
      - db
    image: wordpress:5.1.1-fpm-alpine
    container_name: wordpress
    restart: unless-stopped
    env_file: .env
    environment:
      - WORDPRESS_DB_HOST=db:3306
      - WORDPRESS_DB_USER=$MYSQL_USER
      - WORDPRESS_DB_PASSWORD=$MYSQL_PASSWORD
      - WORDPRESS_DB_NAME=wordpress
    volumes:
      - wordpress:/var/www/html
    networks:
      - app-network

  webserver:
    depends_on:
      - wordpress
    image: nginx:1.15.12-alpine
    container_name: webserver
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - wordpress:/var/www/html
      - ./nginx-conf:/etc/nginx/conf.d
      - certbot-etc:/etc/letsencrypt
    networks:
      - app-network

  certbot:
    depends_on:
      - webserver
    image: certbot/certbot
    container_name: certbot
    volumes:
      - certbot-etc:/etc/letsencrypt
      - wordpress:/var/www/html
    #command: certonly --webroot --webroot-path=/var/www/html --email sammy@your_domain --agree-tos --no-eff-email --staging -d your_domain -d www.your_domain
    #command: certonly --webroot --webroot-path=/var/www/html --email $admin-email --agree-tos --no-eff-email --staging -d $domain-name -d www.$domain-name
    command: certonly --webroot --webroot-path=/var/www/html --email steve@furnival.net --agree-tos --no-eff-email --staging -d furnival.net -d www.furnival.net

#  wpcli:
#    container_name: wpcli
#    depends_on:
#      - wordpress
#    image: wordpress:cli
#    user: 1000:1000
#    command: tail -f /dev/null
#    volumes:
#      - wordpress:/var/www/html
#    environment:
#      - WORDPRESS_DB_HOST=db:3306
#      - WORDPRESS_DB_USER=$MYSQL_USER
#      - WORDPRESS_DB_PASSWORD=$MYSQL_PASSWORD
#      - WORDPRESS_DB_NAME=wordpress
#    profiles:
#      - dev

volumes:
  certbot-etc:
  wordpress:
  dbdata:

networks:
  app-network:
    driver: bridge
END4

        qqx`echo \'$text4\' > docker-compose.yaml`;

        chdir $*HOME;
        mkdir '.rawp-config';
        chdir '.rawp-config';

my $text5 = q:to/END5/;
instance:
    image: ami-0f540e9f488cfa27d            # <== the standard, clean AWS Ubuntu
    #image: ami-0c1163e529aeb9b20            # <== AWS Ubuntu plus raws-ec2 setup already applied (use --nsu flag)
    type: t2.micro                          # <== the basic, free tier eligible test machine
    #type: c6a.4xlarge                       # <== my choice of reasonably priced server class machine
    storage: 30                             # <== EBS size for launch
    security-group:
        name: MySG
        rules:
            - inbound:
                port: 22
                cidr: 0.0.0.0/0
            - inbound:
                port: 80
                cidr: 0.0.0.0/0
            - inbound:
                port: 443
                cidr: 0.0.0.0/0
            - inbound:
                port: 8080
                cidr: 0.0.0.0/0
            - inbound:
                port: 8888
                cidr: 0.0.0.0/0
END5

        qqx`echo \'$text5\' > wordpress-launch.yaml`;

        warn 'Build successful';

        exit 0
    }
}
