


create schema pgq_coop;




-- ----------------------------------------------------------------------
-- Section: Functions
--
-- Overview:
-- 
-- The usual flow of a cooperative consumer is to
-- 
--  1. register itself as a subconsumer for a queue:
--      pgq_coop.register_subconsumer() 
-- 
-- And the run a loop doing
--
--  2A. pgq_coop.next_batch ()
--
--  2B. pgq_coop.finish_batch()
-- 
-- Once the cooperative (or sub-)consuber is done, it should unregister 
-- itself before exiting
-- 
--  3. pgq_coop.unregister_subconsumer() 
-- 
-- 
-- ----------------------------------------------------------------------

-- Group: Subconsumer registration

create or replace function pgq_coop.register_subconsumer(
    i_queue_name text,
    i_consumer_name text,
    i_subconsumer_name text)
returns integer as $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.register_subconsumer(3)
--
--	    Subscribe a subconsumer on a queue.
--
--      Subconsumer will be registered as another consumer on queue,
--      whose name will be i_consumer_name and i_subconsumer_name
--      combined.
--
-- Returns:
--	    0 - if already registered
--	    1 - if this is a new registration
--
-- Calls:
--      pgq.register_consumer(i_queue_name, i_consumer_name)
--      pgq.register_consumer(i_queue_name, _subcon_name);
--
-- Tables directly manipulated:
--      update - pgq.subscription
-- 
-- ----------------------------------------------------------------------
declare
    _subcon_name text; -- consumer + subconsumer
    _queue_id integer;
    _consumer_id integer;
    _subcon_id integer;
    _consumer_sub_id integer;
    _subcon_result integer;
    r record;
begin
    _subcon_name := i_consumer_name || '.' || i_subconsumer_name;

    -- make sure main consumer exists
    perform pgq.register_consumer(i_queue_name, i_consumer_name);

    -- just go and register the subconsumer as a regular consumer
    _subcon_result := pgq.register_consumer(i_queue_name, _subcon_name);

    -- if it is a new registration
    if _subcon_result = 1 then
        select q.queue_id, mainc.co_id as main_consumer_id,
               s.sub_id as main_consumer_sub_id,
               subc.co_id as sub_consumer_id
            into r
            from pgq.queue q, pgq.subscription s, pgq.consumer mainc, pgq.consumer subc
            where mainc.co_name = i_consumer_name
              and subc.co_name = _subcon_name
              and q.queue_name = i_queue_name
              and s.sub_queue = q.queue_id
              and s.sub_consumer = mainc.co_id;
        if not found then
            raise exception 'main consumer not found';
        end if;

        -- duplicate the sub_id of consumer to the subconsumer
        update pgq.subscription s
            set sub_id = r.main_consumer_sub_id,
                sub_last_tick = null,
                sub_next_tick = null
            where sub_queue = r.queue_id
              and sub_consumer = r.sub_consumer_id;
    end if;

    return _subcon_result;
end;
$$ language plpgsql security definer;



create or replace function pgq_coop.unregister_subconsumer(
    i_queue_name text,
    i_consumer_name text,
    i_subconsumer_name text,
    i_batch_handling integer)
returns integer as $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.unregister_subconsumer(4)
--
--      Unregisters subconsumer from the queue.
--
--      If consumer has active batch, then behviour depends on
--      i_batch_handling parameter.
--
-- Values for i_batch_handling:
--      0 - Fail with an exception.
--      1 - Close the batch, ignoring the events.
--
-- Returns:
--	    0 - no consumer found
--      1 - consumer found and unregistered
--
-- Tables directly manipulated:
--      delete - pgq.subscription
--
-- ----------------------------------------------------------------------
declare
    _current_batch bigint;
    _queue_id integer;
    _subcon_id integer;
begin
    select q.queue_id, c.co_id, sub_batch
        into _queue_id, _subcon_id, _current_batch
        from pgq.queue q, pgq.consumer c, pgq.subscription s
        where c.co_name = i_consumer_name || '.' || i_subconsumer_name
          and q.queue_name = i_queue_name
          and s.sub_queue = q.queue_id
          and s.sub_consumer = c.co_id;
    if not found then
        return 0;
    end if;

    if _current_batch is not null then
        if i_batch_handling = 1 then
            -- ignore active batch
        else
            raise exception 'subconsumer has active batch';
        end if;
    end if;

    delete from pgq.subscription
        where sub_queue = _queue_id
          and sub_consumer = _subcon_id;

    return 1;
end;
$$ language plpgsql security definer;



-- Group: Event processing

create or replace function pgq_coop.next_batch(
    i_queue_name text,
    i_consumer_name text,
    i_subconsumer_name text)
returns bigint as $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.next_batch(3)
--
--	Makes next block of events active
--
--	Result NULL means nothing to work with, for a moment
--
-- Parameters:
--	i_queue_name		- Name of the queue
--	i_consumer_name		- Name of the consumer
--	i_subconsumer_name	- Name of the subconsumer
--
-- Calls:
--      pgq.register_consumer(i_queue_name, i_consumer_name)
--      pgq.register_consumer(i_queue_name, _subcon_name);
--
-- Tables directly manipulated:
--      update - pgq.subscription
-- 
-- ----------------------------------------------------------------------
begin
    return pgq_coop.next_batch_custom(i_queue_name, i_consumer_name, i_subconsumer_name, NULL, NULL, NULL, NULL);
end;
$$ language plpgsql;

create or replace function pgq_coop.next_batch(
    i_queue_name text,
    i_consumer_name text,
    i_subconsumer_name text,
    i_dead_interval interval)
returns bigint as $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.next_batch(4)
--
--	Makes next block of events active
--
--      If i_dead_interval is set, other subconsumers are checked for
--      inactivity.  If some subconsumer has active batch, but has
--      been inactive more than i_dead_interval, the batch is taken over.
--
--	Result NULL means nothing to work with, for a moment
--
-- Parameters:
--	i_queue_name		- Name of the queue
--	i_consumer_name		- Name of the consumer
--	i_subconsumer_name	- Name of the subconsumer
--      i_dead_interval         - Take over other subconsumer batch if inactive
-- ----------------------------------------------------------------------
begin
    return pgq_coop.next_batch_custom(i_queue_name, i_consumer_name, i_subconsumer_name, NULL, NULL, NULL, i_dead_interval);
end;
$$ language plpgsql;

create or replace function pgq_coop.next_batch_custom(
    i_queue_name text,
    i_consumer_name text,
    i_subconsumer_name text,
    i_min_lag interval,
    i_min_count int4,
    i_min_interval interval)
returns bigint as $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.next_batch_custom(6)
--
--      Makes next block of events active.  Block size can be tuned
--      with i_min_count, i_min_interval parameters.  Events age can
--      be tuned with i_min_lag.
--
--	Result NULL means nothing to work with, for a moment
--
-- Parameters:
--	i_queue_name		- Name of the queue
--	i_consumer_name		- Name of the consumer
--	i_subconsumer_name	- Name of the subconsumer
--      i_min_lag           - Consumer wants events older than that
--      i_min_count         - Consumer wants batch to contain at least this many events
--      i_min_interval      - Consumer wants batch to cover at least this much time
-- ----------------------------------------------------------------------
begin
    return pgq_coop.next_batch_custom(i_queue_name, i_consumer_name, i_subconsumer_name,
                                      i_min_lag, i_min_count, i_min_interval, NULL);
end;
$$ language plpgsql;

create or replace function pgq_coop.next_batch_custom(
    i_queue_name text,
    i_consumer_name text,
    i_subconsumer_name text,
    i_min_lag interval,
    i_min_count int4,
    i_min_interval interval,
    i_dead_interval interval)
returns bigint as $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.next_batch_custom(7)
--
--      Makes next block of events active.  Block size can be tuned
--      with i_min_count, i_min_interval parameters.  Events age can
--      be tuned with i_min_lag.
--
--      If i_dead_interval is set, other subconsumers are checked for
--      inactivity.  If some subconsumer has active batch, but has
--      been inactive more than i_dead_interval, the batch is taken over.
--
--	Result NULL means nothing to work with, for a moment
--
-- Parameters:
--      i_queue_name        - Name of the queue
--      i_consumer_name     - Name of the consumer
--      i_subconsumer_name  - Name of the subconsumer
--      i_min_lag           - Consumer wants events older than that
--      i_min_count         - Consumer wants batch to contain at least this many events
--      i_min_interval      - Consumer wants batch to cover at least this much time
--      i_dead_interval     - Take over other subconsumer batch if inactive
-- Calls:
--      pgq.register_subconsumer(i_queue_name, i_consumer_name, i_subconsumer_name)
--      pgq.next_batch_custom(i_queue_name, i_consumer_name, i_min_lag, i_min_count, i_min_interval)
-- Tables directly manipulated:
--      update - pgq.subscription
-- ----------------------------------------------------------------------
declare
    _queue_id integer;
    _consumer_id integer;
    _subcon_id integer;
    _batch_id bigint;
    _prev_tick bigint;
    _cur_tick bigint;
    _sub_id integer;
    _dead record;
begin
    -- fetch master consumer details, lock the row
    select q.queue_id, c.co_id, s.sub_next_tick
        into _queue_id, _consumer_id, _cur_tick
        from pgq.queue q, pgq.consumer c, pgq.subscription s
        where q.queue_name = i_queue_name
          and c.co_name = i_consumer_name
          and s.sub_queue = q.queue_id
          and s.sub_consumer = c.co_id
        for update of s;
    if not found then
        perform pgq_coop.register_subconsumer(i_queue_name, i_consumer_name, i_subconsumer_name);
        -- fetch the data again
        select q.queue_id, c.co_id, s.sub_next_tick
            into _queue_id, _consumer_id, _cur_tick
            from pgq.queue q, pgq.consumer c, pgq.subscription s
            where q.queue_name = i_queue_name
              and c.co_name = i_consumer_name
              and s.sub_queue = q.queue_id
              and s.sub_consumer = c.co_id;
    end if;
    if _cur_tick is not null then
        raise exception 'main consumer has batch open?';
    end if;

    -- automatically register subconsumers
    perform 1 from pgq.subscription s, pgq.consumer c, pgq.queue q
        where q.queue_name = i_queue_name
          and s.sub_queue = q.queue_id
          and s.sub_consumer = c.co_id
          and c.co_name = i_consumer_name || '.' || i_subconsumer_name;
    if not found then
        perform pgq_coop.register_subconsumer(i_queue_name, i_consumer_name, i_subconsumer_name);
    end if;

    -- fetch subconsumer details
    select s.sub_batch, sc.co_id, s.sub_id
        into _batch_id, _subcon_id, _sub_id
        from pgq.subscription s, pgq.consumer sc
        where sub_queue = _queue_id
          and sub_consumer = sc.co_id
          and sc.co_name = i_consumer_name || '.' || i_subconsumer_name;
    if not found then
        raise exception 'subconsumer not found';
    end if;

    -- is there a batch already active
    if _batch_id is not null then
        update pgq.subscription set sub_active = now()
            where sub_queue = _queue_id
              and sub_consumer = _subcon_id;
        return _batch_id;
    end if;

    -- help dead comrade
    if i_dead_interval is not null then

        -- check if some other subconsumer has died
        select s.sub_batch, s.sub_consumer, s.sub_last_tick, s.sub_next_tick
            into _dead
            from pgq.subscription s
            where s.sub_queue = _queue_id
              and s.sub_id = _sub_id
              and s.sub_consumer <> _subcon_id
              and s.sub_consumer <> _consumer_id
              and sub_active < now() - i_dead_interval
            limit 1;

        if found then
            -- unregister old consumer
            delete from pgq.subscription
                where sub_queue = _queue_id
                  and sub_consumer = _dead.sub_consumer;

            -- if dead consumer had batch, copy it over and return
            if _dead.sub_batch is not null then
                update pgq.subscription
                    set sub_batch = _dead.sub_batch,
                        sub_last_tick = _dead.sub_last_tick,
                        sub_next_tick = _dead.sub_next_tick,
                        sub_active = now()
                    where sub_queue = _queue_id
                      and sub_consumer = _subcon_id;

                return _dead.sub_batch;
            end if;
        end if;
    end if;

    -- get a new batch for the main consumer
    select batch_id, cur_tick_id, prev_tick_id
        into _batch_id, _cur_tick, _prev_tick
        from pgq.next_batch_custom(i_queue_name, i_consumer_name, i_min_lag, i_min_count, i_min_interval);
    if _batch_id is null then
        return null;
    end if;

    -- close batch for main consumer
    update pgq.subscription
       set sub_batch = null,
           sub_active = now(),
           sub_last_tick = sub_next_tick,
           sub_next_tick = null
     where sub_queue = _queue_id
       and sub_consumer = _consumer_id;

    -- copy state into subconsumer row
    update pgq.subscription
        set sub_batch = _batch_id,
            sub_last_tick = _prev_tick,
            sub_next_tick = _cur_tick,
            sub_active = now()
        where sub_queue = _queue_id
          and sub_consumer = _subcon_id;

    return _batch_id;
end;
$$ language plpgsql security definer;



create or replace function pgq_coop.finish_batch(
    i_batch_id bigint)
returns integer as $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.finish_batch(1)
--
--	Closes a batch.
--
-- Parameters:
--	i_batch_id	- id of the batch to be closed
--
-- Returns:
--	1 if success (batch was found), 0 otherwise
-- Calls:
--      None
-- Tables directly manipulated:
--      update - pgq.subscription
-- ----------------------------------------------------------------------
begin
    -- we are dealing with subconsumer, so nullify all tick info
    -- tick columns for master consumer contain adequate data
    update pgq.subscription
       set sub_active = now(),
           sub_last_tick = null,
           sub_next_tick = null,
           sub_batch = null
     where sub_batch = i_batch_id;
    if not found then
        raise warning 'coop_finish_batch: batch % not found', i_batch_id;
        return 0;
    else
        return 1;
    end if;
end;
$$ language plpgsql security definer;



-- Group: General Info


create or replace function pgq_coop.version()
returns text as $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.version(0)
--
--      Returns version string for pgq_coop.  ATM it is based on SkyTools version
--      and only bumped when database code changes.
-- ----------------------------------------------------------------------
begin
    return '3.1.1';
end;
$$ language plpgsql;






GRANT usage ON SCHEMA pgq_coop TO public;



