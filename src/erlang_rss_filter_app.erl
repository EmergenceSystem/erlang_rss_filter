%%%-------------------------------------------------------------------
%%% @doc Erlang and Elixir RSS filter.
%%%
%%% Copies priv/rss_config.json to the working directory then starts
%%% an rss_filter agent under its own name with specific capabilities.
%%% @end
%%%-------------------------------------------------------------------
-module(erlang_rss_filter_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    copy_config(),
    application:ensure_all_started(rss_filter),
    em_filter:start_agent(erlang_filter, rss_filter_app, #{
        capabilities => rss_filter_app:base_capabilities()
                        ++ [<<"erlang">>, <<"elixir">>, <<"beam">>,
                            <<"functional">>, <<"otp">>]
    }),
    {ok, self()}.

stop(_State) ->
    em_filter:stop_agent(erlang_filter).

copy_config() ->
    case code:priv_dir(erlang_rss_filter) of
        PrivDir when is_list(PrivDir) ->
            Src = filename:join(PrivDir, "rss_config.json"),
            file:copy(Src, "rss_config.json"),
            ok;
        {error, bad_name} ->
            ok
    end.
