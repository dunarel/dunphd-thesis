
#shutdown all local databases
java -jar lib/sqltool.jar --sql="shutdown;" --rcFile=./sqltool.rc proc_hom_local
java -jar lib/sqltool.jar --sql="shutdown;" --rcFile=./sqltool.rc cl_ms_local

rm -fr server.pid
rm -fr log/server.log.*



