xquery version "3.1";

module namespace wdbPF	= "https://github.com/dariok/wdbplus/projectFiles";

import module namespace wdb	= "https://github.com/dariok/wdbplus/wdb" at "/db/apps/edoc/modules/app.xql";
declare namespace http   = "http://expath.org/ns/http-client";
declare namespace tei	= "http://www.tei-c.org/ns/1.0";

declare function wdbPF:getStart ($model as map(*)) {
  httpclient:get(xs:anyURI('http://repertorium.acdh-dev.oeaw.ac.at/exist/restxq/edoc/collection/repertorium/nav.html'), false(), ())
};