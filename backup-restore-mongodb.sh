docker exec mongo-docker sh -c 'mongodump -u root -p etc --archive --gzip' > ./mongo.db
docker exec -i mongo-docker-tests sh -c 'mongorestore -u root -p etc --gzip' < ./mongo.db