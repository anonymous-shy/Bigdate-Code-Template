### Create Table
**Create a Non-Partitioned Table**
```sparksql
-- create a cow table, with primaryKey 'uuid' and without preCombineField provided
create table hudi_cow_nonpcf_tbl (
  uuid int,
  name string,
  price double
) using hudi
tblproperties (
  primaryKey = 'uuid'
);


-- create a mor non-partitioned table with preCombineField provided
create table hudi_mor_tbl (
  id int,
  name string,
  price double,
  ts bigint
) using hudi
tblproperties (
  type = 'mor',
  primaryKey = 'id',
  preCombineField = 'ts'
);
```
**Create Partitioned Table**
```sparksql
-- create a partitioned, preCombineField-provided cow table
create table hudi_cow_pt_tbl (
  id bigint,
  name string,
  ts bigint,
  dt string,
  hh string
) using hudi
tblproperties (
  type = 'cow',
  primaryKey = 'id',
  preCombineField = 'ts'
 )
partitioned by (dt, hh)
location '/tmp/hudi/hudi_cow_pt_tbl';
```
**Create Table for an existing Hudi Table**
> We can create a table on an existing hudi table(created with spark-shell or deltastreamer).   
> This is useful to read/write to/from a pre-existing hudi table.
```sparksql
create table hudi_existing_tbl using hudi
location '/tmp/hudi/hudi_existing_table';
```
**CTAS**
> Hudi supports CTAS (Create Table As Select) on Spark SQL.  
> Note: For better performance to load data to hudi table, CTAS uses the bulk insert as the write operation.  

Example CTAS command to create a non-partitioned COW table without preCombineField.
```sparksql
-- CTAS: create a non-partitioned cow table without preCombineField
create table hudi_ctas_cow_nonpcf_tbl
using hudi
tblproperties (primaryKey = 'id')
as
select 1 as id, 'a1' as name, 10 as price;
```
Example CTAS command to create a partitioned, primary key COW table.
```sparksql
-- CTAS: create a partitioned, preCombineField-provided cow table
create table hudi_ctas_cow_pt_tbl
using hudi
tblproperties (type = 'cow', primaryKey = 'id', preCombineField = 'ts')
partitioned by (dt)
as
select 1 as id, 'a1' as name, 10 as price, 1000 as ts, '2021-12-01' as dt;
```
Example CTAS command to load data from another table.
```sparksql
-- create managed parquet table
create table parquet_mngd using parquet location 'file:///tmp/parquet_dataset/*.parquet';

-- CTAS by loading data into hudi table
create table hudi_ctas_cow_pt_tbl2 using hudi location 'file:/tmp/hudi/hudi_tbl/' 
options (
  type = 'cow',
  primaryKey = 'id',
  preCombineField = 'ts'
)
partitioned by (datestr) as select * from parquet_mngd;
```
### Insert data
```sparksql
-- insert into non-partitioned table
insert into hudi_cow_nonpcf_tbl select 1, 'a1', 20;
insert into hudi_mor_tbl select 1, 'a1', 20, 1000;

-- insert dynamic partition
insert into hudi_cow_pt_tbl partition (dt, hh)
select 1 as id, 'a1' as name, 1000 as ts, '2021-12-09' as dt, '10' as hh;

-- insert static partition
insert into hudi_cow_pt_tbl partition(dt = '2021-12-09', hh='11') select 2, 'a2', 1000;
```
**NOTICE**
- 默认情况下，如果提供preCombineKey，则insert into使用upsert作为写操作类型，否则使用insert。
- 我们支持使用bulk_insert作为写操作的类型，只需要设置两个配置:hoodie.sql.bulk.insert.enable和hoodie.sql.insert.mode。示例如下:
```sparksql
-- upsert mode for preCombineField-provided table
insert into hudi_mor_tbl select 1, 'a1_1', 20, 1001;
select id, name, price, ts from hudi_mor_tbl;
1   a1_1    20.0    1001

-- bulk_insert mode for preCombineField-provided table
set hoodie.sql.bulk.insert.enable=true;
set hoodie.sql.insert.mode=non-strict;

insert into hudi_mor_tbl select 1, 'a1_2', 20, 1002;
select id, name, price, ts from hudi_mor_tbl;
1   a1_1    20.0    1001
1   a1_2    20.0    1002
```
### Query data
eg:
```sparksql
 select fare, begin_lon, begin_lat, ts from  hudi_trips_snapshot where fare > 20.0
```
#### Time Travel Query
Hudi从0.9.0开始支持时间旅行查询。目前支持三种查询时间格式，如下所示:
> NOTE  
> Requires Spark 3.2+
```sparksql
create table hudi_cow_pt_tbl (
  id bigint,
  name string,
  ts bigint,
  dt string,
  hh string
) using hudi
tblproperties (
  type = 'cow',
  primaryKey = 'id',
  preCombineField = 'ts'
 )
partitioned by (dt, hh)
location '/tmp/hudi/hudi_cow_pt_tbl';

insert into hudi_cow_pt_tbl select 1, 'a0', 1000, '2021-12-09', '10';
select * from hudi_cow_pt_tbl;

-- record id=1 changes `name`
insert into hudi_cow_pt_tbl select 1, 'a1', 1001, '2021-12-09', '10';
select * from hudi_cow_pt_tbl;

-- time travel based on first commit time, assume `20220307091628793`
select * from hudi_cow_pt_tbl timestamp as of '20220307091628793' where id = 1;
-- time travel based on different timestamp formats
select * from hudi_cow_pt_tbl timestamp as of '2022-03-07 09:16:28.100' where id = 1;
select * from hudi_cow_pt_tbl timestamp as of '2022-03-08' where id = 1;
```
#### Update data  
Spark SQL支持两种DML来更新hudi表:Merge-Into和update。  
**Syntax**
```sparksql
UPDATE tableIdentifier SET column = EXPRESSION(,column = EXPRESSION) [ WHERE boolExpression]
```
**Case**
```sparksql
update hudi_mor_tbl set price = price * 2, ts = 1111 where id = 1;

update hudi_cow_pt_tbl set name = 'a1_1', ts = 1001 where id = 1;

-- update using non-PK field
update hudi_cow_pt_tbl set ts = 1001 where name = 'a1';
```
#### MergeInto
**TODO**
### Incremental query
Hudi还提供了获取自给定提交时间戳以来更改的记录流的功能。这可以通过使用Hudi的增量查询来实现，并提供需要流化更改的开始时间。如果我们希望在给定的提交之后进行所有更改(这是常见情况)，则不需要指定endTime。
```scala
// spark-shell
// reload data
spark.
  read.
  format("hudi").
  load(basePath).
  createOrReplaceTempView("hudi_trips_snapshot")

val commits = spark.sql("select distinct(_hoodie_commit_time) as commitTime from  hudi_trips_snapshot order by commitTime").map(k => k.getString(0)).take(50)
val beginTime = commits(commits.length - 2) // commit time we are interested in

// incrementally query data
val tripsIncrementalDF = spark.read.format("hudi").
  option(QUERY_TYPE_OPT_KEY, QUERY_TYPE_INCREMENTAL_OPT_VAL).
  option(BEGIN_INSTANTTIME_OPT_KEY, beginTime).
  load(basePath)
tripsIncrementalDF.createOrReplaceTempView("hudi_trips_incremental")

spark.sql("select `_hoodie_commit_time`, fare, begin_lon, begin_lat, ts from  hudi_trips_incremental where fare > 20.0").show()
```
> INFO
> 这将给出beginTime提交后发生的所有更改，过滤器为fare > 20.0。这个特性的独特之处在于它现在允许您在批处理数据上创建流管道。
### Point in time query
如何查询特定时间的数据。具体的时间可以通过将endTime指向特定的提交时间，将beginTime指向“000”(表示可能最早的提交时间)来表示。  
```scala
// spark-shell
val beginTime = "000" // Represents all commits > this time.
val endTime = commits(commits.length - 2) // commit time we are interested in

//incrementally query data
val tripsPointInTimeDF = spark.read.format("hudi").
  option(QUERY_TYPE_OPT_KEY, QUERY_TYPE_INCREMENTAL_OPT_VAL).
  option(BEGIN_INSTANTTIME_OPT_KEY, beginTime).
  option(END_INSTANTTIME_OPT_KEY, endTime).
  load(basePath)
tripsPointInTimeDF.createOrReplaceTempView("hudi_trips_point_in_time")
spark.sql("select `_hoodie_commit_time`, fare, begin_lon, begin_lat, ts from hudi_trips_point_in_time where fare > 20.0").show()
```
### Insert Overwrite
对于批处理ETL作业，此操作比upsert更快，因为批量ETL作业一次重新计算整个目标分区(而不是增量地更新目标表)。这是因为，我们能够完全绕过upsert写路径中的索引、预组合和其他重分区步骤。  
```sparksql
-- insert overwrite non-partitioned table
insert overwrite hudi_mor_tbl select 99, 'a99', 20.0, 900;
insert overwrite hudi_cow_nonpcf_tbl select 99, 'a99', 20.0;

-- insert overwrite partitioned table with dynamic partition
insert overwrite table hudi_cow_pt_tbl select 10, 'a10', 1100, '2021-12-09', '10';

-- insert overwrite partitioned table with static partition
insert overwrite hudi_cow_pt_tbl partition(dt = '2021-12-09', hh='12') select 13, 'a13', 1100;
```
### More Spark SQL Commands
#### Alter Table
Schema evolution可以通过ALTER TABLE命令实现。
**Syntax**
```sparksql
-- Alter table name
ALTER TABLE oldTableName RENAME TO newTableName

-- Alter table add columns
ALTER TABLE tableIdentifier ADD COLUMNS(colAndType (,colAndType)*)

-- Alter table column type
ALTER TABLE tableIdentifier CHANGE COLUMN colName colName colType

-- Alter table properties
ALTER TABLE tableIdentifier SET TBLPROPERTIES (key = 'value')
```
**Examples**
```sparksql
--rename to:
ALTER TABLE hudi_cow_nonpcf_tbl RENAME TO hudi_cow_nonpcf_tbl2;

--add column:
ALTER TABLE hudi_cow_nonpcf_tbl2 add columns(remark string);

--change column:
ALTER TABLE hudi_cow_nonpcf_tbl2 change column uuid uuid bigint;

--set properties;
alter table hudi_cow_nonpcf_tbl2 set tblproperties (hoodie.keep.max.commits = '10');
```
#### Partition SQL Command
**Syntax**
```sparksql
-- Drop Partition
ALTER TABLE tableIdentifier DROP PARTITION ( partition_col_name = partition_col_val [ , ... ] )

-- Show Partitions
SHOW PARTITIONS tableIdentifier
```
**Examples**
```sparksql
--show partition:
show partitions hudi_cow_pt_tbl;

--drop partition：
alter table hudi_cow_pt_tbl drop partition (dt='2021-12-09', hh='10');
```





