# -*- coding: utf-8 -*-

from datetime import time, datetime


def period_time_to_int(time_info):
    return time_info.hour * 60 + time_info.minute


def period_int_to_time(period_time):
    hour = period_time / 60
    minute = period_time % 60
    return time(hour=hour, minute=minute)


def period_str_to_int(period_str):
    period_date = datetime.strptime(period_str, '%H:%M')
    return period_time_to_int(period_date)
