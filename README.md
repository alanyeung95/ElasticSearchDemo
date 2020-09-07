# ElasticSearch & Monstache Demo

A project to demo elasticsearch, kibana and monstache architecture and function

This repo is one of the microservices. Other related repo is <b>GoProjectDemo</b> and <b>vue-project-demo</b>

Please setup the project under this order:

1. GoProjectDemo
2. ElasticSearchDemo
3. vue-project-demo

# Purpose

In real industry we are not just using mongo, but also elastic search to fetch data and bring better user experience. However, inserting data in mongo won't update elastic search in default. Monstache is a useful syncing service to keep the ES update and make the inserted data available for searching from ES.

# Start

just run `docker-compose up` to run the project

## Mongo setup

The docker will run the `mongo-setup.sh` to create DB and users

```
mongo_1          | Successfully added user: {
mongo_1          | 	"user" : "root",
mongo_1          | 	"roles" : [
mongo_1          | 		{
mongo_1          | 			"role" : "root",
mongo_1          | 			"db" : "admin"
mongo_1          | 		}
mongo_1          | 	]
mongo_1          | }
mongo_1          | switched to db domain
mongo_1          | Successfully added user: {
mongo_1          | 	"user" : "user",
mongo_1          | 	"roles" : [
mongo_1          | 		{
mongo_1          | 			"role" : "readWrite",
mongo_1          | 			"db" : "domain"
mongo_1          | 		}
mongo_1          | 	]
mongo_1          | }
mongo_1          | bye
```

Assume all the mongo, elasticsearch, kibana and monstache are all up, we can insert our own data

## Create sample data (user) in mongo

```
{"_id":{"$oid":"5ec549a46640bb70315c2c7e"},"name":"Alan"}
```

## Monstache

Monstache is syncing data to elastic search real time

```
monstache_1      | TRACE 2020/05/20 15:16:08 POST /_bulk HTTP/1.1
monstache_1      | Host: elasticsearch:9200
monstache_1      | User-Agent: elastic/6.2.26 (linux-amd64)
monstache_1      | Content-Length: 156
monstache_1      | Accept: application/json
monstache_1      | Content-Type: application/x-ndjson
monstache_1      | Accept-Encoding: gzip
monstache_1      |
monstache_1      | {"index":{"_index":"domain_users","_id":"5ec549a46640bb70315c2c7e","_type":"_doc","version":6828945447420166145,"version_type":"external"}}
monstache_1      | {"name":"Alan"}
monstache_1      |
elasticsearch_1  | [2020-05-20T15:16:08,821][WARN ][o.e.d.c.m.MetaDataCreateIndexService] [z3Tgi37] the default number of shards will change from [5] to [1] in 7.0.0; if you wish to continue using the default of [5] shards, you must manage this on the create index request or with an index template
elasticsearch_1  | [2020-05-20T15:16:08,853][INFO ][o.e.c.m.MetaDataCreateIndexService] [z3Tgi37] [domain_users] creating index, cause [auto(bulk api)], templates [], shards [5]/[1], mappings []
elasticsearch_1  | [2020-05-20T15:16:10,740][INFO ][o.e.c.m.MetaDataMappingService] [z3Tgi37] [domain_users/NWKOHn8HQTOnQQvzr_-AKw] create_mapping [_doc]
monstache_1      | TRACE 2020/05/20 15:16:10 HTTP/1.1 200 OK
monstache_1      | Content-Length: 263
monstache_1      | Content-Type: application/json; charset=UTF-8
monstache_1      | Warning: 299 Elasticsearch-6.8.5-78990e9 "the default number of shards will change from [5] to [1] in 7.0.0; if you wish to continue using the default of [5] shards, you must manage this on the create index request or with an index template"
monstache_1      |
monstache_1      | {"took":2065,"errors":false,"items":[{"index":{"_index":"domain_users","_type":"_doc","_id":"5ec549a46640bb70315c2c7e","_version":6828945447420166145,"result":"created","_shards":{"total":2,"successful":1,"failed":0},"_seq_no":0,"_primary_term":1,"status":201}}]}

```

## Kibana

Go to kibana `http://localhost:5601` to check the index

```
GET /_cat/indices
```

will result

```
yellow open domain_users         NWKOHn8HQTOnQQvzr_-AKw 5 1 1 0  4.2kb  4.2kb
green  open .kibana_task_manager 0pAdXAZ7R9SEBsELOF5fiA 1 0 2 0 12.3kb 12.3kb
green  open .kibana_1            dZkqkKt9QBmImTFZF8Q8VA 1 0 2 0 10.2kb 10.2kb
```

query the user we just created in MongoDB

```
GET domain_users/_search
{
  "query": {
    "terms": {
      "_id": [ "5ec549a46640bb70315c2c7e" ]
    }
  }
}
```

here we go

```
{
  "took" : 12,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "domain_users",
        "_type" : "_doc",
        "_id" : "5ec549a46640bb70315c2c7e",
        "_score" : 1.0,
        "_source" : {
          "name" : "Alan"
        }
      }
    ]
  }
}

```

# Extra usage

Use query string if you want to query a field that contains a target string, if not field is provide it will search all possible field in the documents

```
GET domain_items/_search
{
    "query": {
        "query_string" : {
            "fields" : ["description"],
            "query" : "hello world"
        }
    }
}
```

ES also support operatior

```
GET domain_items/_search
{
    "query": {
        "query_string" : {
            "query" : "earth OR sun"
        }
    }
}
```

# Development Notes

## Debug your index mapping and setting

Create index first
```
PUT /testing_index_updated
```

Disable index for usage before updating its setting and mapping
```
POST /testing_index_updated/_close
```

Update setting
```
PUT /testing_index_updated/_settings
```

Update mapping
```
PUT /testing_index_update/_mapping/_doc
```

reactivate the index, otherwise we will get `index_closed_exception`
```
POST /testing_index_updated/_open 
```

# Todo list:

- [ ] Add querying nested object example
- [ ] Wrap elasticsearch with API server
