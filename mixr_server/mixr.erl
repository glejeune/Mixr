% Copyright (c) 2008 Gregoire Lejeune
%  
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to
% deal in the Software without restriction, including without limitation the
% rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
% sell copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%   
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%    
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
% THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
% IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
% CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

-module(mixr).
-author('gregoire.lejeune@free.fr').
-compile(export_all).
-import(random).
-include_lib("stdlib/include/qlc.hrl").

%% The primary key of the table is the ﬁrst column in the table. So...
-record(mixr_cache, {key, value}).

%% Version du server
-define(MIXR_VERSION, "0.2.0").

%% Ceci permet de créer la base Mnesia
do_this_once() ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(mixr_cache, [{attributes, record_info(fields, mixr_cache)}]),
  mnesia:stop().

%% Démarrage du serveur.
start(Port) ->
	do_this_once(),
	mnesia:start(),
	mnesia:wait_for_tables([mixr_cache], 20000),
  {ok, ListenSocket} = gen_tcp:listen(Port, [binary, {packet, 0}, {active, false}]),
	error_logger:info_msg("** Mixr version ~s Started (port ~p)~n", [?MIXR_VERSION, Port]),
  loop(ListenSocket).
start() ->
  case file:consult("mixr.conf") of
    {ok, C} ->
			error_logger:info_msg("** Read config from ./mixr.conf~n"),
      [{port, P}] = C,
      start(P);
    {error, _} ->
      case file:consult(filename:absname_join(os_home(), "mixr.conf")) of
        {ok, C} ->
          error_logger:info_msg("** Read config from $HOME/mixr.conf~n"),
          [{port, P}] = C,
          start(P);
        {error, _} ->
          error_logger:info_msg("No configuration file found. Start mixr server on port 9900!"),
					start(9900)
      end
  end.

loop(ListenSocket) ->
  case gen_tcp:accept(ListenSocket) of
    {ok, Socket} -> 
      spawn(fun() -> 
        handle_connection(Socket) 
      end),
			loop(ListenSocket);
    {error, Reason} ->
      io:format("Error: ~p~n", [Reason])
  end.

handle_connection(Socket) ->
  try communication(Socket)
  catch
    error:Reason ->
      {gen_tcp:send(Socket, io_lib:format("Error: ~p~n", [Reason]))}
  end,
  ok = gen_tcp:close(Socket).

communication(Socket) ->
  {ok, Binary} = gen_tcp:recv(Socket, 0),
	{ok, {Address, _}} = inet:peername(Socket),
	error_logger:info_msg( "~p ask Mixr server : ~p~n", [Address, Binary]),
	{ok, [A|D]} = regexp:split( binary_to_list(Binary), "@" ),
	case A of
		"KEYS" -> R = keys();
		"VALUES" -> R = values();
		"CLEAR" -> R = clear();
		"DELETE" -> [R] = delete(D);
		"GET" -> [R] = do_get(D);
		"SET" -> R = do_set(D)
	end,
  gen_tcp:send(Socket, io_lib:format( "~p", [R] )).

keys() ->
	do(qlc:q([X#mixr_cache.key || X <- mnesia:table(mixr_cache)])).

values() ->
	do(qlc:q([X#mixr_cache.value || X <- mnesia:table(mixr_cache)])).

clear() ->
	lists:foreach( fun(E) ->
			mnesia:transaction( fun() -> mnesia:delete({mixr_cache, E}) end )
		end, keys() ),
	true.

delete(T) ->
	R = do_get(T),
	[K] = T,
	mnesia:transaction( fun() -> mnesia:delete({mixr_cache, K}) end ),
	R.
	
do_get(T) ->
	[K] = T,
	do(qlc:q([X#mixr_cache.value || X <- mnesia:table(mixr_cache),
			   X#mixr_cache.key =:= K
			])).
	
do_set(T) ->
	[D] = T,
	{ok, [K, V]} = regexp:split( D, "|" ),
	Row = #mixr_cache{key=K, value=V},
	F = fun() ->
		mnesia:write(Row)
	end,
	case mnesia:transaction(F) of
		{aborted, _} -> false;
		{atomic, _} -> true
	end.

view() ->
	io:format( "~p~n", [do(qlc:q([X || X <- mnesia:table(mixr_cache)]))] ).
	
do(Q) ->
    F = fun() -> qlc:e(Q) end,
    {atomic, Val} = mnesia:transaction(F),
    Val.

os_home() ->
	case os:type() of
		{win32, _} -> HOME = os:getenv("USERPROFILE");
		{unix, _} -> HOME = os:getenv("HOME")
	end,
	HOME.