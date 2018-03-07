-module(whale).
-compile({parse_transform, category}).

-export([start/0]).
-export([
   type/1,
   type_container/0,

   action/1,
   action_start/0,
   action_die/0,

   identity/0,

   inspect/1
]).

%%
start() ->
   applib:boot(?MODULE, code:where_is_file("sys.config")).

%%
%%
type(Type) ->
   lens:c(lens:at(<<"Type">>), lens:require(Type)).

type_container() ->
   type(<<"container">>).

%%
%%
action(Type) ->
   lens:c(lens:at(<<"Action">>), lens:require(Type)).

action_start() ->
   action(<<"start">>).

action_die() ->
   action(<<"die">>).

%%
%%
identity() ->
   lens:at(<<"id">>).

%%
%%
inspect(Id) ->
   [m_http ||
      cats:new(uri:segments([containers, Id, json], uri:new("http://127.0.0.1:2376"))),
      cats:method('GET'),
      cats:header("Connection", "close"),
      cats:request(30000),
      cats:unit( erlang:iolist_to_binary( tl(_) ) ),
      cats:unit( jsx:decode(_, [return_maps]) )
   ].





