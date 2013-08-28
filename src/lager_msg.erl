-module(lager_msg).

-export([new/4, new/5]).
-export([message/1]).
-export([datetime/1]).
-export([severity/1]).
-export([severity_as_int/1]).
-export([metadata/1]).
-export([destinations/1]).

-record(lager_msg,{
        destinations :: list(),
        metadata :: [tuple()],
        severity :: lager:log_level(),
        datetime :: {string(), string()},
        message :: list()
    }).

-opaque lager_msg() :: #lager_msg{}.
-export_type([lager_msg/0]).

%% create with provided timestamp, handy for testing mostly
-spec new(list(), erlang:timestamp() | 'undefined', lager:log_level(), [tuple()], list()) -> lager_msg().
new(Msg, undefined, Severity, Metadata, Destinations) ->
    #lager_msg{message=Msg, datetime={"Undefined", "Undefined"}, severity=Severity,
	       metadata=Metadata, destinations=Destinations};
new(Msg, Timestamp, Severity, Metadata, Destinations) ->
    {Date, Time} = lager_util:format_time(lager_util:maybe_utc(lager_util:localtime_ms(Timestamp))),
    #lager_msg{message=Msg, datetime={Date, Time}, severity=Severity,
        metadata=Metadata, destinations=Destinations}.

-spec new(list(), lager:log_level(), [tuple()], list()) -> lager_msg().
new(Msg, Severity, Metadata, Destinations) ->
    Timestamp =
	case application:get_env(lager, use_timestamp) of
	    {ok, false} ->
		undefined;
	    _ ->
		os:timestamp()
	end,
    new(Msg, Timestamp, Severity, Metadata, Destinations).

-spec message(lager_msg()) -> list().
message(Msg) ->
    Msg#lager_msg.message.

-spec datetime(lager_msg()) -> {string(), string()}.
datetime(Msg) ->
    Msg#lager_msg.datetime.

-spec severity(lager_msg()) -> lager:log_level().
severity(Msg) ->
    Msg#lager_msg.severity.

-spec severity_as_int(lager_msg()) -> lager:log_level_number().
severity_as_int(Msg) ->
    lager_util:level_to_num(Msg#lager_msg.severity).

-spec metadata(lager_msg()) -> [tuple()].
metadata(Msg) ->
    Msg#lager_msg.metadata.

-spec destinations(lager_msg()) -> list().
destinations(Msg) ->
    Msg#lager_msg.destinations.


