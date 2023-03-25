# rawp launch
The launch command will configure and start a new Wordpress instance. It performs a 'staging' phase to check your kit for a no ssl website and, if OK, then fetches and installs a letsencrypt ssl certificate and restarts the website. Largely, this follows the guidance at viz. 
https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose
###0. Prerequisites
- raws-ec2 instance
    - a server running Ubuntu 20.04, along with a non-root user with sudo privileges and an active firewall
    - docker installed on your server
    - docker-compose installed on your server
- registered domain name, DNS records:
    - a record with your_domain -> IP
    - a record with www.your_domain -> IP
###1. Environment Variables
```yaml
#sudo vi .env
MYSQL_ROOT_PASSWORD='xxx'
MYSQL_USER=wp_yyy
MYSQL_PASSWORD='zzz'
```
Because your .env file contains sensitive information, you want to ensure that it is included in your project’s **.gitignore** and .dockerignore files.
```perl6
#sudo vi .dockerignore [~/wordpress/.dockerignore]

#`[
.env
.git
.dockerignore
]
```
###2. Webserver Configuration
```perl6
my $elastic-ip   = '35.177.143.49';
my $domain-name  = 'furnival.net';
my $admin-email  = 'hccs@furnival.net';

#on target
#mkdir wordpress
#cd wordpress
#mkdir nginx-conf
#sudo vi nginx-conf/nginx.conf

#use some qq
#`[
server {
    listen 80;
    listen [::]:80;

    #server_name your_domain www.your_domain;
    server_name $domain-name www.$domain-name;

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
#]
```
###3. Docker Compose Services
```perl6
#sudo vi docker-compose.yaml
```
```yaml
version: '3'

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
    command: '--default-authentication-plugin=mysql_native_password'
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
```
#### Wordpress CLI Service

```sudo docker exec wpcli wp --info```    --ok, but may need this:
```sudo docker-compose up -d --force-recreate --no-deps wpcli```

iamerejh
```sudo docker exec wpcli wp search-replace "test" "test1" --dry-run```

Error: The site you have requested is not installed.
Run `wp core install` to create database tables.

seems to need some juggling/forcing ... may need to tweak versions ... should work no wpcli (can't always get nginx to restart), then layer wpcli in maybe with force-recreate (or is there some muck in the yaml?) see test.yaml
###4. SSL Certificates and Credentials

```sudo docker-compose up -d```
```sudo docker-compose ps```
```text
Output
  Name                 Command               State           Ports       
-------------------------------------------------------------------------
certbot     certbot certonly --webroot ...   Exit 0                      
db          docker-entrypoint.sh --def ...   Up       3306/tcp, 33060/tcp
webserver   nginx -g daemon off;             Up       0.0.0.0:80->80/tcp 
wordpress   docker-entrypoint.sh php-fpm     Up       9000/tcp           
```

```sudo docker-compose exec webserver ls -la /etc/letsencrypt/live```
```text
Output
total 16
drwx------    3 root     root          4096 May 10 15:45 .
drwxr-xr-x    9 root     root          4096 May 10 15:45 ..
-rw-r--r--    1 root     root           740 May 10 15:45 README
drwxr-xr-x    2 root     root          4096 May 10 15:45 your_domain
```

Now that you know your request will be successful, you can edit the certbot service definition to remove the --staging flag.

Find the section of the file with the certbot service definition, and replace the --staging flag in the command option with the --force-renewal flag, which will tell Certbot that you want to request a new certificate with the same domains as an existing certificate. The following is the certbot service definition with the updated flag:

```yaml
...
    command: certonly --webroot --webroot-path=/var/www/html --email sammy@your_domain --agree-tos --no-eff-email --force-renewal -d your_domain -d www.your_domain
...
```

```sudo docker-compose up --force-recreate --no-deps certbot```
###5. Modifying the Web Server Configuration and Service Definition

Enabling SSL in your Nginx configuration will involve adding an HTTP redirect to HTTPS, specifying your SSL certificate and key locations, and adding security parameters and headers.

Since you are going to recreate the webserver service to include these additions, you can stop it now:
```sudo docker-compose stop webserver```

Before modifying the configuration file, get the recommended Nginx security parameter from Certbot using curl:
```sudo curl -sSLo nginx-conf/options-ssl-nginx.conf https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf```

This command will save these parameters in a file called options-ssl-nginx.conf, located in the nginx-conf directory.

Next, remove the Nginx configuration file you created earlier:
```sudo rm nginx-conf/nginx.conf```

Create and open another version of the file:
```sudo vi nginx-conf/nginx.conf```

```text
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
```

Before recreating the webserver service, you will need to add a 443 port mapping to your webserver service definition.

Open your docker-compose.yml file:
```sudo vi docker-compose.yaml```

In the webserver service definition, add the following port mapping:

```yaml
...
    ports:
      - "80:80"
      - "443:443"
```

Recreate the webserver service:
```sudo docker-compose up -d --force-recreate --no-deps webserver```
###6. Front End Setup
simples
###7. Renewing Certificates
Let’s Encrypt certificates are valid for 90 days. This cron job will renew your certificates and reload your Nginx configuration.

First, open a script called ssl_renew.sh:
```perl6
#sudo vi ssl_renew.sh```

#`[
#!/bin/bash

COMPOSE="/usr/local/bin/docker-compose --no-ansi"
DOCKER="/usr/bin/docker"

cd ~/wordpress/
$COMPOSE run certbot renew --dry-run && $COMPOSE kill -s SIGHUP webserver
$DOCKER system prune -af
]
```
This script first assigns the docker-compose binary to a variable called COMPOSE, and specifies the --no-ansi option, which will run docker-compose commands without ANSI control characters. It then does the same with the docker binary. Finally, it changes to the ~/wordpress project directory and runs the following docker-compose commands:

nano ssl_renew.sh
Copy
Add the following code to the script to renew your certificates and reload your web server configuration. Remember to replace the example username here with your own non-root username:

~/wordpress/ssl_renew.sh

Copy


docker-compose run: This will start a certbot container and override the command provided in your certbot service definition. Instead of using the certonly subcommand, the renew subcommand is used, which will renew certificates that are close to expiring. Also included is the --dry-run option to test your script.
docker-compose kill: This will send a SIGHUP signal to the webserver container to reload the Nginx configuration.
It then runs docker system prune to remove all unused containers and images.

Close the file when you are finished editing. Make it executable with the following command:

chmod +x ssl_renew.sh
Copy
Next, open your root crontab file to run the renewal script at a specified interval:

sudo crontab -e
If this is your first time editing this file, you will be asked to choose an editor:

Output
no crontab for root - using an empty one

Select an editor.  To change later, run 'select-editor'.
1. /bin/nano        <---- easiest
2. /usr/bin/vim.basic
3. /usr/bin/vim.tiny
4. /bin/ed

Choose 1-4 [1]:
...
At the very bottom of this file, add the following line:

crontab
...
*/5 * * * * /home/sammy/wordpress/ssl_renew.sh >> /var/log/cron.log 2>&1
This will set the job interval to every five minutes, so you can test whether or not your renewal request has worked as intended. A log file, cron.log, is created to record relevant output from the job.

After five minutes, check cron.log to confirm whether or not the renewal request has succeeded:

tail -f /var/log/cron.log
Copy
The following output confirms a successful renewal:

Output
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
** DRY RUN: simulating 'certbot renew' close to cert expiry
**          (The test certificates below have not been saved.)

Congratulations, all renewals succeeded. The following certs have been renewed:
/etc/letsencrypt/live/your_domain/fullchain.pem (success)
** DRY RUN: simulating 'certbot renew' close to cert expiry
**          (The test certificates above have not been saved.)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Exit out by entering CTRL+C in your terminal.

You can modify the crontab file to set a daily interval. To run the script every day at noon, for example, you would modify the last line of the file like the following:

crontab
...
0 12 * * * /home/sammy/wordpress/ssl_renew.sh >> /var/log/cron.log 2>&1
You will also want to remove the --dry-run option from your ssl_renew.sh script:

~/wordpress/ssl_renew.sh
```
#!/bin/bash

COMPOSE="/usr/local/bin/docker-compose --no-ansi"
DOCKER="/usr/bin/docker"

cd /home/sammy/wordpress/
$COMPOSE run certbot renew && $COMPOSE kill -s SIGHUP webserver
$DOCKER system prune -af
Copy
Your cron job will ensure that your Let’s Encrypt certificates don’t lapse by renewing them when they are eligible. You can also set up log rotation with the Logrotate utility to rotate and compress your log files.
```
