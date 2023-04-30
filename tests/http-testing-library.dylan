Module: dylan-user
Copyright: See LICENSE in this distribution for details.

define library http-testing
  use common-dylan;
  use http-client;
  use http-common;
  use http-server;
  use logging;
  use network;
  use system;
  use testworks;
  use uri;
  use io, import: { format };

  export http-testing;
end library http-testing;

define module http-testing
  use format;
  use common-dylan;
  use http-client;
  use http-common;
  use http-server;
  use locators,
    import: { file-locator, locator-name };
  use logging;
  use sockets,
    import: { start-sockets };
  use testworks;
  use threads,
    import: { dynamic-bind };
  use uri,
    import: { parse-url, <url> };

  export
    <echo-resource>,
    fmt,
    $listener-127,
    $listener-any,
    *test-host*,
    *test-port*,
    test-url,
    root-url,
    make-listener,
    make-server,
    <x-resource>, make-x-url,
    \http-test-definer,
    \with-http-server,
    \with-logging-redirected;
end module http-testing;
