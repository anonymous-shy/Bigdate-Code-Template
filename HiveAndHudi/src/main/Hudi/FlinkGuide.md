- **Quick Start** : Read Quick Start to get started quickly Flink sql client to write to(read from) Hudi.  
- **Configuration** : 对于全局配置，通过$FLINK_HOME/conf/flink-conf.yaml进行设置。对于每个作业配置，通过表选项进行设置。
- **Writing Data** : Flink支持不同的写入模式， such as CDC Ingestion, Bulk Insert, Index Bootstrap, Changelog Mode and Append Mode.
- **Querying Data** : Flink支持不同的读取模式，such as Streaming Query and Incremental Query.
- **Tuning** : 对于写/读任务，本指南给出了一些调优建议，such as Memory Optimization and Write Rate Limit.
- **Optimization**: 支持离线压缩Offline Compaction.
- **Query Engines**: 除了Flink，还集成了许多其他引擎: Hive Query, Presto Query.
### Setup
**Step.1 download Flink jar**  
**Step.2 start Flink cluster**  
在hadoop环境中启动一个独立的Flink集群。在启动集群之前，我们建议对集群进行如下配置:  
- in $FLINK_HOME/conf/flink-conf.yaml, add config option taskmanager.numberOfTaskSlots: 4
- in $FLINK_HOME/conf/flink-conf.yaml, add other global configurations according to the characteristics of your task
- in $FLINK_HOME/conf/workers, add item localhost as 4 lines so that there are 4 workers on the local cluster  
### Insert Data
```sparksql
-- sets up the result mode to tableau to show the results directly in the CLI
set sql-client.execution.result-mode = tableau;

CREATE TABLE t1(
  uuid VARCHAR(20) PRIMARY KEY NOT ENFORCED,
  name VARCHAR(10),
  age INT,
  ts TIMESTAMP(3),
  `partition` VARCHAR(20)
)
PARTITIONED BY (`partition`)
WITH (
  'connector' = 'hudi',
  'path' = '${path}',
  'table.type' = 'MERGE_ON_READ' -- this creates a MERGE_ON_READ table, by default is COPY_ON_WRITE
);

-- insert data using values
INSERT INTO t1 VALUES
  ('id1','Danny',23,TIMESTAMP '1970-01-01 00:00:01','par1'),
  ('id2','Stephen',33,TIMESTAMP '1970-01-01 00:00:02','par1'),
  ('id3','Julian',53,TIMESTAMP '1970-01-01 00:00:03','par2'),
  ('id4','Fabian',31,TIMESTAMP '1970-01-01 00:00:04','par2'),
  ('id5','Sophia',18,TIMESTAMP '1970-01-01 00:00:05','par3'),
  ('id6','Emma',20,TIMESTAMP '1970-01-01 00:00:06','par3'),
  ('id7','Bob',44,TIMESTAMP '1970-01-01 00:00:07','par4'),
  ('id8','Han',56,TIMESTAMP '1970-01-01 00:00:08','par4');
```
### Query Data
```sparksql
-- query from the Hudi table
select * from t1;
-- 此语句查询数据集的快照视图(snapshot view)。
-- 有关支持的所有表类型和查询类型的更多信息，请参阅 Table types and queries 。
```
### Update Data
```sparksql
-- this would update the record with key 'id1'
insert into t1 values
  ('id1','Danny',27,TIMESTAMP '1970-01-01 00:00:01','par1');
```
注意，保存模式现在是Append。通常，总是使用追加模式，除非您是第一次尝试创建表。再次查询数据将显示更新的记录。每个写操作生成一个由时间戳表示的新提交。在_hoodie_commit_time, age字段中寻找之前提交中相同的_hoodie_record_keys的变化。
### Streaming Query
Hudi Flink还提供了获得自给定提交时间戳以来更改的记录流的功能。这可以通过使用Hudi的流查询来实现，并提供需要流化更改的开始时间。如果我们希望在给定的提交之后进行所有更改(这是常见情况)，则不需要指定endTime。
```sparksql
CREATE TABLE t1(
  uuid VARCHAR(20) PRIMARY KEY NOT ENFORCED,
  name VARCHAR(10),
  age INT,
  ts TIMESTAMP(3),
  `partition` VARCHAR(20)
)
PARTITIONED BY (`partition`)
WITH (
  'connector' = 'hudi',
  'path' = '${path}',
  'table.type' = 'MERGE_ON_READ',
  'read.streaming.enabled' = 'true',  -- this option enable the streaming read
  'read.start-commit' = '20210316134557', -- specifies the start commit instant time
  'read.streaming.check-interval' = '4' -- specifies the check interval for finding new source commits, default 60s.
);

-- Then query the table in stream mode
select * from t1;
```













