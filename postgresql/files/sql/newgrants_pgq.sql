begin;


-- 1.public --
REVOKE ALL ON FUNCTION pgq.seq_getval(text),
    pgq.get_queue_info(),
    pgq.get_queue_info(text),
    pgq.get_consumer_info(),
    pgq.get_consumer_info(text),
    pgq.get_consumer_info(text, text),
    pgq.quote_fqname(text),
    pgq.version()
  FROM pgq_reader, pgq_writer, pgq_admin, public CASCADE;

-- 2.consumer --
REVOKE ALL ON FUNCTION pgq.batch_event_sql(bigint),
    pgq.batch_event_tables(bigint),
    pgq.find_tick_helper(int4, int8, timestamptz, int8, int8, interval),
    pgq.register_consumer(text, text),
    pgq.register_consumer_at(text, text, bigint),
    pgq.unregister_consumer(text, text),
    pgq.next_batch_info(text, text),
    pgq.next_batch(text, text),
    pgq.next_batch_custom(text, text, interval, int4, interval),
    pgq.get_batch_events(bigint),
    pgq.get_batch_info(bigint),
    pgq.get_batch_cursor(bigint, text, int4, text),
    pgq.get_batch_cursor(bigint, text, int4),
    pgq.event_retry(bigint, bigint, timestamptz),
    pgq.event_retry(bigint, bigint, integer),
    pgq.batch_retry(bigint, integer),
    pgq.force_tick(text),
    pgq.finish_batch(bigint)
  FROM pgq_reader, pgq_writer, pgq_admin, public CASCADE;
REVOKE ALL ON FUNCTION pgq.batch_event_sql(bigint),
    pgq.batch_event_tables(bigint),
    pgq.find_tick_helper(int4, int8, timestamptz, int8, int8, interval),
    pgq.register_consumer(text, text),
    pgq.register_consumer_at(text, text, bigint),
    pgq.unregister_consumer(text, text),
    pgq.next_batch_info(text, text),
    pgq.next_batch(text, text),
    pgq.next_batch_custom(text, text, interval, int4, interval),
    pgq.get_batch_events(bigint),
    pgq.get_batch_info(bigint),
    pgq.get_batch_cursor(bigint, text, int4, text),
    pgq.get_batch_cursor(bigint, text, int4),
    pgq.event_retry(bigint, bigint, timestamptz),
    pgq.event_retry(bigint, bigint, integer),
    pgq.batch_retry(bigint, integer),
    pgq.force_tick(text),
    pgq.finish_batch(bigint)
  FROM public CASCADE;

-- 3.producer --
REVOKE ALL ON FUNCTION pgq.insert_event(text, text, text),
    pgq.insert_event(text, text, text, text, text, text, text),
    pgq.current_event_table(text),
    pgq.sqltriga(),
    pgq.logutriga()
  FROM pgq_reader, pgq_writer, pgq_admin, public CASCADE;
REVOKE ALL ON FUNCTION pgq.insert_event(text, text, text),
    pgq.insert_event(text, text, text, text, text, text, text),
    pgq.current_event_table(text),
    pgq.sqltriga(),
    pgq.logutriga()
  FROM public CASCADE;

-- 4.admin --
REVOKE ALL ON FUNCTION pgq.ticker(text, bigint, timestamptz, bigint),
    pgq.ticker(text),
    pgq.ticker(),
    pgq.maint_retry_events(),
    pgq.maint_rotate_tables_step1(text),
    pgq.maint_rotate_tables_step2(),
    pgq.maint_tables_to_vacuum(),
    pgq.maint_operations(),
    pgq.upgrade_schema(),
    pgq.grant_perms(text),
    pgq._grant_perms_from(text,text,text,text),
    pgq.tune_storage(text),
    pgq.seq_setval(text, int8),
    pgq.create_queue(text),
    pgq.drop_queue(text, bool),
    pgq.drop_queue(text),
    pgq.set_queue_config(text, text, text),
    pgq.insert_event_raw(text, bigint, timestamptz, integer, integer, text, text, text, text, text, text),
    pgq.event_retry_raw(text, text, timestamptz, bigint, timestamptz, integer, text, text, text, text, text, text)
  FROM pgq_reader, pgq_writer, pgq_admin, public CASCADE;
REVOKE ALL ON FUNCTION pgq.ticker(text, bigint, timestamptz, bigint),
    pgq.ticker(text),
    pgq.ticker(),
    pgq.maint_retry_events(),
    pgq.maint_rotate_tables_step1(text),
    pgq.maint_rotate_tables_step2(),
    pgq.maint_tables_to_vacuum(),
    pgq.maint_operations(),
    pgq.upgrade_schema(),
    pgq.grant_perms(text),
    pgq._grant_perms_from(text,text,text,text),
    pgq.tune_storage(text),
    pgq.seq_setval(text, int8),
    pgq.create_queue(text),
    pgq.drop_queue(text, bool),
    pgq.drop_queue(text),
    pgq.set_queue_config(text, text, text),
    pgq.insert_event_raw(text, bigint, timestamptz, integer, integer, text, text, text, text, text, text),
    pgq.event_retry_raw(text, text, timestamptz, bigint, timestamptz, integer, text, text, text, text, text, text)
  FROM public CASCADE;

-- 5.event.tables --
REVOKE ALL ON TABLE pgq.event_template
  FROM pgq_reader, pgq_writer, pgq_admin, public CASCADE;

-- 5.meta.tables --
REVOKE ALL ON TABLE pgq.consumer, pgq.queue, pgq.tick, pgq.subscription
  FROM pgq_reader, pgq_writer, pgq_admin, public CASCADE;

-- 6.retry.event --
REVOKE ALL ON TABLE pgq.retry_queue
  FROM pgq_reader, pgq_writer, pgq_admin, public CASCADE;

-- 1.public --
GRANT execute ON FUNCTION pgq.seq_getval(text),
    pgq.get_queue_info(),
    pgq.get_queue_info(text),
    pgq.get_consumer_info(),
    pgq.get_consumer_info(text),
    pgq.get_consumer_info(text, text),
    pgq.quote_fqname(text),
    pgq.version()
  TO public;

-- 2.consumer --
GRANT execute ON FUNCTION pgq.batch_event_sql(bigint),
    pgq.batch_event_tables(bigint),
    pgq.find_tick_helper(int4, int8, timestamptz, int8, int8, interval),
    pgq.register_consumer(text, text),
    pgq.register_consumer_at(text, text, bigint),
    pgq.unregister_consumer(text, text),
    pgq.next_batch_info(text, text),
    pgq.next_batch(text, text),
    pgq.next_batch_custom(text, text, interval, int4, interval),
    pgq.get_batch_events(bigint),
    pgq.get_batch_info(bigint),
    pgq.get_batch_cursor(bigint, text, int4, text),
    pgq.get_batch_cursor(bigint, text, int4),
    pgq.event_retry(bigint, bigint, timestamptz),
    pgq.event_retry(bigint, bigint, integer),
    pgq.batch_retry(bigint, integer),
    pgq.force_tick(text),
    pgq.finish_batch(bigint)
  TO pgq_reader;

-- 3.producer --
GRANT execute ON FUNCTION pgq.insert_event(text, text, text),
    pgq.insert_event(text, text, text, text, text, text, text),
    pgq.current_event_table(text),
    pgq.sqltriga(),
    pgq.logutriga()
  TO pgq_writer;

-- 4.admin --
GRANT execute ON FUNCTION pgq.ticker(text, bigint, timestamptz, bigint),
    pgq.ticker(text),
    pgq.ticker(),
    pgq.maint_retry_events(),
    pgq.maint_rotate_tables_step1(text),
    pgq.maint_rotate_tables_step2(),
    pgq.maint_tables_to_vacuum(),
    pgq.maint_operations(),
    pgq.upgrade_schema(),
    pgq.grant_perms(text),
    pgq._grant_perms_from(text,text,text,text),
    pgq.tune_storage(text),
    pgq.seq_setval(text, int8),
    pgq.create_queue(text),
    pgq.drop_queue(text, bool),
    pgq.drop_queue(text),
    pgq.set_queue_config(text, text, text),
    pgq.insert_event_raw(text, bigint, timestamptz, integer, integer, text, text, text, text, text, text),
    pgq.event_retry_raw(text, text, timestamptz, bigint, timestamptz, integer, text, text, text, text, text, text)
  TO pgq_admin;

-- 5.event.tables --
GRANT select ON TABLE pgq.event_template
  TO pgq_reader;
GRANT select, insert, truncate ON TABLE pgq.event_template
  TO pgq_admin;

-- 5.meta.tables --
GRANT select ON TABLE pgq.consumer, pgq.queue, pgq.tick, pgq.subscription
  TO pgq_reader;
GRANT select, insert, update, delete ON TABLE pgq.consumer, pgq.queue, pgq.tick, pgq.subscription
  TO pgq_admin;
GRANT select ON TABLE pgq.consumer, pgq.queue, pgq.tick, pgq.subscription
  TO public;

-- 6.retry.event --
GRANT select, insert, update, delete ON TABLE pgq.retry_queue
  TO pgq_admin;

commit;

