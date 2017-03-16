# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render, redirect
from django.views.decorators.csrf import ensure_csrf_cookie
from django.views.decorators.http import require_http_methods
from django.contrib.auth import authenticate, login as _login, logout as _logout
from django.contrib.auth.models import User
from django.forms import Form, CharField, EmailField

from libs.json_service_helper import need_logon, fail, success, StatusCode, \
    check_input
from common.models import NavItems
from django.core.urlresolvers import reverse


@ensure_csrf_cookie
@require_http_methods(['GET'])
@need_logon
def tree(request):
    nav = NavItems.get_menu_data()
    return success(nav)


class LogonForm(Form):
    username = CharField(min_length=1, max_length=30, required=True)
    password = CharField(min_length=1, max_length=30, required=True)


class RegisterForm(Form):
    username = CharField(min_length=1, max_length=30, required=True)
    password = CharField(min_length=1, max_length=30, required=True)
    first_name = CharField(min_length=1, max_length=10, required=True)
    last_name = CharField(min_length=1, max_length=10, required=True)
    email = EmailField(min_length=1, max_length=256, required=True)


# Create your views here.
@ensure_csrf_cookie
@require_http_methods(['GET'])
def home(request):
    if not request.user.is_authenticated():
        return render(request, 'common/login.tpl')
    return render(request, 'home/home.tpl', {'current_page_names': ['home']})


@ensure_csrf_cookie
@require_http_methods(['GET'])
def welcome(request):
    return render(request, 'home/welcome.tpl',
                  {'current_page_names': ['index']})


@require_http_methods(['GET'])
def logout(request):
    _logout(request)
    url = reverse("home")
    return redirect(url)


@ensure_csrf_cookie
@require_http_methods(['POST'])
@check_input(LogonForm)
def login(request, form):
    username = form.cleaned_data['username']
    password = form.cleaned_data['password']
    user = authenticate(username=username, password=password)
    message = ''
    if user is None:
        message = "用户名密码错误"
    elif not user.is_active:
        message = "用户还未激活，请联系管理员"

    success_state = True
    result = 'no'
    if message == '':
        result = "ok"
        _login(request, user)

    data = {"success": success_state, "message": message, "result": result}
    return success(data)


@ensure_csrf_cookie
@require_http_methods(['POST'])
@check_input(RegisterForm)
def register(request, form):
    username = form.cleaned_data['username']
    password = form.cleaned_data['password']
    first_name = form.cleaned_data['first_name']
    last_name = form.cleaned_data['last_name']
    email = form.cleaned_data['email']
    user = User.objects.create_user(
        username=username,
        email=email,
        password=password,
        first_name=first_name,
        last_name=last_name)
    user.is_active = False
    user.save()
    return success(user)
