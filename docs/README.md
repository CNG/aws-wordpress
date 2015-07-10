# Amazon Web Services + WordPress

See the subfolders of this directory for available documentation.

## Master data locations

This repository should contain everything needed to set up the WordPress environment except for some static files such as images and uploads. **Note the latest WordPress files have been removed from the repository for now, as this particular one serves as a template.**

* Content changes are contained in the WordPress MySQL databases, referenced in [`wp-config.php`](../html/wp-config.php)
* Uploaded images and other files should all be contained on the server in `/var/www/html/wp-content/`
* Everything else should be version controlled in this repository
