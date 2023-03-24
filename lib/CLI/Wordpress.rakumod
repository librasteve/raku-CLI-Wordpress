unit module CLI::Wordpress:ver<0.0.1>:auth<Steve Roe (p6steve@furnival.net)>;

use YAMLish;
use JSON::Fast;
# first go `aws configure` to populate $HOME/.aws/credentials

my $et = time;      # for unique names

my %config-yaml := load-yaml("$*HOME/.rawp-config/wordpress-launch.yaml".IO.slurp);   # only once

class Config is export {
    has %.y;

    method TWEAK {
        %!y        := %config-yaml;
    }
}

class Instance is export {
    has $.c = Config.new;

    method launch {
        say 'start staging...';

        chdir "$*HOME/wordpress";

        qqx`sudo docker-compose up -d`.say;

        sleep 5;
        qqx`sudo docker-compose ps`.say;

        qqx`sudo docker-compose run certbot certonly --webroot --webroot-path=/var/www/html --email steve@furnival.net --agree-tos --no-eff-email --staging --non-interactive -d furnival.net -d www.furnival.net`.say;

        #| check if staging was successful
        my @output = qqx`sudo docker-compose exec webserver ls -la /etc/letsencrypt/live`;

        die 'staging Failed' unless @output[*-1] ~~ /'furnival.net'/;     #FIXME dehardwire

        #| proceed
        say 'staging OK, now getting cert & switching to ssl nginx...';
        say 'this will use one of your 5/week lets-encrypt quota...';
        say 'you now have 5 seconds to abort (ctrl-C)';
        sleep 5;
        say '[you must now go "zef install ..." again to rebuild from no ssl]';

        #| get cert
        qqx`sudo docker-compose run certbot certonly --webroot --webroot-path=/var/www/html --email steve@furnival.net --agree-tos --no-eff-email --force-renewal --non-interactive -d furnival.net -d www.furnival.net`.say;

        #| reconfigure webserver to ssl
        qqx`sudo docker-compose stop webserver`;

        qqx`sudo curl -sSLo nginx-conf/options-ssl-nginx.conf https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf`;

        #| swap out nginx.conf
        qqx`sudo cp $*HOME/wordpress/nginx-conf/nginx.conf $*HOME/wordpress/nginx-conf/nginx.nossl`;
        qqx`sudo cp $*HOME/wordpress/nginx-conf/nginx.ssl $*HOME/wordpress/nginx-conf/nginx.conf`;

        #| restart as ssl
        qqx`sudo docker-compose up -d --force-recreate --no-deps webserver`;
    }

    method renew {
        say 'setting up cert renewals...';

        chdir "$*HOME/wordpress";

        #| setup cert renewal
        qqx`sudo chmod +x ssl_renew.sh`;
        qqx`sudo crontab ssl_renew`;

        #iamerejh check next install & remove yo tick
        #sudo tail -f /var/log/cron.log to see activity
    }

#`[
    method connect {
        self.wait-until-running;
        
        my $dns = self.public-dns-name;
        qq`ssh -o "StrictHostKeyChecking no" -i "{$!s.kpn}.pem" ubuntu@$dns`
    }

    method terminate {
        say 'terminating...';
        qqx`aws ec2 terminate-instances --instance-ids $!id`
    }

    method setup {
            say "setting up, this can take some minutes (longer if on a t2.micro) please be patient...";
            self.wait-until-running;
            sleep 20;       # let instance mellow

            my $dns = self.public-dns-name;

            # since we are changing the host, but keeping the eip, we flush known_hosts
            qqx`ssh-keygen -f ~/.ssh/known_hosts -R $dns`;

            my $proc = Proc::Async.new(:w, 'ssh', '-tt', '-o', "StrictHostKeyChecking no", '-i', "{$!s.kpn}.pem", "ubuntu@$dns");
            $proc.stdout.tap({ print "stdout: $^s" });
            $proc.stderr.tap({ print "stderr: $^s" });

            my $promise = $proc.start;

            $proc.say("echo 'Hello, World'");
            $proc.say("id");

            $proc.say('export PATH=$PATH:/usr/lib/perl6/site/bin:/home/ubuntu/.raku/bin');
            $proc.say('echo PATH=$PATH:/usr/lib/perl6/site/bin:/home/ubuntu/.raku/bin >> ~/.bashrc');

            $proc.say("echo \'$setup-text\' > setup.pl");
            $proc.say('cat setup.pl | perl');

            sleep 5;

            $proc.say("exit");
            await $promise;
            say "done!";
        }
    #]
}


