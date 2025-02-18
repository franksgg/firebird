-- Create functions in current DB
create function div (
    n1 integer,
    n2 integer
) returns double precision
    external name 'udf_compat!UC_div'
    engine udr;

create function frac (
    val double precision
) returns double precision
    external name 'udf_compat!UC_frac'
    engine udr;

create function dow (
    val timestamp
) returns varchar(53) character set none
    external name 'udf_compat!UC_dow'
    engine udr;

create function sdow (
    val timestamp
) returns varchar(13) character set none
    external name 'udf_compat!UC_sdow'
    engine udr;

create function getExactTimestampUTC
	returns timestamp
    external name 'udf_compat!UC_getExactTimestampUTC'
    engine udr;

create function isLeapYear (
    val timestamp
) returns boolean
    external name 'udf_compat!UC_isLeapYear'
    engine udr;

create function exec (
    val varchar(1024)
) returns integer
    external name 'udf_compat!UC_exec'
    engine udr;    
    
create function free_ram () returns bigint
    external name 'udf_compat!UC_free_ram'
    engine udr;

create function free_swap () returns bigint
    external name 'udf_compat!UC_free_swap'
    engine udr;
    
create function total_swap () returns bigint
    external name 'udf_compat!UC_total_swap'
    engine udr;
    
create function total_ram () returns bigint
    external name 'udf_compat!UC_total_ram'
    engine udr;
create function b_savetofile (
    VAL varchar(1024),
    B blob )
    returns integer
    external name 'udf_compat!UC_b_save'
    engine udr;
create function b_loadfromfile (
    VAL varchar(1024))
    returns blob
    external name 'udf_compat!UC_b_load'
    engine udr;

-- Run minimum test
select 25, 3, div(25, 3) from rdb$database;
select pi(), frac(pi()) from rdb$database;
select timestamp '2020-01-29', dow(timestamp '2020-01-29'), sdow(timestamp '2020-01-29') from rdb$database;
set time zone 'utc';
select cast(((current_timestamp - getexacttimestamputc()) * 1000) as integer) as getexacttimestamptest from rdb$database;
set time zone local;
select timestamp '2019-01-29', isleapyear(timestamp '2019-01-29') from rdb$database;
select timestamp '2020-01-29', isleapyear(timestamp '2020-01-29') from rdb$database;
