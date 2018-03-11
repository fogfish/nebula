-module(nebula).

-export([start/0]).

%%
start() ->
   applib:boot(?MODULE, code:where_is_file("sys.config")).
