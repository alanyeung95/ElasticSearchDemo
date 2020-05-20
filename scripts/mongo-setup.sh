#!/bin/sh
INIT_MARK_FILE=/data/db/inited
if [ ! -f "$INIT_MARK_FILE" ] ; then
	echo "Setup replica set and authentication"

	mongod --replSet $MONGODB_REPLICATE_SET &
	sleep 5

	mongo <<-EOJS
		rs.initiate(
			{
				_id: '$MONGODB_REPLICATE_SET',
				members: [
					{ _id: 0, host: "$MONGODB_ADDRESSES" }
				]
			}
		)
	EOJS
	sleep 5
	mongo <<-EOJS
		use admin
		db.createUser({
			user: 'root',
			pwd: 'root',
			roles: [ { role: 'root', db: 'admin' } ]
		})

		use $MONGODB_DATABASE
		db.createUser({
			user: '$MONGODB_USERNAME',
			pwd: '$MONGODB_PASSWORD',
			roles: [ { role: 'readWrite', db: '$MONGODB_DATABASE' } ]
		})
	EOJS

	touch $INIT_MARK_FILE
	mongod --shutdown
fi

mongod --bind_ip_all --auth --replSet $MONGODB_REPLICATE_SET

