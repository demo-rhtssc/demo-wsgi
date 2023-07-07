#!/usr/bin/python3
import os
from time import time
from flask import Flask
from flask_restx import Resource, Api, reqparse

application = Flask(__name__)
api = Api(application)


parser = reqparse.RequestParser()
parser.add_argument('morning', type=bool, help='Morning greeting')
parser.add_argument('afternoon', type=bool, help='Afternoon greeting')


@api.expect(parser)
@api.route('/hello/<string:name>')
class HelloWorld(Resource):
    def get(self, name):
        args = parser.parse_args(strict=True)
        if args['morning']:
            greeting = 'Good morning'
        elif args['afternoon']:
            greeting = 'Good afternoon'
        else:
            greeting = 'Hello'
        return {greeting: name}


@api.route('/date')
class Time(Resource):
    def get(self):
        return {'timestamp': time()}


if __name__ == '__main__':
    application.run(debug=True, host=os.environ.get('HOST', '127.0.0.1'), port=os.environ.get('FLASK_PORT', 5000))
