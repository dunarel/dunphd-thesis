nohup java -XX:+UseConcMarkSweepGC -Xms512m -Xmx4196m -cp lib/hsqldb.jar:sp_projects/proc-hom-sp/dist/proc-hom-sp.jar org.hsqldb.server.Server 2>&1 | rotatelogs log/server.log 5m &
#nohup java -Xmx512m org.hsqldb.server.Server 2>&1 | rotatelogs log/server.log 5m &


let spid=$!-1 

echo $spid > server.pid
echo "kill -9 "$spid > server-killer.sh
echo "rm server.pid" >> server-killer.sh
echo "rm log/server.log*" >> server-killer.sh
chmod 777 server-killer.sh

