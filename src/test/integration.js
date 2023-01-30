const chai = require('chai');
const chaiHttp = require('chai-http');
chai.use(chaiHttp);
const should = chai.should();
const expect = chai.expect;

describe('GET /', () => {
    it('should return the index page of our application', function(done) {
        chai
        .request('http://localhost:8080') // We're testing that the container runs in docker-compose
        .get('/')
        .end(function(err, res) {
            res.should.have.status(200);
            done();
        })
    });
});
