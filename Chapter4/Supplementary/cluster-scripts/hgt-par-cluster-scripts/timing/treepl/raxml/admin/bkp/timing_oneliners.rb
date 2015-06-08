#!/usr/bin/env ruby


#https://makandracards.com/makandra/15003-how-to-ruby-heredoc-without-interpolation
#http://stackoverflow.com/questions/8309234/use-ruby-one-liners-from-ruby-code
#http://benoithamelin.tumblr.com/ruby1line



#no string interpolation with single quoting separator
cmd = <<'DOC'
 cat ../subm/jpraxml-*.o* | ruby -ne '@fen_f=$1 if $_ =~ /jobs_f.*job-tasks-(.*)\.yaml/; puts"#{@fen_f} #{$1}" if $_ =~ /Resources.*(walltime.*)/'
DOC


system cmd;







