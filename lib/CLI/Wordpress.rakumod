unit module CLI::Wordpress:ver<0.0.1>:auth<Steve Roe (p6steve@furnival.net)>;

use YAMLish;
use JSON::Fast;
# first go `aws configure` to populate $HOME/.aws/credentials

my $et = time;      # for unique names

say 'yo';

#FIXME - make a yaml
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
        say 'launching...';

        #my @l=qqx`sudo docker-compose exec webserver ls -la /etc/letsencrypt/live`; @l[*-1] ~~ /"furnival.net"/.so.say;

        #`[
        my $cmd :=
            "aws ec2 run-instances " ~
            "--image-id {$!c.image} " ~
            "--instance-type {$!c.type} " ~
            "--key-name {$!s.kpn} " ~
            "--security-group-ids {$!s.sg.id}";
            
        qqx`$cmd` andthen
            $!id = .&from-json<Instances>[0]<InstanceId>;
        #]
    }

#`[
    method describe {
        qqx`aws ec2 describe-instances --instance-ids $!id`
        andthen 
            .&from-json<Reservations>[0]<Instances>[0]
    }

    method public-dns-name {
        self.describe<PublicDnsName>
    }

    method public-ip-address {
        self.describe<PublicIpAddress>
    }

    method state {
        self.describe<State><Name>
    }

    method wait-until-running {
        until self.state eq 'running' { 
            say self.state, '...'; 
            sleep 5 
        }
        say self.state, '...';
    }

    method eip-associate {
        self.wait-until-running;
        say 'associating eip...'; 
        $!s.eip.associate( :$!id );     # always associate Elastic IP
    }

    method connect {
        self.wait-until-running;
        
        my $dns = self.public-dns-name;
        qq`ssh -o "StrictHostKeyChecking no" -i "{$!s.kpn}.pem" ubuntu@$dns`
    }

    method terminate {
        say 'terminating...';
        qqx`aws ec2 terminate-instances --instance-ids $!id`
    }
    #]
}


