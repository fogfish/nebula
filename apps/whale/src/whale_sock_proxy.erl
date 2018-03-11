%%
%% @doc
%%   Containers events stream
-module(whale_sock_proxy).
-behaviour(pipe).
-compile({parse_transform, category}).

-export([
   start_link/0,
   init/1,
   free/2,
   proxy/3
]).

%%
%% script bootstrap code
-define(BOOTSTRAP, "echo \"pid $$\"; exec socat -d TCP-LISTEN:2376,range=127.0.0.1/32,reuseaddr,fork UNIX:/var/run/docker.sock").
-define(KILL,      "kill ~s").

%% global port options
-define(PORT(X), [
   {args, ["-c", X]}
  ,binary
  ,stream
  ,exit_status
  ,use_stdio
  ,stderr_to_stdout
  ,hide
]).

-record(state, {
   port = undefined,
   proc = undefined
}).

start_link() ->
   pipe:start_link(?MODULE, [], []).

init(_) ->
   erlang:process_flag(trap_exit, true),
   Shell = os:find_executable(sh),
   Cmd   = ?BOOTSTRAP,
   Port  = erlang:open_port({spawn_executable, Shell}, ?PORT(Cmd)),
   wait_for_socat(),
   {ok, proxy, #state{port = Port}}.

free(_, #state{port = Port, proc = Proc}) ->
   Cmd = lists:flatten( io_lib:format(?KILL, [Proc]) ),
   os:cmd(Cmd),
   erlang:port_close(Port).

proxy({_Port, {data, <<$p, $i, $d, $ , Pid/binary>>}}, _, State) ->
   Proc = hd(string:tokens(scalar:c(Pid), "\n")),
   {next_state, proxy, State#state{proc = Proc}}.

wait_for_socat() ->
   case
      [either ||
         Sock <- knet:connect("http://localhost:2376/version"),
         Data <- cats:unit( stream:list(knet:stream(Sock)) ),
         knet:close(Sock),
         cats:unit(Data)
      ]
   of
      {ok, [{200, _, _} | Version]} ->
         lager:info("[whale] api ~p", [jsx:decode(scalar:s(Version))]);
      _ ->
         wait_for_socat()
   end.


