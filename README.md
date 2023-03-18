[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

# Raku CLI::Wordpress

This module provides a simple abstraction to the Wordpress command line interface (wpcli) for managing Wordpress installation.

If you encounter a feature of wpcli you want that's not implemented by this module (and there are many), please consider sending a pull request.

## Design

- clone rawp to target
```sudo git clone https://github.com/p6steve/raku-CLI-Wordpress.git```




## Getting Started

- zef install CLI::Wordpress
- rawp _[enter your commands here]_

## Usage

```
./rawp <cmd>
  
    <cmd>         One of <launch start stop connect terminate>
```

iamerejh

## Config

```launch``` reads ```wordpress-launch.yaml```.
Edit this yaml file to meet your needs...

- cat .rawp-config/wordpress-launch.yaml 

```
instance:
    image: 'ami-0f540e9f488cfa27d'
    type: 't2.micro'
    security-group:
        name: 'MySG'
        rules:
            - inbound:
                port: 80
                cidr: '0.0.0.0/0'
            - inbound:
                port: 443 
                cidr: '0.0.0.0/0'
```

## Setup

```setup``` deploys docker, docker-compose, raku and zef to the launchee...

- cat .raws-config/launch.pl

```
#!/usr/bin/perl
`sudo apt-get update -y`;

`sudo apt-get install rakudo -y`;
`sudo git clone https://github.com/ugexe/zef.git`;
`sudo raku -I./zef zef/bin/zef install ./zef --/test`;

`sudo apt-get install docker -y`;
`sudo apt-get install docker-compose -y`;
```

## Wordpress Deploy & Control

[This section will probably go into raku-CLI-WP-Simple]

viz. [digital ocean howto](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose#step-3-defining-services-with-docker-compose)

- client script 'raku-wp --launch'


## NOTES

- unassigned Elastic IPs are chargeable ($5 per month ish), may be better to run one free tier instance
- rules about rules
  - will always open port 22 (SSH) inbound from this client IP
  - will re-use the existing named Security Group (or create if not present)
  - only inbound are supported for now 
  -  if you want to keep the name and change the rules, then delete via the aws console

### Copyright
copyright(c) 2022 Henley Cloud Consulting Ltd.
