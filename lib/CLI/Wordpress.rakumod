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
        say 'staging...';

	chdir "$*HOME/wordpress";

	qqx`sudo docker-compose up -d`.say;

	sleep 5;
	qqx`sudo docker-compose ps`.say;

	#| check if staging was successful
        my @output = qqx`sudo docker-compose exec webserver ls -la /etc/letsencrypt/live`; 

	die 'staging Failed' unless @output[*-1] ~~ /'furnival.net'/;     #FIXME dehardwire

	say 'staging OK, now getting cert...';
	say '[go "zef install ..." again to reset]';

	my $dc;
        $dc = "$*HOME/wordpress/docker-compose.yaml".IO.slurp;
	$dc ~~ s:g/'--staging'/'--force-renewal'/;
	"$*HOME/wordpress/docker-compose.yaml".IO.spurt: $dc;

	qqx`sudo docker-compose up --force-recreate --no-deps certbot`;

	qqx`sudo cp $*HOME/wordpress/nginx-conf/nginx-ssl.conf $*HOME/wordpress/nginx-conf/nginx.conf`;

	#| add secure port
	$dc = "$*HOME/wordpress/docker-compose.yaml".IO.slurp;
	my $new-ports = "- \"80:80\"\n      - \"443:443\"";
	$dc ~~ s:g/'- "80:80"'/$new-ports/;
	"$*HOME/wordpress/docker-compose.yaml".IO.spurt: $dc;

	qqx`sudo docker-compose up -d --force-recreate --no-deps webserver`;
	#iamerejh

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


