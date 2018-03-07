-module(nebula_api).
-compile({parse_transform, category}).

-export([endpoints/0]).

endpoints() ->
   [
      registry_lookup(),
      registry_create()
   ].


registry_lookup() ->
   [reader ||
      Path /= restd:path("/nodes/:id"),
         _ /= restd:method('GET'),

      Node =< lens:get(lens:pair(<<"id">>), Path),
      cats:optionT(not_found, pns:whereis(nebula, Node)),
      cats:unit({ok, scalar:s(_)}),

      Http /= restd:to_text(_),
         _ /= restd:accesslog(Http)
   ].

%% @todo: prevent re-use of same port by node with different name
registry_create() ->
   [reader ||
      Path /= restd:path("/nodes/:id"),
         _ /= restd:method('PUT'),
      Port /= restd:as_text(),

      Node =< lens:get(lens:pair(<<"id">>), Path),
      cats:unit({ok, pns:register(nebula, Node, Port)}),

      Http /= restd:to_text(_),
         _ /= restd:accesslog(Http)
   ].
