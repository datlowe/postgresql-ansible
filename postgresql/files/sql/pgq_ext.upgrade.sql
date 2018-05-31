
--
-- Section: Functions
--



create or replace function pgq_ext.upgrade_schema()
returns int4 as $$
-- updates table structure if necessary
-- ----------------------------------------------------------------------
-- Function: pgq_ext.upgrade_schema()
--
--	    Upgrades tables to have column subconsumer_id 
--
-- Parameters:
--      None
--
-- Returns:
--	    number of tables updated 
-- Calls:
--      None
-- Tables directly manipulated:
--      alter - pgq_ext.completed_batch
--      alter - pgq_ext.completed_tick
--      alter - pgq_ext.partial_batch
--      alter - pgq_ext.completed_event
-- ----------------------------------------------------------------------
declare
    cnt int4 = 0;
    tbl text;
    sql text;
begin
    -- pgq_ext.completed_batch: subconsumer_id
    perform 1 from information_schema.columns
      where table_schema = 'pgq_ext'
        and table_name = 'completed_batch'
        and column_name = 'subconsumer_id';
    if not found then
        alter table pgq_ext.completed_batch
            add column subconsumer_id text;
        update pgq_ext.completed_batch
            set subconsumer_id = '';
        alter table pgq_ext.completed_batch
            alter column subconsumer_id set not null;
        alter table pgq_ext.completed_batch
            drop constraint completed_batch_pkey;
        alter table pgq_ext.completed_batch
            add constraint completed_batch_pkey
            primary key (consumer_id, subconsumer_id);
        cnt := cnt + 1;
    end if;

    -- pgq_ext.completed_tick: subconsumer_id
    perform 1 from information_schema.columns
      where table_schema = 'pgq_ext'
        and table_name = 'completed_tick'
        and column_name = 'subconsumer_id';
    if not found then
        alter table pgq_ext.completed_tick
            add column subconsumer_id text;
        update pgq_ext.completed_tick
            set subconsumer_id = '';
        alter table pgq_ext.completed_tick
            alter column subconsumer_id set not null;
        alter table pgq_ext.completed_tick
            drop constraint completed_tick_pkey;
        alter table pgq_ext.completed_tick
            add constraint completed_tick_pkey
            primary key (consumer_id, subconsumer_id);
        cnt := cnt + 1;
    end if;

    -- pgq_ext.partial_batch: subconsumer_id
    perform 1 from information_schema.columns
      where table_schema = 'pgq_ext'
        and table_name = 'partial_batch'
        and column_name = 'subconsumer_id';
    if not found then
        alter table pgq_ext.partial_batch
            add column subconsumer_id text;
        update pgq_ext.partial_batch
            set subconsumer_id = '';
        alter table pgq_ext.partial_batch
            alter column subconsumer_id set not null;
        alter table pgq_ext.partial_batch
            drop constraint partial_batch_pkey;
        alter table pgq_ext.partial_batch
            add constraint partial_batch_pkey
            primary key (consumer_id, subconsumer_id);
        cnt := cnt + 1;
    end if;

    -- pgq_ext.completed_event: subconsumer_id
    perform 1 from information_schema.columns
      where table_schema = 'pgq_ext'
        and table_name = 'completed_event'
        and column_name = 'subconsumer_id';
    if not found then
        alter table pgq_ext.completed_event
            add column subconsumer_id text;
        update pgq_ext.completed_event
            set subconsumer_id = '';
        alter table pgq_ext.completed_event
            alter column subconsumer_id set not null;
        alter table pgq_ext.completed_event
            drop constraint completed_event_pkey;
        alter table pgq_ext.completed_event
            add constraint completed_event_pkey
            primary key (consumer_id, subconsumer_id, batch_id, event_id);
        cnt := cnt + 1;
    end if;

    -- add default value to subconsumer_id column
    for tbl in
        select table_name
           from information_schema.columns
           where table_schema = 'pgq_ext'
             and table_name in ('completed_tick', 'completed_event', 'partial_batch', 'completed_batch')
             and column_name = 'subconsumer_id'
             and column_default is null
    loop
        sql := 'alter table pgq_ext.' || tbl
            || ' alter column subconsumer_id set default ' || quote_literal('');
        execute sql;
        cnt := cnt + 1;
    end loop;

    return cnt;
end;
$$ language plpgsql;




select pgq_ext.upgrade_schema();

-- Group: track batches via batch id


create or replace function pgq_ext.is_batch_done(
    a_consumer text,
    a_subconsumer text,
    a_batch_id bigint)
returns boolean as $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.is_batch_done(3)
--
--	    Checks if a certain consumer and subconsumer have completed the batch 
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_batch_id - a batch id
--
-- Returns:
--	    true if batch is done, else false 
-- Calls:
--      None
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
declare
    res   boolean;
begin
    select last_batch_id = a_batch_id
      into res from pgq_ext.completed_batch
     where consumer_id = a_consumer
       and subconsumer_id = a_subconsumer;
    if not found then
        return false;
    end if;
    return res;
end;
$$ language plpgsql security definer;

create or replace function pgq_ext.is_batch_done(
    a_consumer text,
    a_batch_id bigint)
returns boolean as $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.is_batch_done(2)
--
--	    Checks if a certain consumer has completed the batch 
--
-- Parameters:
--      a_consumer - consumer name
--      a_batch_id - a batch id
--
-- Returns:
--	    true if batch is done, else false 
-- Calls:
--      pgq_ext.is_batch_done(3)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.is_batch_done(a_consumer, '', a_batch_id);
end;
$$ language plpgsql;




create or replace function pgq_ext.set_batch_done(
    a_consumer text,
    a_subconsumer text,
    a_batch_id bigint)
returns boolean as $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_batch_done(3)
--
--	    Marks a batch as "done"  for certain consumer and subconsumer 
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_batch_id - a batch id
--
-- Returns:
--      false if it already was done
--	    true for successfully marking it as done 
-- Calls:
--      None
-- Tables directly manipulated:
--      update - pgq_ext.completed_batch
-- ----------------------------------------------------------------------
begin
    if pgq_ext.is_batch_done(a_consumer, a_subconsumer, a_batch_id) then
        return false;
    end if;

    if a_batch_id > 0 then
        update pgq_ext.completed_batch
           set last_batch_id = a_batch_id
         where consumer_id = a_consumer
           and subconsumer_id = a_subconsumer;
        if not found then
            insert into pgq_ext.completed_batch (consumer_id, subconsumer_id, last_batch_id)
                values (a_consumer, a_subconsumer, a_batch_id);
        end if;
    end if;

    return true;
end;
$$ language plpgsql security definer;

create or replace function pgq_ext.set_batch_done(
    a_consumer text,
    a_batch_id bigint)
returns boolean as $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_batch_done(3)
--
--	    Marks a batch as "done"  for certain consumer 
--
-- Parameters:
--      a_consumer - consumer name
--      a_batch_id - a batch id
--
-- Returns:
--      false if it already was done
--	    true for successfully marking it as done 
-- Calls:
--      pgq_ext.set_batch_done(3)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.set_batch_done(a_consumer, '', a_batch_id);
end;
$$ language plpgsql;



-- Group: track batches via tick id


create or replace function pgq_ext.get_last_tick(a_consumer text, a_subconsumer text)
returns int8 as $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.get_last_tick(2)
--
--	Gets last completed tick for this consumer 
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--
-- Returns:
--	    tick_id - last completed tick 
-- Calls:
--      None
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
declare
    res   int8;
begin
    select last_tick_id into res
      from pgq_ext.completed_tick
     where consumer_id = a_consumer
       and subconsumer_id = a_subconsumer;
    return res;
end;
$$ language plpgsql security definer;

create or replace function pgq_ext.get_last_tick(a_consumer text)
returns int8 as $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.get_last_tick(1)
--
--	Gets last completed tick for this consumer 
--
-- Parameters:
--      a_consumer - consumer name
--
-- Returns:
--	    tick_id - last completed tick 
-- Calls:
--      pgq_ext.get_last_tick(2)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.get_last_tick(a_consumer, '');
end;
$$ language plpgsql;




create or replace function pgq_ext.set_last_tick(
    a_consumer text,
    a_subconsumer text,
    a_tick_id bigint)
returns integer as $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_last_tick(3)
--
--	    records last completed tick for consumer,
--      removes row if a_tick_id is NULL 
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_tick_id - a tick id
--
-- Returns:
--      1
-- Calls:
--      None
-- Tables directly manipulated:
--      delete - pgq_ext.completed_tick
--      update - pgq_ext.completed_tick
--      insert - pgq_ext.completed_tick 
-- ----------------------------------------------------------------------
begin
    if a_tick_id is null then
        delete from pgq_ext.completed_tick
         where consumer_id = a_consumer
           and subconsumer_id = a_subconsumer;
    else   
        update pgq_ext.completed_tick
           set last_tick_id = a_tick_id
         where consumer_id = a_consumer
           and subconsumer_id = a_subconsumer;
        if not found then
            insert into pgq_ext.completed_tick
                (consumer_id, subconsumer_id, last_tick_id)
                values (a_consumer, a_subconsumer, a_tick_id);
        end if;
    end if;

    return 1;
end;
$$ language plpgsql security definer;

create or replace function pgq_ext.set_last_tick(
    a_consumer text,
    a_tick_id bigint)
returns integer as $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_last_tick(2)
--
--	    records last completed tick for consumer,
--      removes row if a_tick_id is NULL 
--
-- Parameters:
--      a_consumer - consumer name
--      a_tick_id - a tick id
--
-- Returns:
--      1
-- Calls:
--      pgq_ext.set_last_tick(2)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.set_last_tick(a_consumer, '', a_tick_id);
end;
$$ language plpgsql;




-- Group: Track events separately


create or replace function pgq_ext.is_event_done(
    a_consumer text,
    a_subconsumer text,
    a_batch_id bigint,
    a_event_id bigint)
returns boolean as $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.is_event_done(4)
--
--	    Checks if a certain consumer and subconsumer have "done" and event
--      in a batch  
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_batch_id - a batch id
--      a_event_id - an event id
--
-- Returns:
--	    true if event is done, else false 
-- Calls:
--      None
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
declare
    res   bigint;
begin
    perform 1 from pgq_ext.completed_event
     where consumer_id = a_consumer
       and subconsumer_id = a_subconsumer
       and batch_id = a_batch_id
       and event_id = a_event_id;
    return found;
end;
$$ language plpgsql security definer;

create or replace function pgq_ext.is_event_done(
    a_consumer text,
    a_batch_id bigint,
    a_event_id bigint)
returns boolean as $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.is_event_done(3)
--
--	    Checks if a certain consumer has "done" and event
--      in a batch  
--
-- Parameters:
--      a_consumer - consumer name
--      a_batch_id - a batch id
--      a_event_id - an event id
--
-- Returns:
--	    true if event is done, else false 
-- Calls:
--      Nonpgq_ext.is_event_done(4)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.is_event_done(a_consumer, '', a_batch_id, a_event_id);
end;
$$ language plpgsql;




create or replace function pgq_ext.set_event_done(
    a_consumer text,
    a_subconsumer text,
    a_batch_id bigint,
    a_event_id bigint)
returns boolean as $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_event_done(4)
--
--	    Marks and event done in a batch for a certain consumer and subconsumer
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_batch_id - a batch id
--      a_event_id - an event id
--
-- Returns:
--      false if already done
--	    true on success 
-- Calls:
--      None
-- Tables directly manipulated:
--      insert - pgq_ext.partial_batch
--      delete - pgq_ext.completed_event
--      update - pgq_ext.partial_batch
--      insert - pgq_ext.completed_event
-- ----------------------------------------------------------------------
declare
    old_batch bigint;
begin
    -- check if done
    perform 1 from pgq_ext.completed_event
     where consumer_id = a_consumer
       and subconsumer_id = a_subconsumer
       and batch_id = a_batch_id
       and event_id = a_event_id;
    if found then
        return false;
    end if;

    -- if batch changed, do cleanup
    select cur_batch_id into old_batch
        from pgq_ext.partial_batch
        where consumer_id = a_consumer
          and subconsumer_id = a_subconsumer;
    if not found then
        -- first time here
        insert into pgq_ext.partial_batch
            (consumer_id, subconsumer_id, cur_batch_id)
            values (a_consumer, a_subconsumer, a_batch_id);
    elsif old_batch <> a_batch_id then
        -- batch changed, that means old is finished on queue db
        -- thus the tagged events are not needed anymore
        delete from pgq_ext.completed_event
            where consumer_id = a_consumer
              and subconsumer_id = a_subconsumer
              and batch_id = old_batch;
        -- remember current one
        update pgq_ext.partial_batch
            set cur_batch_id = a_batch_id
            where consumer_id = a_consumer
              and subconsumer_id = a_subconsumer;
    end if;

    -- tag as done
    insert into pgq_ext.completed_event
        (consumer_id, subconsumer_id, batch_id, event_id)
        values (a_consumer, a_subconsumer, a_batch_id, a_event_id);

    return true;
end;
$$ language plpgsql security definer;

create or replace function pgq_ext.set_event_done(
    a_consumer text,
    a_batch_id bigint,
    a_event_id bigint)
returns boolean as $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_event_done(3)
--
--	    Marks and event done in a batch for a certain consumer and subconsumer
--
-- Parameters:
--      a_consumer - consumer name
--      a_batch_id - a batch id
--      a_event_id - an event id
--
-- Returns:
--      false if already done
--	    true on success 
-- Calls:
--      pgq_ext.set_event_done(4)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.set_event_done(a_consumer, '', a_batch_id, a_event_id);
end;
$$ language plpgsql;



-- Group: Schema info


create or replace function pgq_ext.version()
returns text as $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.version(0)
--
--      Returns version string for pgq_ext.  ATM it is based SkyTools version
--      only bumped when database code changes.
-- ----------------------------------------------------------------------
begin
    return '3.1';
end;
$$ language plpgsql;




