[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

# Raku CLI::Wordpress

This module provides a simple abstraction to the Wordpress command line interface (wpcli) for managing Wordpress installation.

If you encounter a feature of wpcli you want that's not implemented by this module (and there are many), please consider sending a pull request.

## Design
- install rawp on target
```sudo zef install https://github.com/p6steve/raku-CLI-Wordpress.git```
- files
  - docker-compose.yaml 
  - nginx-conf
  - …?
- qqx stages

###CMDs
- [ ] launch
- [x] start ```sudo docker-compose up -d```
- [x] stop ```sudo docker-compose down```
- [x] list ```sudo docker-compose ps```
- [x] connect ```sudo docker exec -it ubuntu_wordpress_1 "/bin/bash"```
- [x] terminate ```sudo docker compose down -v```  #rm volumes & reset
- [ ] exec #wpcli cmd

## Getting Started
- zef install https://github.com/p6steve/raku-CLI-Wordpress.git _[or CLI::Wordpress]_
- rawp _[enter your commands here]_

## Usage
```
./rawp <cmd>
  
    <cmd>         One of <launch start stop connect terminate>
```

### Copyright
copyright(c) 2023 Henley Cloud Consulting Ltd.
