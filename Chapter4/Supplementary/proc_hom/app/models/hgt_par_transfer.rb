class HgtParTransfer < ActiveRecord::Base

  #belongs_to :ns_src, :class_name => "NcbiSeq", :foreign_key => "source_id" 
  #belongs_to :ns_dest, :class_name => "NcbiSeq", :foreign_key => "dest_id"
  #belongs_to :hcf, :class_name => "HgtComIntFragm", :foreign_key => "hgt_com_int_fragm_id"

 # scope :fragments, joins(:hgt_com_int_fragm)
  
  #scope :event_stream_for, lambda{ |user|
  #where("target_id in (SELECT DISTINCT id FROM events WHERE (host_id == ? OR invitee_id == ?) and target_type = ?", user.id, user.id, "Event")
 #}
  
end
