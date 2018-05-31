begin;


-- 1.tables --
REVOKE ALL ON TABLE londiste.table_info, londiste.seq_info, londiste.pending_fkeys, londiste.applied_execute
  FROM londiste_writer, londiste_reader, public, pgq_admin CASCADE;

-- 2.public.fns --
REVOKE ALL ON FUNCTION londiste.find_column_types(text),
    londiste.find_table_fkeys(text),
    londiste.find_rel_oid(text, text),
    londiste.find_table_oid(text),
    londiste.find_seq_oid(text),
    londiste.is_replica_func(oid),
    londiste.quote_fqname(text),
    londiste.make_fqname(text),
    londiste.split_fqname(text),
    londiste.version()
  FROM londiste_writer, londiste_reader, public, pgq_admin CASCADE;

-- 3.remote.node --
REVOKE ALL ON FUNCTION londiste.get_seq_list(text),
    londiste.get_table_list(text),
    londiste._coordinate_copy(text, text)
  FROM londiste_writer, londiste_reader, public, pgq_admin CASCADE;
REVOKE ALL ON FUNCTION londiste.get_seq_list(text),
    londiste.get_table_list(text),
    londiste._coordinate_copy(text, text)
  FROM public CASCADE;

-- 4.local.node --
REVOKE ALL ON FUNCTION londiste.local_show_missing(text),
    londiste.local_add_seq(text, text),
    londiste.local_add_table(text, text, text[], text, text),
    londiste.local_add_table(text, text, text[], text),
    londiste.local_add_table(text, text, text[]),
    londiste.local_add_table(text, text),
    londiste.local_remove_seq(text, text),
    londiste.local_remove_table(text, text),
    londiste.global_add_table(text, text),
    londiste.global_remove_table(text, text),
    londiste.global_update_seq(text, text, int8),
    londiste.global_remove_seq(text, text),
    londiste.get_table_pending_fkeys(text),
    londiste.get_valid_pending_fkeys(text),
    londiste.drop_table_fkey(text, text),
    londiste.restore_table_fkey(text, text),
    londiste.execute_start(text, text, text, boolean),
    londiste.execute_finish(text, text),
    londiste.root_check_seqs(text, int8),
    londiste.root_check_seqs(text),
    londiste.root_notify_change(text, text, text),
    londiste.local_set_table_state(text, text, text, text),
    londiste.local_set_table_attrs(text, text, text),
    londiste.local_set_table_struct(text, text, text),
    londiste.drop_table_triggers(text, text),
    londiste.table_info_trigger(),
    londiste.create_partition(text, text, text, text, timestamptz, text),
    londiste.is_obsolete_partition (text, interval, text),
    londiste.list_obsolete_partitions (text, interval, text),
    londiste.drop_obsolete_partitions (text, interval, text),
    londiste.create_trigger(text,text,text[],text,text), 
    londiste.periodic_maintenance(),
    londiste.upgrade_schema()
  FROM londiste_writer, londiste_reader, public, pgq_admin CASCADE;
REVOKE ALL ON FUNCTION londiste.local_show_missing(text),
    londiste.local_add_seq(text, text),
    londiste.local_add_table(text, text, text[], text, text),
    londiste.local_add_table(text, text, text[], text),
    londiste.local_add_table(text, text, text[]),
    londiste.local_add_table(text, text),
    londiste.local_remove_seq(text, text),
    londiste.local_remove_table(text, text),
    londiste.global_add_table(text, text),
    londiste.global_remove_table(text, text),
    londiste.global_update_seq(text, text, int8),
    londiste.global_remove_seq(text, text),
    londiste.get_table_pending_fkeys(text),
    londiste.get_valid_pending_fkeys(text),
    londiste.drop_table_fkey(text, text),
    londiste.restore_table_fkey(text, text),
    londiste.execute_start(text, text, text, boolean),
    londiste.execute_finish(text, text),
    londiste.root_check_seqs(text, int8),
    londiste.root_check_seqs(text),
    londiste.root_notify_change(text, text, text),
    londiste.local_set_table_state(text, text, text, text),
    londiste.local_set_table_attrs(text, text, text),
    londiste.local_set_table_struct(text, text, text),
    londiste.drop_table_triggers(text, text),
    londiste.table_info_trigger(),
    londiste.create_partition(text, text, text, text, timestamptz, text),
    londiste.is_obsolete_partition (text, interval, text),
    londiste.list_obsolete_partitions (text, interval, text),
    londiste.drop_obsolete_partitions (text, interval, text),
    londiste.create_trigger(text,text,text[],text,text), 
    londiste.periodic_maintenance(),
    londiste.upgrade_schema()
  FROM public CASCADE;

-- 5.seqs --
REVOKE ALL ON SEQUENCE londiste.table_info_nr_seq,
    londiste.seq_info_nr_seq
  FROM londiste_writer, londiste_reader, public, pgq_admin CASCADE;

-- 6.maint --
REVOKE ALL ON FUNCTION londiste.periodic_maintenance()
  FROM londiste_writer, londiste_reader, public, pgq_admin CASCADE;
REVOKE ALL ON FUNCTION londiste.periodic_maintenance()
  FROM public CASCADE;

-- 1.tables --
GRANT select ON TABLE londiste.table_info, londiste.seq_info, londiste.pending_fkeys, londiste.applied_execute
  TO londiste_reader;
GRANT select ON TABLE londiste.table_info, londiste.seq_info, londiste.pending_fkeys, londiste.applied_execute
  TO public;
GRANT select, insert, update, delete ON TABLE londiste.table_info, londiste.seq_info, londiste.pending_fkeys, londiste.applied_execute
  TO pgq_admin;

-- 2.public.fns --
GRANT execute ON FUNCTION londiste.find_column_types(text),
    londiste.find_table_fkeys(text),
    londiste.find_rel_oid(text, text),
    londiste.find_table_oid(text),
    londiste.find_seq_oid(text),
    londiste.is_replica_func(oid),
    londiste.quote_fqname(text),
    londiste.make_fqname(text),
    londiste.split_fqname(text),
    londiste.version()
  TO public;

-- 3.remote.node --
GRANT execute ON FUNCTION londiste.get_seq_list(text),
    londiste.get_table_list(text),
    londiste._coordinate_copy(text, text)
  TO londiste_writer;
GRANT execute ON FUNCTION londiste.get_seq_list(text),
    londiste.get_table_list(text),
    londiste._coordinate_copy(text, text)
  TO londiste_reader;

-- 4.local.node --
GRANT execute ON FUNCTION londiste.local_show_missing(text),
    londiste.local_add_seq(text, text),
    londiste.local_add_table(text, text, text[], text, text),
    londiste.local_add_table(text, text, text[], text),
    londiste.local_add_table(text, text, text[]),
    londiste.local_add_table(text, text),
    londiste.local_remove_seq(text, text),
    londiste.local_remove_table(text, text),
    londiste.global_add_table(text, text),
    londiste.global_remove_table(text, text),
    londiste.global_update_seq(text, text, int8),
    londiste.global_remove_seq(text, text),
    londiste.get_table_pending_fkeys(text),
    londiste.get_valid_pending_fkeys(text),
    londiste.drop_table_fkey(text, text),
    londiste.restore_table_fkey(text, text),
    londiste.execute_start(text, text, text, boolean),
    londiste.execute_finish(text, text),
    londiste.root_check_seqs(text, int8),
    londiste.root_check_seqs(text),
    londiste.root_notify_change(text, text, text),
    londiste.local_set_table_state(text, text, text, text),
    londiste.local_set_table_attrs(text, text, text),
    londiste.local_set_table_struct(text, text, text),
    londiste.drop_table_triggers(text, text),
    londiste.table_info_trigger(),
    londiste.create_partition(text, text, text, text, timestamptz, text),
    londiste.is_obsolete_partition (text, interval, text),
    londiste.list_obsolete_partitions (text, interval, text),
    londiste.drop_obsolete_partitions (text, interval, text),
    londiste.create_trigger(text,text,text[],text,text), 
    londiste.periodic_maintenance(),
    londiste.upgrade_schema()
  TO londiste_writer;

-- 5.seqs --
GRANT usage ON SEQUENCE londiste.table_info_nr_seq,
    londiste.seq_info_nr_seq
  TO londiste_writer;

-- 6.maint --
GRANT execute ON FUNCTION londiste.periodic_maintenance()
  TO pgq_admin;

commit;

