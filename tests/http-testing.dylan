Module: http-testing
Copyright: See LICENSE in this distribution for details.


define constant $log :: <logger>
  = make(<logger>, name: "http.test-suite");

// Would this be useful in http-server itself?
//
define macro with-http-server
  { with-http-server (?server:variable = ?ctor:expression) ?body:body end }
  => { let _server = #f;
       block ()
         _server := ?ctor;
         let ?server = _server;
         start-server(_server, background: #t, wait: #t);
         ?body
       cleanup
         if (_server)
           stop-server(_server, abort: #t);
         end
       end;
     }
end macro with-http-server;

define constant fmt = format-to-string;

define variable *test-host* :: <string> = "127.0.0.1";
define variable *test-port* :: <integer> = 8080;

define method test-url
    (path-etc :: <string>, #key host, port) => (url :: <url>)
  parse-url(fmt("http://%s:%d%s", host | *test-host*, *test-port*, path-etc))
end;

define method root-url
    () => (url :: <url>)
  test-url("/")
end;

define method make-listener
    (address :: <string>) => (listener :: <string>)
  format-to-string("%s:%d", address, *test-port*)
end;

define constant $listener-any = make-listener("0.0.0.0");
define constant $listener-127 = make-listener("127.0.0.1");

define function make-server
    (#rest keys, #key listeners, #all-keys)
  apply(make, <http-server>,
        listeners: listeners | list($listener-any),
        keys)
end;

define class <echo-resource> (<resource>)
end;

define method respond-to-get
    (resource :: <echo-resource>, #key)
  // should eventually be output(read-to-end(current-request()))
  output(request-content(current-request()));
end;

define method respond-to-post
    (resource :: <echo-resource>, #key)
  respond-to-get(resource)
end;


define class <x-resource> (<resource>)
end;

define method respond-to-get
    (resource :: <x-resource>, #key)
  let n = get-query-value("n", as: <integer>);
  output(make(<byte-string>, size: n, fill: 'x'))
end;

define method respond-to-post
    (resource :: <x-resource>, #key)
  respond-to-get(resource)
end;

define function make-x-url
    (n :: <integer>) => (url :: <url>)
  test-url(format-to-string("/x?n=%d", n))
end;


define class <mock-http-server> (<http-server>)
end;

define function make-mock-server
    (#rest args, #key listeners, #all-keys)
  apply(make, <mock-http-server>,
        listeners: listeners | #[],
        args)
end;

define class <mock-http-connection> (<http-connection>)
  inherited slot connection-host = "localhost";
  inherited slot connection-port = $default-http-port;
  constant slot connection-server :: <mock-http-server>,
    required-init-keyword: server:;
end class <mock-http-connection>;

// Adds a method to the generic in http-client.
define method make-http-connection
    (target :: <mock-http-server>, #key) => (conn :: <mock-http-connection>)
  make(<mock-http-connection>,
       server: target,
       socket: make(<string-stream>))
end;

define method start-server
    (server :: <mock-http-server>, #key background :: <boolean>, wait :: <boolean>)
 => (started? :: <boolean>)
  #t                            // good enough for now
end method start-server;
