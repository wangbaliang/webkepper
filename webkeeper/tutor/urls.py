# -*- coding: utf-8 -*-

from django.conf.urls import patterns, url

urlpatterns = patterns(
    '',
    url(r'^season_list$', 'tutor.views.season_list_page',
        name='tutor.season_list'),
    url(r'^period_list$', 'tutor.views.period_list_page',
        name='tutor.period_list'),
    url(r'^class_template_list$', 'tutor.views.class_template_list_page',
        name='tutor.class_template_list'),
    url(r'^class_template_reservation$', 'tutor.views.class_template_reservation_page',
        name='tutor.class_template.reservation'),
    url(r'^coach_list$', 'tutor.views.coach_list_page',
        name='tutor.coach_list'),
    url(r'^student_list$', 'tutor.views.student_list_page',
        name='tutor.student_list'),
    url(r'^class_create_list$', 'tutor.views.class_create_list_page',
        name='tutor.class_create_list'),
    url(r'^class_list$', 'tutor.views.class_list_page',
        name='tutor.class_list'),
    url(r'^class_temporary_substitute_state$', 'tutor.views.class_temporary_substitute_state_page',
        name='tutor.class_temporary_substitute_state'),
    url(r'^class_temporary_enrollment_schedule$', 'tutor.views.class_temporary_enrollment_schedule_page',
        name='tutor.class_temporary_enrollment_schedule'),
    url(r'^class_monitor$', 'tutor.views.class_monitor_page',
        name='tutor.class_monitor'),
    url(r'^coach_hiring_list$', 'tutor.views.coach_hiring_list_page',
        name='tutor.coach_hiring_list'),
    url(r'change_coach_status$', 'tutor.views.change_coach_status_page',
        name='tutor.change_coach_status'),

    # ajax requests
    # 映射类ajax请求
    url(r'^ajax/area_data', 'tutor.views.area_data'),

    # 学季管理的ajax请求
    url(r'^ajax/season_list$', 'tutor.views.season_list'),
    url(r'^ajax/add_season$', 'tutor.views.add_season'),
    url(r'^ajax/edit_season$', 'tutor.views.edit_season'),
    url(r'^ajax/delete_season$', 'tutor.views.delete_season'),

    # 时段管理的ajax请求
    url(r'^ajax/period_list$', 'tutor.views.period_list'),
    url(r'^ajax/period_find$', 'tutor.views.period_find'),
    url(r'^ajax/add_period$', 'tutor.views.add_period'),
    url(r'^ajax/edit_period$', 'tutor.views.edit_period'),
    url(r'^ajax/delete_period$', 'tutor.views.delete_period'),

    # 班型管理的ajax请求
    url(r'^ajax/class_template_list$', 'tutor.views.class_template_list'),
    url(r'^ajax/add_class_template$', 'tutor.views.add_class_template'),
    url(r'^ajax/edit_class_template$', 'tutor.views.edit_class_template'),
    url(r'^ajax/delete_class_template$', 'tutor.views.delete_class_template'),
    url(r'^ajax/reservation_list$', 'tutor.views.reservation_list'),
    url(r'^ajax/class_template_enrollment_schedule$', 'tutor.views.class_template_enrollment_schedule'),
    url(r'^ajax/send_notification$', 'tutor.views.send_notification'),
    url(r'^excel/get_class_template_enrollment_schedule$',
        'tutor.views.export_excel_class_template_enrollment_schedule'),
    url(r'^excel/export_reservation_data$',
        'tutor.views.export_reservation_data'),

    # 教练管理的ajax请求
    url(r'^ajax/coach_list$', 'tutor.views.coach_list'),
    url(r'^ajax/fire_coach_info_by_name$', 'tutor.views.fire_coach_info_by_name'),
    url(r'^ajax/coach_usable_period_by_id$', 'tutor.views.coach_usable_period_by_id'),
    url(r'^ajax/exchange_coach$', 'tutor.views.exchange_coach'),
    url(r'^ajax/import_coaches$', 'tutor.views.coach_import'),
    url(r'^ajax/dismiss_coach$', 'tutor.views.dismiss_coach'),
    url(r'^ajax/set_coach_retraining$', 'tutor.views.set_coach_retraining'),
    url(r'^ajax/cancel_coach_retraining$', 'tutor.views.cancel_coach_retraining'),
    url(r'^ajax/set_coach_trial', 'tutor.views.set_coach_trial'),
    url(r'^ajax/set_coach_positive', 'tutor.views.set_coach_positive'),
    url(r'^ajax/get_rank_class_num', 'tutor.views.get_rank_class_num'),
    url(r'^ajax/update_rank_class_num', 'tutor.views.update_rank_class_num'),
    url(r'^ajax/set_coach_class_num', 'tutor.views.set_coach_class_num'),

    # 学员管理的ajax请求
    url(r'^ajax/student_list$', 'tutor.views.student_list'),
    url(r'^ajax/enlist_list_by_user_name$', 'tutor.views.enlist_list_by_user_name'),
    url(r'^ajax/modify_class_for_student$', 'tutor.views.modify_class_for_student'),

    # 班级管理的ajax请求
    url(r'^ajax/class_list$', 'tutor.views.class_list'),
    url(r'^ajax/student_info_in_class$', 'tutor.views.student_info_in_class_by_class_id'),
    url(r'^ajax/class_list_of_student_by_user_name$', 'tutor.views.class_list_of_student_by_user_name'),
    url(r'^ajax/area_data$', 'tutor.views.area_data'),
    url(r'^ajax/temp_replace_class_time$', 'tutor.views.temp_replace_class_time'),
    url(r'^ajax/temp_replace_coach$', 'tutor.views.temp_replace_coach'),
    url(r'^ajax/class_create_task_list$', 'tutor.views.class_create_task_list'),
    url(r'^excel/export_class_create_tasks',
        'tutor.views.export_class_create_tasks'),
    url(r'^ajax/task_invite_list$', 'tutor.views.task_invite_list'),
    url(r'^ajax/task_student_list$', 'tutor.views.task_apply_student_list'),
    url(r'^ajax/invite_coach$', 'tutor.views.invite_coach'),
    url(r'^ajax/cancel_invite_coach$', 'tutor.views.cancel_invite_coach'),
    url(r'^ajax/class_temporary_substitute_state$', 'tutor.views.class_temporary_substitute_state'),
    url(r'^ajax/modify_student_to_another_class$', 'tutor.views.modify_student_to_another_class'),
    url(r'^ajax/close_class', 'tutor.views.close_class'),

    # 班级监控的ajax请求
    url(r'^ajax/monitor_class_list$', 'tutor.views.monitor_class_list'),

    # 教练招培的ajax请求
    url(r'^ajax/coach_hiring_list$', 'tutor.views.coach_hiring_list'),
    url(r'^ajax/import_hiring_coaches$', 'tutor.views.coach_hiring_import'),
    url(r'^ajax/set_coach_reserve', 'tutor.views.set_coach_reserve'),

    # 教练更换状态监控
    url(r'^ajax/change_coach_status_list$', 'tutor.views.change_coach_status_list'),
    url(r'^ajax/change_coach_list_invite_coach$', 'tutor.views.change_coach_list_invite_coach'),

)
