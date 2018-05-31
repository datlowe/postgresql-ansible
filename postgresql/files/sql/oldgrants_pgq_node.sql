begin;

-- 1.public.fns --
REVOKE ALL ON FUNCTION pgq_node.is_root_node(text),
    pgq_node.is_leaf_node(text),
    pgq_node.version()
  FROM pgq_writer, pgq_admin, pgq_reader, public CASCADE;
GRANT execute ON FUNCTION pgq_node.is_root_node(text),
    pgq_node.is_leaf_node(text),
    pgq_node.version()
  TO public;

-- 2.consumer.fns --
REVOKE ALL ON FUNCTION pgq_node.register_consumer(text, text, text, int8),
    pgq_node.unregister_consumer(text, text),
    pgq_node.change_consumer_provider(text, text, text),
    pgq_node.set_consumer_uptodate(text, text, boolean),
    pgq_node.set_consumer_paused(text, text, boolean),
    pgq_node.set_consumer_completed(text, text, int8),
    pgq_node.set_consumer_error(text, text, text)
  FROM pgq_writer, pgq_admin, pgq_reader, public CASCADE;
GRANT execute ON FUNCTION pgq_node.register_consumer(text, text, text, int8),
    pgq_node.unregister_consumer(text, text),
    pgq_node.change_consumer_provider(text, text, text),
    pgq_node.set_consumer_uptodate(text, text, boolean),
    pgq_node.set_consumer_paused(text, text, boolean),
    pgq_node.set_consumer_completed(text, text, int8),
    pgq_node.set_consumer_error(text, text, text)
  TO public;

-- 3.worker.fns --
REVOKE ALL ON FUNCTION pgq_node.create_node(text, text, text, text, text, bigint, text),
    pgq_node.drop_node(text, text),
    pgq_node.demote_root(text, int4, text),
    pgq_node.promote_branch(text),
    pgq_node.set_node_attrs(text, text),
    pgq_node.get_worker_state(text),
    pgq_node.set_global_watermark(text, bigint),
    pgq_node.set_partition_watermark(text, text, bigint)
  FROM pgq_writer, pgq_admin, pgq_reader, public CASCADE;
GRANT execute ON FUNCTION pgq_node.create_node(text, text, text, text, text, bigint, text),
    pgq_node.drop_node(text, text),
    pgq_node.demote_root(text, int4, text),
    pgq_node.promote_branch(text),
    pgq_node.set_node_attrs(text, text),
    pgq_node.get_worker_state(text),
    pgq_node.set_global_watermark(text, bigint),
    pgq_node.set_partition_watermark(text, text, bigint)
  TO public;

-- 4.admin.fns --
REVOKE ALL ON FUNCTION pgq_node.register_location(text, text, text, boolean),
    pgq_node.unregister_location(text, text),
    pgq_node.upgrade_schema(),
    pgq_node.maint_watermark(text)
  FROM pgq_writer, pgq_admin, pgq_reader, public CASCADE;
GRANT execute ON FUNCTION pgq_node.register_location(text, text, text, boolean),
    pgq_node.unregister_location(text, text),
    pgq_node.upgrade_schema(),
    pgq_node.maint_watermark(text)
  TO public;

-- 4.remote.fns --
REVOKE ALL ON FUNCTION pgq_node.get_consumer_info(text),
    pgq_node.get_consumer_state(text, text),
    pgq_node.get_queue_locations(text),
    pgq_node.get_node_info(text),
    pgq_node.get_subscriber_info(text),
    pgq_node.register_subscriber(text, text, text, int8),
    pgq_node.unregister_subscriber(text, text),
    pgq_node.set_subscriber_watermark(text, text, bigint)
  FROM pgq_writer, pgq_admin, pgq_reader, public CASCADE;
GRANT execute ON FUNCTION pgq_node.get_consumer_info(text),
    pgq_node.get_consumer_state(text, text),
    pgq_node.get_queue_locations(text),
    pgq_node.get_node_info(text),
    pgq_node.get_subscriber_info(text),
    pgq_node.register_subscriber(text, text, text, int8),
    pgq_node.unregister_subscriber(text, text),
    pgq_node.set_subscriber_watermark(text, text, bigint)
  TO public;

-- 5.tables --
REVOKE ALL ON TABLE pgq_node.node_location, pgq_node.node_info, pgq_node.local_state, pgq_node.subscriber_info
  FROM pgq_writer, pgq_admin, pgq_reader, public CASCADE;

grant usage on schema pgq_node to public;

commit;
