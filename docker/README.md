It is assumed you have intermediate understanding of docker concepts and basic usage.

Building the SeMaWi image
=========================

1. Download the docker source files.
2. Stand in the parent directory of the directory containing the Dockerfile
3. Issue the following command: docker build -t semawi -f docker/Dockerfile .
4. Wait.

=Running a SeMaWi container=

For testing/development
=======================

The command will resemble the following:

docker run -d --name semawi-test -h semawi-test -p 12345:80 semawi

In the docker host, you should be able to access the SeMaWi container now through your browser, with an address like http://127.0.0.1:12345 . A default user SeMaWi (member of groups SysOp and Bureaucrat) has been created for you with the password "SeMaWiSeMaWi"; this password is case sensitive. This password should be changed as your first action in the running system.

For production
==============

A detailed description of deploying docker containers to production is beyond the scope of this document.

=Post deploy configuration=

Obligatory
==========

After the container is run from the built image, you will need to manually tweak a few settings. The container exports /var/www/wiki/ as a volume. Find it's location using docker inspect semawi-test. Set $wgServer to the IP of the container, obtained with docker inspect $CONTAINERID like so: $wgServer="http://172.17.0.2";

If you're running SeMaWi in production, you will need to edit the line in `LocalSettings.php` which looks like `enableSemantics( 'localhost' );`, replacing localhost with the domain name you are using.

You will still need to import the KLE data. The data files can be obtained here: https://github.com/JosefAssad/SeMaWi/tree/master/KLE-data . You will need to use the CSV import option in SpecialPages.

Optional
========

You will likely want to change your logo. Follow the guidelines [here](https://www.mediawiki.org/wiki/Manual:$wgLogo) to incorporate your logo.

I recommend you examine the list of Forms to identify which parts of the SeMaWi functionality is required in your case. You can link to the Categories created by these Forms in MediaWiki:Sidebar. A default sidebar will be provided in a future release.

You are encouraged to examine LocalSettings.php and adapt it to your needs.
