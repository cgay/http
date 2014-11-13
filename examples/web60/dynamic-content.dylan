Module: web60-dynamic-content

define class <clock-page> (<resource>)
end;

define method respond
    (page :: <clock-page>, request :: <request>, response :: <response>, #key)
  set-header(response, "Content-Type", "text/html");
  let date = as-iso8601-string(current-date());
  write(response, concatenate("<html><body>", date, "</body></html>"));
end;

let server = make(<http-server>,
                  listeners: list("0.0.0.0:8888"));
add-resource(server, "/", make(<clock-page>));
start-server(server);

