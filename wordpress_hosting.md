# Slick, cheap

**1 server + Amazon CloudFront + CloudFlare**

1. Domain name points to CloudFlare, which provides DNS and security services
2. CloudFlare routes requests to CloudFront via CNAME record
3. Special subdomain bypasses CloudFlare to access app box running WP
4. W3 Total Cache plugin gives caching rules to Amazon CloudFront
5. Jetpack plugin has Photon, free photo CDN offered by Wordpress

Could split database to separate server or implement other strategies if needed.

Source: [How To Self-Host an Infinitely Scalable WordPress Site on a Shoestring Budget](https://christiaanconover.com/blog/how-to-self-host-an-infinitely-scalable-wordpress-site-on-a-shoestring-budget)

# Customary approach

Several sites with 5-10M page views a month mentioned a setup similar to this, with some customizations.

* Database server running MySQL
* App server with Varnish
* Front end servers with PHP-FPM (or can put static files on one, PHP on the other)

# Alternative

This setup allows for easily adding cloned nodes, and is interesting because it distributes the filesystem and the database over all NODEs as a cluster. Source didn't mention caching or CDN, but presumably we could integrate those as well.

* NODE1: web server + database server
* NODE2: web server + database server
* NODE3: web server + database server
* LB1: load balancer (master) + keepalived
* LB2: ClusterControl + load balancer (backup) + keepalived

Source: [Scaling Wordpress and MySQL on Multiple Servers for Performance](http://www.severalnines.com/blog/scaling-wordpress-and-mysql-multiple-servers-performance)

# Notes from sources

## iPhoneclub.nl – 5.4M/m

* The app server hosts the Varnish front end.
* They use two nginx Web servers: one with PHP-FPM, the other with static content, like a CDN.
* The database server runs a highly tuned MySQL server, in which some of the WordPress tables, such as wp_posts, have been transitioned from MyISAM to InnoDB.
* Because InnoDB doesn’t have full text search, Sphinx Search was implemented.

## The Next Web – 8M/m

Essentials:

* Varnish as a reverse proxy and for Edge Side Includes (cache different sections of a page separately with different expiration times)
* Memcached to store the results of heavy queries, such as popular stories
* Munin for monitoring

Proactive maintenance:

* Use MySQL slow query log with `no-index` enabled
* Use XHprof for code path analyses
* Keep Apache logs clean. Generating a 404 page can be heavy, so it needs to be cacheable in Varnish as well.

Varnish tools:

* `varnishtop` to look into Varnish
* `varnishtop -i txurl` shows requests that aren't cached
* WP-VCL, their Varnish config file to make Varnish 3 play well with WP

## Essential plugins

* **W3 Total Cache** or **WP Super Cache**
* **WP Widget Cache**
* **Plugin Output Cache** in conjunction with **Similar Posts**, **Recent Posts** and **Recent Comments**
* **Clean Options** to keep WordPress’ easily bloated options table tidy
* **WordPress Sphinx search plugin** to connect with the open-source Sphinx search project
* **WPVarnish** for cache busting.
* **Term Management Tools by Scribu** for merging duplicate tags
* **Memcached Object Cache Plugin** to run a persistent object cache outside of PHP-APC if you’re running multiple servers
* **Varnish**

Source: [Secrets Of High-Traffic WordPress Blogs](http://www.smashingmagazine.com/2012/09/12/secrets-high-traffic-wordpress-blogs/)

# Sources

[WordPress: Best Practices on AWS](https://d0.awsstatic.com/whitepapers/wordpress-best-practices-on-aws.pdf)

[Varnish Deployment Architectures in AWS](http://harish11g.blogspot.sg/2012/03/deployment-architectures-varnish-amazon.html)

[Secrets Of High-Traffic WordPress Blogs](http://www.smashingmagazine.com/2012/09/12/secrets-high-traffic-wordpress-blogs/)

[Configuring Varnish for High-Availability with Multiple Web Servers](https://www.lullabot.com/blog/article/configuring-varnish-high-availability-multiple-web-servers)

[Scaling Wordpress and MySQL on Multiple Servers for Performance](http://www.severalnines.com/blog/scaling-wordpress-and-mysql-multiple-servers-performance)

[Step-by-step: Speed Up Wordpress with Varnish Software](https://www.varnish-software.com/blog/step-step-speed-wordpress-varnish-software)

