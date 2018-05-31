begin;


-- 1.consumer --
REVOKE ALL ON FUNCTION pgq_coop.register_subconsumer(text, text, text),
    pgq_coop.unregister_subconsumer(text, text, text, integer),
    pgq_coop.next_batch(text, text, text),
    pgq_coop.next_batch(text, text, text, interval),
    pgq_coop.next_batch_custom(text, text, text, interval, int4, interval),
    pgq_coop.next_batch_custom(text, text, text, interval, int4, interval, interval),
    pgq_coop.finish_batch(bigint)
  FROM pgq_reader, pgq_writer, pgq_admin, public CASCADE;
REVOKE ALL ON FUNCTION pgq_coop.register_subconsumer(text, text, text),
    pgq_coop.unregister_subconsumer(text, text, text, integer),
    pgq_coop.next_batch(text, text, text),
    pgq_coop.next_batch(text, text, text, interval),
    pgq_coop.next_batch_custom(text, text, text, interval, int4, interval),
    pgq_coop.next_batch_custom(text, text, text, interval, int4, interval, interval),
    pgq_coop.finish_batch(bigint)
  FROM public CASCADE;

-- 2.public --
REVOKE ALL ON FUNCTION pgq_coop.version()
  FROM pgq_reader, pgq_writer, pgq_admin, public CASCADE;

-- 1.consumer --
GRANT execute ON FUNCTION pgq_coop.register_subconsumer(text, text, text),
    pgq_coop.unregister_subconsumer(text, text, text, integer),
    pgq_coop.next_batch(text, text, text),
    pgq_coop.next_batch(text, text, text, interval),
    pgq_coop.next_batch_custom(text, text, text, interval, int4, interval),
    pgq_coop.next_batch_custom(text, text, text, interval, int4, interval, interval),
    pgq_coop.finish_batch(bigint)
  TO pgq_reader;

-- 2.public --
GRANT execute ON FUNCTION pgq_coop.version()
  TO public;

commit;

