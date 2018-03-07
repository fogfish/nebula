-module(nebula_registry).

-compile({parse_transform, category}).
-compile({parse_transform, lager_transform}).

-export([
   start_link/0, 
   up/0,
   die/0
]).


%%
%%
start_link() ->
   piped:start_link(?MODULE).

%%
%%
up() ->
   [reader ||
       _ /= piped:require( whale:type_container() ),
       _ /= piped:require( whale:action_start() ),
      Id /= piped:require( whale:identity() ),

    Json =< hd( (whale:inspect(Id))(#{}) ),
    Node <- cats:optionT(badarg, lens:get( identity(), Json )),
    Port <- cats:optionT(badarg, lens:get( port(Node), Json )),
       _ =< pns:register(nebula, Node, Port),
       _ =< lager:info("[nebula] up ~s at ~s", [Node, Port])
   ].

%%
%%
die() ->
   [reader ||
       _ /= piped:require( whale:type_container() ),
       _ /= piped:require( whale:action_die() ),
      Id /= piped:require( whale:identity() ),

    Json =< hd( (whale:inspect(Id))(#{}) ),
    Node <- cats:optionT(badarg, lens:get( identity(), Json )),
       _ =< pns:unregister(nebula, Node),
       _ =< lager:info("[nebula] die ~s", [Node])
   ].


port(Node) ->
   lens:c(
      lens:at(<<"NetworkSettings">>),
      lens:at(<<"Ports">>),
      lens:at(<<"32100/tcp">>),
      lens:hd(),
      lens:at(<<"HostPort">>)
   ).

identity() ->
   lens:c(
      lens:at(<<"Config">>),
      lens:at(<<"Env">>),
      lens:takewith(fun(<<"ERL_NODE=", _/binary>>) -> true; (_) -> false end),
      %% @todo: replace with binary lens
      fun(Fun, <<"ERL_NODE=", Node/binary>>) ->
         lens:fmap(fun(_) -> Node end, Fun(Node))
      end
   ).




