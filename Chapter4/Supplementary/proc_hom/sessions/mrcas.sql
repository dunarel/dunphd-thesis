select mr.id,
	  mr.ABREV,
	  mr.TIME_MIN,
	  mr.TIME_MAX,
	  mr.TIME_MED,
	  mr.STDEV,
	  mr.NAME
from mrcas mr
where mr.MRCA_CRITER_ID = 0