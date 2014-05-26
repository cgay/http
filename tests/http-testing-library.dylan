Module: dylan-user
Synopsis: HTTP testing infrastructure
Copyright: See LICENSE in this distribution for details.

define library http-testing
  use common-dylan;
  use http-client;
  use http-common;
  use http-server;
  use io;
  use logging;
  use uri;

  export http-testing;
end library http-testing;

define module http-testing
  use common-dylan;
  use http-client;
  use http-common;
  use http-server,
    exclude: { log-trace, log-debug, log-info, log-warning, log-error };
  use logging,
    import: { <logger> };
  use streams,
    import: { <string-stream> };
  use uri,
    import: { parse-url, <url> };

  export
    <echo-resource>,
    fmt,
    $listener-127,
    $listener-any,
    $log,
    *test-host*,
    *test-port*,
    test-url,
    root-url,
    make-listener,
    make-mock-server,
    make-server,
    <x-resource>, make-x-url,
    with-http-server;
end module http-testing;
