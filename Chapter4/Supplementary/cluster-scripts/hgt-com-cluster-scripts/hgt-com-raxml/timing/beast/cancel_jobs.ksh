qstat -u badescud | egrep "\sR\s" | awk '{print $1}' | xargs -i -t qdel {}

