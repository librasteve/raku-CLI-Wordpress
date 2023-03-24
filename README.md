[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

# Raku CLI::Wordpress

This module provides a simple abstraction to the Wordpress command line interface (wpcli) for managing Wordpress installation.

If you encounter a feature of wpcli you want that's not implemented by this module (and there are many), please consider sending a pull request.

## Getting Started
- install rawp on target
```zef install https://github.com/p6steve/raku-CLI-Wordpress.git```
- launch new instance of Wordpress & set up ssl certificate
```rawp launch```
- setup ssl cert renewals via letsencrypt
```rwap renewal```


###CMDs
- [x] launch
- [x] renewal
- [x] up
- [x] wp          #exec wpcli cmd viz. https://developer.wordpress.org/cli/commands/
- [x] down
- [x] ps
- [x] connect
- [x] terminate   #rm volumes & reset


## Getting Started
- zef install https://github.com/p6steve/raku-CLI-Wordpress.git _[or CLI::Wordpress]_
- rawp _[enter your commands here]_

## Usage
```
  rawp <cmd> [<wp>]
  
    <cmd>     One of <launch renewal up wp down ps connect terminate>
    [<wp>]    A valid wp cli cmd (viz. https://developer.wordpress.org/cli/commands/)
```

##commands
###1. launch

This follows the advice on viz. https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose with a few exceptions:
- docker-compose.yaml
  - put in port 443 from the get go (even if not used)
  - certbot does not run a command on docker-compose up -d to avoid exceeding the (5/week) limit of let's encrypt, instead the cerbot image is started (and allowed to exit) when it can be re-run with the needed commands:
     - ```sudo docker-compose run certbot certonly --webroot --webroot-path=/var/www/html --email steve@furnival.net --agree-tos --no-eff-email --staging -d furnival.net -d www.furnival.net``` (once on launch, eg. after termination)
     - ```sudo docker-compose run certbot renew --dry-run```




### Copyright
copyright(c) 2023 Henley Cloud Consulting Ltd.
