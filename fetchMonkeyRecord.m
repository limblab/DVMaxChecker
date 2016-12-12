function data=fetchMonkeyRecord(conn,cagecardID)
    %helper function to pull records for a single monkey from DVMax
    exestring= ['select distinct cage_card_id, datetime_performed_cst, med_rec_code, med_description, comments'...
       ' from granite_reports.dvmax_med_rec_entries_vw where cage_card_id=' cagecardID 'order by datetime_performed_cst asc'];
    data = fetch(conn,exestring);
    data = data(end:-1:1,:);
end