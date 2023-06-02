# CLI::Wordpress Backup

## Updraft Plus

If you like to use a supported commercial backup/restore/migrate product then the [UpdraftPlus](https://updraftplus.com) Premium plugin (requires paid subscription) can be used.

_see [../README.md](../README.md) for details_

So, a typical new site starts with 
- ```rawp setup && rawp launch && rawp renewal```
- go to site and configure via front-end
  - new user
  - upload and install ```updraftplus-with-migrator.2.23.3.zip```
  - upload and restore / migrate from source site

This will handle the original WP **database** and files

Then, according to the [docs](https://updraftplus.com/wp-cli-updraftplus-documentation/), you can go:

- ```rawp wp 'updraftplus backup'```
- ```rawp wp 'updraftplus restore <nonce>'```

## Git Source Control (Backup)

After your base site is running, you can push it to git.

_see [./wpgit.md](./wpgit.md) for details_

This will initialize the WP files:

- do ```rawp git-setup```
- do 'Push (modified) Wordpress files to a (new) GitHub repo'

Then for the database:

- ```rawp wp 'db export'```
- do a git commit and push


export GPG_TTY=$(tty)
git pull
git add *.sql
git status
git commit -am'db backup'
git push
exit



rawp wp 'db import wordpress-2023-04-28-367cd92.sql'












