# -*- coding: utf-8 -*-
"""
用于提供json格式的api请求的辅助方法的模块。
"""

from __future__ import unicode_literals

import json
import datetime
import thriftpy

from functools import wraps
from django.http import HttpResponse
from django.core.serializers.json import DjangoJSONEncoder
from django.forms.models import model_to_dict
from django.db.models import Model


class StatusCode(object):
    OK = 200
    UNAUTHORIZED = 401
    FORBIDDEN = 403
    NOT_FOUND = 404
    INPUT_NOT_VALID = 412
    FAILED = 420
    SERVICE_UNAVAILABLE = 503


def _result(data, status_code):
    if isinstance(data, Model):
        data = model_to_dict(data)
    content = json.dumps(data, cls=DjangoJSONEncoder, ensure_ascii=False)
    return HttpResponse(content,
                        content_type='application/json',
                        status=status_code)


def success(data=True):
    return _result(data, StatusCode.OK)


def fail(data=None, status_code=StatusCode.FAILED):
    return _result(data, status_code)


def need_logon(func):
    @wraps(func)
    def _fn(request, *args, **kwargs):
        if not request.user.is_authenticated():
            return fail('您还没有登录，请您登录后重试', StatusCode.UNAUTHORIZED)
        if not request.user.is_active:
            return fail('您还没有激活，请您联系管理员', StatusCode.UNAUTHORIZED)
        return func(request, *args, **kwargs)
    return _fn


def check_input(form_cls, as_text=False):
    def decorator(func):
        @wraps(func)
        def _fn(request, *args, **kwargs):
            form = form_cls(request.POST)
            if not form.is_valid():
                fail_message = form.errors.as_text() if as_text \
                    else form.errors.as_data()
                return fail(fail_message, StatusCode.INPUT_NOT_VALID)
            return func(request, form, *args, **kwargs)
        return _fn
    return decorator


def objects_to_array(objects):
    array0 = []
    if isinstance(objects, list):
        array0 = objects
    elif isinstance(objects, Model):
        array0.append(objects)
        json_str = objects.to_json()
        array0 = json.loads(json_str)
    else:
        json_str = objects.to_json()
        array0 = json.loads(json_str)
    # 1404144000000
    # 1317094800.0
    array = []
    for obj in array0:
        array_object = {}
        for j, value in obj.iteritems():
            if isinstance(value, dict):
                if value.keys()[0] == '$date':
                    # 将时间戳转化为localtime
                    timestamp = value["$date"]
                    if timestamp > 1000000000000:
                        timestamp *= 0.001
                    dt = datetime.datetime.utcfromtimestamp(timestamp)
                    localtime = dt + datetime.timedelta(hours=8)
                    # localtime = time.localtime(timestamp)
                    # array_object[j] = time.strftime('%Y-%m-%d %H:%M:%S', localtime)
                    array_object[j] = localtime.strftime('%Y-%m-%d %H:%M:%S')
                else:
                    array_object[j] = value.values()[0]
            else:
                array_object[j] = value
        array.append(array_object)

    return array


def objects_to_str(objects):
    data = objects_to_array(objects)
    content = json.dumps(data, cls=DjangoJSONEncoder, ensure_ascii=False)
    return content


# 变量转化为json串
def data_to_json(data):
    json_str = json.dumps(data, cls=DjangoJSONEncoder, ensure_ascii=False)
    return json_str


# str转化为python变量
def str_to_data(json_str):
    array = json.loads(json_str)
    return array


class ResultBuilder(object):
    @classmethod
    def result(cls, success, data=None, message=None):
        if not success and message is None:
            message = '操作失败'  # default error message
        return {'success': success, 'data': data, 'message': message}

    @classmethod
    def fail(cls, message=None):
        return cls.result(False, message=message)

    @classmethod
    def success(cls, data=None):
        return cls.result(True, data=data)

ext_fail = ResultBuilder.fail
ext_success = ResultBuilder.success


class ThriftStructJsonEncoder(DjangoJSONEncoder):
    def default(self, o):
        if isinstance(o, thriftpy.thrift.TPayload):
            return o.__dict__
        else:
            return super(ThriftStructJsonEncoder, self).default(o)


def _json_service_decorator(must_logon):
    def decorator(func):
        @wraps(func)
        def _fn(request, *args, **kwargs):
            if must_logon:
                if not request.user.is_authenticated():
                    result = fail('您还没有登录，请您登录后重试')
                elif not request.user.is_active:
                    result = fail('您还没有激活，请您联系管理员')
                else:
                    result = func(request, *args, **kwargs)
            else:
                result = func(request, *args, **kwargs)
            content = json.dumps(result, cls=ThriftStructJsonEncoder,
                                 ensure_ascii=False)
            return HttpResponse(content, content_type='application/json')
        return _fn
    return decorator


def json_service(function=None, must_logon=True):
    decorator = _json_service_decorator(must_logon)
    if function:
        return decorator(function)
    return decorator
