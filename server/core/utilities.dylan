Module:    httpi
Author:    Carl Gay
Copyright: See LICENSE in this distribution for details.
Synopsis:  Variables and utilities 


define constant $http-version :: <byte-string> = "HTTP/1.1";
define constant $default-http-port :: <integer> = 8000;
define constant $default-https-port :: <integer> = 8443;


// Command-line arguments parser.  The expectation is that libraries that use
// and extend this server (e.g., wiki) may want to add their own <option-parser>s to
// this before calling http-server-main().
define variable *command-line-parser* :: <command-line-parser>
  = make(<command-line-parser>);


// Max size of data in a POST.
define variable *max-post-size* :: false-or(<integer>) = 16 * 1024 * 1024;


define function file-contents (filename :: <pathname>)
 => (contents :: false-or(<string>))
  block ()
    with-open-file(input-stream = filename,
                   direction: #"input")
      read-to-end(input-stream)
    end
  exception (ex :: <file-does-not-exist-error>)
    #f
  end
end function file-contents;

define method parent-directory
    (dir :: <locator>, #key levels = 1) => (dir :: <directory-locator>)
  for (i from 1 to levels)
    // is there a better way to get the containing directory?
    dir := simplify-locator(subdirectory-locator(dir, ".."));
  end;
  dir
end;



// These logs are used if no other logs are configured.
// Usually that should only happen very early during startup when
// *server* isn't bound, if at all.

// Log used as last resort if no other logs are defined.
// This is the initial value used for the *request-log*, *debug-log*, and
// *error-log* variables, which in turn are used as the default logs for
// each <http-server>.
//
define constant $default-log
  = make(<log>,
         name: "http.server",
         level: $info-level,
         targets: list($stdout-log-target));

define thread variable *debug-log* :: <log> = $default-log;

define thread variable *error-log* :: <log> = $default-log;

define thread variable *request-log* :: <log> = $default-log;

define constant log-trace   = curry(%log-trace, *debug-log*);
define constant log-debug   = curry(%log-debug, *debug-log*);
define constant log-info    = curry(%log-info, *debug-log*);
define constant log-warning = curry(%log-warning, *error-log*);
define constant log-error   = curry(%log-error, *error-log*);

// For debugging only.
// For logging request and response content data only.
// So verbose it needs to be explicitly enabled.
define variable *content-log* :: <log>
  = make(<log>,
         name: "http.server.content",
         targets: list($stdout-log-target),
         additive: #f);

// Not yet configurable.
define variable *log-content?* :: <boolean> = #f;

define inline method log-content (content)
  log-debug-if(*log-content?*, *content-log*, "Sent content: %=", content);
end;

define class <multi-log-mixin> (<object>)
  slot request-log :: <log> = *request-log*,
    init-keyword: request-log:;

  slot error-log :: <log> = *error-log*,
    init-keyword: error-log:;

  slot debug-log :: <log> = *debug-log*,
    init-keyword: debug-log:;
end class <multi-log-mixin>;


// We want media types (with attributes) rather than plain mime types,
// and we give them all quality values.
define constant $default-media-type-map
  = begin
      let tmap = make(<mime-type-map>);
      for (mtype keyed-by extension in $default-mime-type-map)
        let media-type = make(<media-type>,
                              type: mtype.mime-type,
                              subtype: mtype.mime-subtype);
        set-attribute(media-type, "q", 0.1);
        tmap[extension] := media-type;
      end;

      // Set higher quality values for some media types.  These affect
      // content negotiation.

      // TODO -- more, and make them configurable
      set-attribute(tmap["html"], "q", 0.2);
      set-attribute(tmap["htm"], "q", 0.2);

      tmap
    end;

define function %resource-not-found-error
    (request, #rest args, #key url, #all-keys)
  let url = iff(instance?(url, <uri>), build-path(url), url);
  apply(resource-not-found-error,
        url: url | build-path(request-url(request)),
        args)
end function %resource-not-found-error;




//// Errors

define class <http-server-error> (<format-string-condition>, <error>)
end;

// Signaled when a library uses the server API incorrectly. i.e., user
// errors such as registering a page that has already been registered.
// Not for errors that will be reported to the HTTP client.
//
define open class <http-server-api-error> (<http-server-error>)
end;

define function http-server-api-error
    (format-string :: <string>, #rest format-arguments)
  signal(make(<http-server-api-error>,
              format-string: format-string,
              format-arguments: format-arguments));
end;



//// URLs

define open generic redirect-to
    (object :: <object>, request :: <request>, response :: <response>);

define method redirect-to
    (url :: <string>, request :: <request>, response :: <response>)
  let headers = response.raw-headers;
  set-header(headers, "Location", url);
  see-other-redirect(headers: headers);
end method redirect-to;

define method redirect-to
    (url :: <url>, request :: <request>, response :: <response>)
  redirect-to(build-uri(url), request, response);
end;

define open generic redirect-temporarily-to
    (object :: <object>, request :: <request>, response :: <response>);

define method redirect-temporarily-to
    (url :: <string>, request :: <request>, response :: <response>)
  let headers = response.raw-headers;
  set-header(headers, "Location", url);
  moved-temporarily-redirect(headers: headers);
end method redirect-temporarily-to;

define method redirect-temporarily-to
    (url :: <url>, request :: <request>, response :: <response>)
  redirect-temporarily-to(build-uri(url), request, response);
end;



//// <page-context>

// Gives the user a place to store values that will have a lifetime
// equal to the duration of the handling of the request.  The name is
// stolen from JSP's PageContext class, but it's not intended to serve the
// same purpose.  Use set-attribute(page-context, key, val) to store attributes
// for the page and get-attribute(page-context, key) to retrieve them.

define class <page-context> (<attributes-mixin>)
end;

define thread variable *page-context* :: false-or(<page-context>) = #f;

// TODO(cgay): not sure!
define method page-context
    () => (context :: false-or(<page-context>))
  if (*request*)
    *page-context* | (*page-context* := make(<page-context>))
  else
    application-error(message: "There is no active HTTP request.")
  end;
end;



