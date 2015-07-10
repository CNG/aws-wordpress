#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and http://varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;
import directors;

# Default backend definition. Set this to point to your content server.
backend default {
  .host = "127.0.0.1";
  .port = "8080";
}

acl purge {
  "localhost";
  "127.0.0.1";
  # production internal IPs
  # production external IPs
}

#sub vcl_recv {
# Happens before we check if we have this in cache already.
#
# Typically you clean up the request here, removing cookies you don't need,
# rewriting the request, etc.
#}

#sub vcl_backend_response {
# Happens after we have read the response headers from the backend.
#
# Here you clean the response headers, removing silly Set-Cookie headers
# and other mistakes your backend does.
#}

#sub vcl_deliver {
# Happens when we have all the pieces we need, and are about to send the
# response to the client.
#
# You can do accounting or modifying the final object here.
#}


sub vcl_init {
  # Called when VCL is loaded, before any requests pass through it. Typically used to initialize VMODs.
}


sub vcl_recv {

  # set standard proxied ip header for getting original remote address
  set req.http.X-Forwarded-For = client.ip;

  if (req.method == "PURGE") {
    if (!client.ip ~ purge) {
      return(synth(405,"Not allowed."));
    }
    return (purge);
  }

  if (req.url ~ "\.(gif|jpg|jpeg|swf|ttf|css|js|flv|mp3|mp4|pdf|ico|png)(\?.*|)$") {
    unset req.http.cookie;
    set req.url = regsub(req.url, "\?.*$", "");
  }

  if (req.url ~ "\?(utm_(campaign|medium|source|term)|adParams|client|cx|eid|fbid|feed|ref(id|src)?|v(er|iew))=") {
    set req.url = regsub(req.url, "\?.*$", "");
  }

  if (req.url ~ "wp-(login|admin)" || req.url ~ "preview=true" || req.url ~ "xmlrpc.php") {
    return (pass);
  }

  if (req.http.cookie) {
    if (req.http.cookie ~ "(wordpress_|wp-settings-)") {
      return(pass);
    } else {
      unset req.http.cookie;
    }
  }

}

#sub vcl_fetch {
#  if (beresp.status == 500 || beresp.status == 502 || beresp.status == 503) {
#    set beresp.saintmode = 10s;
#    if (req.request != "POST") {
#      return(restart);
#    }
#  }
#  set beresp.grace = 6h;
#}

# Drop any cookies Wordpress tries to send back to the client.
sub vcl_backend_response {

  if (beresp.status >= 500 && beresp.status < 600) {
      unset beresp.http.Cache-Control;
      set beresp.http.Cache-Control = "no-cache, max-age=0, must-revalidate";
      set beresp.ttl = 0s;
      set beresp.http.Pragma = "no-cache";
      set beresp.uncacheable = true;
      return(deliver);
  }

  # remove some headers we never want to see
  unset beresp.http.Server;
  unset beresp.http.X-Powered-By;

  if ( (!(bereq.url ~ "(wp-(login|admin)|login)")) || (bereq.method == "GET") ) {
    unset beresp.http.set-cookie;
    set beresp.ttl = 6h;
  }

  if (bereq.url ~ "\.(gif|jpg|jpeg|swf|ttf|css|js|flv|mp3|mp4|pdf|ico|png)(\?.*|)$") {
    set beresp.ttl = 365d;
  }

}

sub vcl_deliver {
  # add debugging headers, so we can see what's cached
  if (obj.hits > 0) {
    set resp.http.X-Cache = "HIT";
  } else {
    set resp.http.X-Cache = "MISS";
  }
  set resp.http.Access-Control-Allow-Origin = "*";
  # remove some headers added by varnish
  unset resp.http.Via;
  unset resp.http.X-Varnish;
}

sub vcl_hit {
  if (req.method == "PURGE") {    
    return(synth(200,"OK"));
  }
}

sub vcl_miss {
  if (req.method == "PURGE") {    
    return(synth(404,"Not cached"));
  }
}
