# -*- coding: utf-8 -*-
"""

"""
from django.conf.urls import patterns, url

urlpatterns = patterns(
    '',
    # url(r'^courses$', 'nc.views.course_list', name='nc.course_list'),
    # (r'^mydata/(?P<id>\d+)/$', views.my_view, {'id': 3}),

    url(r'^course_list$', 'nc.views.course_list', name='nc.course_list'),
    url(r'^lesson_list/(?P<course_id>[A-Za-z\d]+)$', 'nc.views.lesson_list'),
    url(r'^survey_list$', 'nc.views.survey_list', name='nc.survey_list'),
    url(r'^survey_list/(?P<survey_type>[0,1])$', 'nc.views.survey_list'),
    url(r'^survey_show/(?P<survey_type>[0,1])/(?P<survey_id>[A-Za-z\d]+)$', 'nc.views.survey_show'),
    url(r'^survey_detail/(?P<survey_type>[0,1])/(?P<survey_id>[A-Za-z\d]+)$', 'nc.views.survey_detail',
        name='nc.survey_detail'),
    url(r'^survey_opt/(?P<survey_type>[0,1])$', 'nc.views.survey_opt', name='nc.survey_opt'),
    url(r'^survey_opt/(?P<survey_type>[0,1])/(?P<survey_id>[A-Za-z\d]+)$', 'nc.views.survey_opt'),
    url(r'^results_export/(?P<survey_id>[A-Za-z\d]+)$', 'nc.views.results_export'),

    url(r'^ajax/course_list$', 'nc.views.course_lists'),
    url(r'^ajax/course_apply_list$', 'nc.views.course_apply_list', name='nc.course_apply_list'),
    url(r'^ajax/lesson/list/(?P<course_id>[A-Za-z\d]+)$', 'nc.views.lesson_list_json'),
    url(r'^ajax/lesson/save', 'nc.views.lesson_save', name='nc.lesson_save'),
    url(r'^ajax/lesson/destroy$', 'nc.views.lesson_destroy', name='nc.lesson_destroy'),

    url(r'^ajax/survey_get/(?P<survey_type>[0,1])/(?P<survey_id>[A-Za-z\d]+)$', 'nc.views.survey_get'),
    url(r'^ajax/survey_detail/(?P<survey_type>[0,1])/(?P<survey_id>[A-Za-z\d]+)$',
        'nc.views.survey_detail_get'),
    url(r'^ajax/survey/save$', 'nc.views.survey_save', name='nc.survey_save'),
    url(r'^ajax/survey/destroy$', 'nc.views.survey_destroy', name='nc.survey_destroy'),
    url(r'^ajax/survey_issue$', 'nc.views.survey_issue', name='nc.survey_issue'),
    url(r'^ajax/survey_end$', 'nc.views.survey_end', name='nc.survey_end'),

    url(r'^ajax/results_list/(?P<survey_id>[A-Za-z\d]+)$', 'nc.views.results_list_json'),

    url(r'^ajax/survey_list/(?P<survey_type>[0,1])$', 'nc.views.survey_list_json'),
    url(r'^test$', 'nc.views.test'),
)