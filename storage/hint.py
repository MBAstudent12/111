#!/usr/bin/python3

from urllib.parse import unquote
from tornado import web,gen
from tornado.concurrent import run_on_executor
from concurrent.futures import ThreadPoolExecutor
from db_query import DBQuery
from language import text, encode
from configuration import env
import json

dbhost=env["DBHOST"]
office=list(map(float, env["OFFICE"].split(','))) if "OFFICE" in env else ""

class HintHandler(web.RequestHandler):
    def __init__(self, app, request, **kwargs):
        super(HintHandler, self).__init__(app, request, **kwargs)
        self.executor= ThreadPoolExecutor(2)

    def check_origin(self, origin):
        return True

    @run_on_executor
    def _hint(self, indexes):
        try:
            hints={}
            for index in indexes:
                dbq=DBQuery(index=index,office=office,host=dbhost)
                hints[index]=dbq.hints(size=100)
            return hints
        except Exception as e:
            return str(e)

    @gen.coroutine
    def get(self):
        indexes=unquote(str(self.get_argument("index"))).split(",")

        r=yield self._hint(indexes)
        if isinstance(r,str):
            self.set_status(400, encode(r))
            return

        self.write(r)
        self.set_status(200,'OK')
        self.finish()
