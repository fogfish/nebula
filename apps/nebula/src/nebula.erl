-module(nebula).

-export([start/0]).
% -export([
%    port/1
% ]).

-define(M, 9).

%%
start() ->
   applib:boot(?MODULE, code:where_is_file("sys.config")).


% port(Node)
%  when is_binary(Node) ->
%    <<Addr:?M, _/bits>> = crypto:hash(sha, Node),
%    Addr.


