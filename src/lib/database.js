'use strict';

var MongoClient = require('mongodb').MongoClient;
var config = require('./config');
var _db;

function Database() {
    this.connect = function(app, callback) {
            // This no longer returns a db, instead it returns a client,
            // against which there is a function called db() that returns
            // db instance we are looking for. 
            MongoClient.connect(config.database.url,
                                config.database.options,
                                function (err, client) {
                                    if (err) {
                                        console.log(err);
                                        console.log(config.database.url);
                                        console.log(config.database.options);
                                    } else {
                                        _db = client.db(config.database.name);
                                        app.locals.db = client.db(config.database.name);
                                    }
                                    callback(err);
                                });
    }

    this.getDb = function(app, callback) {
        if (!_db) {
            this.connect(app, function(err) {
                if (err) {
                    console.log('Failed to connect to database server');
                } else {
                    console.log('Connected to database server successfully');
                }

                callback(err, _db);
            });
        } else {
            callback(null, _db);
        }

    }
}

module.exports = exports = new Database(); // Singleton
