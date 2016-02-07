DigitalOcean-DDNS
=================

Digital Ocean dynamic DNS update script with Perl and LWP.

### INSTALLATION

Clone the git repository,

	git clone git@github.com:chandwer/DigitalOcean-DDNS.git

Generate a personal access token with write privilages here, https://cloud.digitalocean.com/settings/applications

Using the config.json.example as a reference make a config file with a personal access token and an array of domains objects under the domains key. Each domains object must contain a "domain" key and optionally a "record" key with a single record to update or a "records" key with an array of records to update.

Make sure you have the OpenSSL libraries and required Perl modules installed,

	sudo apt-get install libssl-dev
	sudo cpan LWP::UserAgent LWP::Protocol::https JSON::XS File::Slurp FindBin Log::Tiny

Run the update.pl script once and make sure there are no errors.

Create a cron job entry to run the script. For example to run it every 5 min use a crontab entry like,

	*/5 * * * * /home/some_user/src/DigitalOcean-DDNS/update.pl

### DEPENDENCIES
* LWP::UserAgent
* JSON::XS
* File::Slurp
* FindBin
* Log::Tiny

### AUTHOR

Chris Handwerker 2014 <<chris.handwerker@gmail.com>>

### LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
