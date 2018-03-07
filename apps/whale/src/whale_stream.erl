%%
%% @doc
%%   Containers events stream
-module(whale_stream).
-behaviour(pipe).

-compile({parse_transform, lager_transform}).
-compile({parse_transform, category}).

-export([
   start_link/0,
   init/1,
   free/2,
   listen/3
]).


%%
%%
-record(state, {
   sock = undefined :: pid()
}).

%%-----------------------------------------------------------------------------
%%
%% factory
%%
%%-----------------------------------------------------------------------------

start_link() ->
   pipe:start_link(?MODULE, [], []).

init([]) ->
   [either ||
      knet:connect("http://127.0.0.1:2376/events"),
      cats:unit(listen, 
         #state{
            sock = _
         }
      )
   ].

free(_, #state{sock = Sock}) ->
   knet:close(Sock).

%%-----------------------------------------------------------------------------
%%
%% listener
%%
%%-----------------------------------------------------------------------------

listen({http, _, {200, _, Head}}, _, #state{} = State) ->
   lager:info("[whale] connected ~s", [jsx:encode(Head)]),
   {next_state, listen, State};

listen({http, _, {Err, _, Head}}, _, #state{} = State) ->
   lager:error("[whale] connection error ~s", [jsx:encode(Head)]),
   {stop, {http, Err}, State};

listen({http, _, eof}, _, #state{} = State) ->
   lager:error("[whale] connection is closed"),
   {stop, {http, eof}, State};

listen({http, _, Pckt}, Pipe, #state{} = State) ->
   lists:foreach(
      fun(Json) -> upstream(Pipe, Json) end, 
      binary:split(Pckt, <<$\n>>, [trim, global])
   ),
   {next_state, listen, State}.

%%
%%
upstream(Pipe, Json) ->
   try
      pipe:b(Pipe, jsx:decode(Json, [return_maps]))
   catch Error:Reason ->
      error_logger:error_report([
         {error,  Error},
         {reason, Reason},
         {packet, Json},
         {stack,   erlang:get_stacktrace()}
      ])
   end.

