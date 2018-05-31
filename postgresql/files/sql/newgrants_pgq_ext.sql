begin;


-- 1.public --
REVOKE ALL ON FUNCTION pgq_ext.version()
  FROM pgq_writer, public CASCADE;

-- 2.pgq_ext --
REVOKE ALL ON FUNCTION pgq_ext.upgrade_schema(),
    pgq_ext.is_batch_done(text, text, bigint),
    pgq_ext.is_batch_done(text, bigint),
    pgq_ext.set_batch_done(text, text, bigint),
    pgq_ext.set_batch_done(text, bigint),
    pgq_ext.is_event_done(text, text, bigint, bigint),
    pgq_ext.is_event_done(text, bigint, bigint),
    pgq_ext.set_event_done(text, text, bigint, bigint),
    pgq_ext.set_event_done(text, bigint, bigint),
    pgq_ext.get_last_tick(text, text),
    pgq_ext.get_last_tick(text),
    pgq_ext.set_last_tick(text, text, bigint),
    pgq_ext.set_last_tick(text, bigint)
  FROM pgq_writer, public CASCADE;
REVOKE ALL ON FUNCTION pgq_ext.upgrade_schema(),
    pgq_ext.is_batch_done(text, text, bigint),
    pgq_ext.is_batch_done(text, bigint),
    pgq_ext.set_batch_done(text, text, bigint),
    pgq_ext.set_batch_done(text, bigint),
    pgq_ext.is_event_done(text, text, bigint, bigint),
    pgq_ext.is_event_done(text, bigint, bigint),
    pgq_ext.set_event_done(text, text, bigint, bigint),
    pgq_ext.set_event_done(text, bigint, bigint),
    pgq_ext.get_last_tick(text, text),
    pgq_ext.get_last_tick(text),
    pgq_ext.set_last_tick(text, text, bigint),
    pgq_ext.set_last_tick(text, bigint)
  FROM public CASCADE;

-- 1.public --
GRANT execute ON FUNCTION pgq_ext.version()
  TO public;

-- 2.pgq_ext --
GRANT execute ON FUNCTION pgq_ext.upgrade_schema(),
    pgq_ext.is_batch_done(text, text, bigint),
    pgq_ext.is_batch_done(text, bigint),
    pgq_ext.set_batch_done(text, text, bigint),
    pgq_ext.set_batch_done(text, bigint),
    pgq_ext.is_event_done(text, text, bigint, bigint),
    pgq_ext.is_event_done(text, bigint, bigint),
    pgq_ext.set_event_done(text, text, bigint, bigint),
    pgq_ext.set_event_done(text, bigint, bigint),
    pgq_ext.get_last_tick(text, text),
    pgq_ext.get_last_tick(text),
    pgq_ext.set_last_tick(text, text, bigint),
    pgq_ext.set_last_tick(text, bigint)
  TO pgq_writer;

commit;

