#!/bin/bash

IMAGE="master"
HADOOP_EXEC="/usr/local/hadoop/bin/hadoop"

cp_to_local(){
	if [ $# -ne 2 ]; 
	then
		echo "Invalid args. Must be of form: hdfs-tool.sh copyToLocal <src_file> <dst_dir>"
		exit 1
	fi
	
	docker exec $IMAGE mkdir -p /tmp$1
	docker exec $IMAGE rm -r /tmp$1

	docker exec $IMAGE $HADOOP_EXEC fs -copyToLocal $1 /tmp$1
	docker cp $IMAGE:/tmp$1 $2

	docker exec $IMAGE rm -r /tmp$1
}

cp_from_local(){
	if [ $# -ne 2 ]; 
	then
		echo "Invalid args. Must be of form: hdfs-tool.sh copyFromLocal <src_file> <dst_dir>"
		exit 1
	fi
	
	docker cp $1 $IMAGE:/tmp
	docker exec $IMAGE $HADOOP_EXEC fs -copyFromLocal /tmp/$1 $2
}

mkdir(){
	if [ $# -ne 1 ]; 
	then
		echo "Invalid args. Must be of form: hdfs-tool.sh mkdir <hdfs_dir>"
		exit 1
	fi

	docker exec $IMAGE $HADOOP_EXEC fs -mkdir $1
	docker exec $IMAGE $HADOOP_EXEC fs -chmod -R a+rw $1
}

ls(){
	if [ $# -ne 1 ]; 
	then
		echo "Invalid args. Must be of form: hdfs-tool.sh ls <hdfs_dir>"
		exit 1
	fi

	docker exec $IMAGE $HADOOP_EXEC fs -ls $1
}

rm(){
	if [ $# -ne 1 ]; 
	then
		echo "Invalid args. Must be of form: hdfs-tool.sh rm <hdfs_dir>"
		exit 1
	fi

	docker exec $IMAGE $HADOOP_EXEC fs -rm -r $1
}

rmdir(){
	if [ $# -ne 1 ]; 
	then
		echo "Invalid args. Must be of form: hdfs-tool.sh rmdir <hdfs_dir>"
		exit 1
	fi

	docker exec $IMAGE $HADOOP_EXEC fs -rmdir $1
}

mv(){
	if [ $# -ne 2 ]; 
	then
		echo "Invalid args. Must be of form: hdfs-tool.sh ls <hdfs_dir>"
		exit 1
	fi

	docker exec $IMAGE mkdir -p /tmp$2
	docker cp $1 $IMAGE:/tmp$2 

	docker exec $IMAGE $HADOOP_EXEC fs -copyFromLocal /tmp$2/$1 $2 
}

if [ $# -eq 0 ]; then
	echo "Missing args."
fi

case $1 in
	copyToLocal) cp_to_local $2 $3
	;;
	copyFromLocal) cp_from_local $2 $3
	;;
	mkdir) mkdir $2 
	;;
	ls) ls $2 
	;;
	rm) rm $2 
	;;
	rmdir) rmdir $2 
	;;
	*) echo "Invalid hdfs command: $1"
esac

exit 0
