# -*- coding: utf-8 -*-

import datetime
import urllib
import warnings

from functools import wraps
from django.http import HttpResponse
from django.shortcuts import render


# 验证登录
def require_login(skip_type='', url_hash=''):
    def handle_func(func):
        @wraps(func)
        def _fn(request, *args, **kwargs):
            if not request.user.is_authenticated():
                if skip_type == 'self':
                    return render(request, 'common/login.tpl')
                else:
                    if url_hash != '':
                        url = url_hash + '?next=' + urllib.quote(request.get_full_path())
                    else:
                        url = '#' + urllib.quote(request.get_full_path())
                    return HttpResponse('<script type="text/javascript">window.parent.location="/'
                                        + url + '";</script>')
            return func(request, *args, **kwargs)
        return _fn
    return handle_func


def deprecated(func):
    @wraps(func)
    def new_func(*args, **kwargs):
        warnings.warn_explicit(
            'Call to deprecated function {}.'.format(func.__name__),
            category=DeprecationWarning,
            filename=func.func_code.co_filename,
            lineno=func.func_code.co_firstlineno + 1
        )
        return func(*args, **kwargs)
    return new_func


@deprecated
def get_beijing_time(dt=None):
    if not dt:
        dt = datetime.datetime.utcnow()
    localtime = dt + datetime.timedelta(hours=8)
    return localtime


@deprecated
def get_utc_time(dt=None):
    if not dt:
        localtime = datetime.datetime.utcnow()
    else:
        localtime = dt - datetime.timedelta(hours=8)
    return localtime
