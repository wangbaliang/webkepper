# -*- coding: utf-8 -*-
import arrow
import xlwt
import time
from django.http import HttpResponse

from django.shortcuts import render
from django.views.decorators.csrf import ensure_csrf_cookie
from django.views.decorators.http import require_http_methods
import json

from libs.common import require_login
from libs.json_service_helper import json_service, ext_success, ext_fail

from models import (
    SeasonService,
    PeriodService,
    ClassTemplateService,
    CoachService,
    StudentService,
    DistrictService,
    ClassAdminService,
    ClassService,
    MonitorService
)
from libs.datetime_helper import period_int_to_time, period_str_to_int


# =====================================
#
# 学季管理相关页面及ajax接口
#
# =====================================
@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def season_list_page(request):
    return render(request, 'tutor/season_list.tpl')


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def season_list(request):
    data = SeasonService.get_season_list()
    return ext_success({'rows': data, 'total': len(data)})


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def add_season(request):
    post_data = request.POST
    year = int(post_data['year'])
    season_type = int(post_data['seasonType'])
    start_day = post_data['startDay']
    end_day = post_data['endDay']
    except_days = request.POST.getlist('exceptDays')
    data = {
        'year': year,
        'season_type': season_type,
        'start_day': start_day,
        'end_day': end_day,
        'except_days': [item for item in except_days if item]
    }
    result = SeasonService.add_season(data)
    if result > 0:
        return ext_success()
    else:
        return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def edit_season(request):
    post_data = request.POST
    season_id = int(post_data['id'])
    year = int(post_data['year'])
    season_type = int(post_data['seasonType'])
    start_day = post_data['startDay']
    end_day = post_data['endDay']
    except_days = request.POST.getlist('exceptDays')
    data = {
        'id': season_id,
        'year': year,
        'season_type': season_type,
        'start_day': start_day,
        'end_day': end_day,
        'except_days': [item for item in except_days if item]
    }
    result = SeasonService.update_season(data)
    if result:
        return ext_success()
    else:
        return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def delete_season(request):
    post_data = request.POST
    season_id = int(post_data['id'])
    result = SeasonService.delete_season(season_id)
    if result:
        return ext_success()
    else:
        return ext_fail()


# =====================================
#
# 学季时段管理相关页面及ajax接口
#
# =====================================
@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def period_list_page(request):
    return render(request, 'tutor/period_list.tpl')


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def period_list(request):
    offset = int(request.GET['start'])
    limit = int(request.GET['limit'])
    data, total = PeriodService.get_period_list(limit, offset)
    for item in data:
        item.startTime = period_int_to_time(item.startTime).strftime('%H:%M')
        item.endTime = period_int_to_time(item.endTime).strftime('%H:%M')
    return ext_success({'rows': data, 'total': total})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def period_find(request):
    season_id = int(request.GET['seasonId'])
    grade_type = int(request.GET['gradeType'])
    data = PeriodService.get_by_season_and_grade_type(season_id, grade_type)
    for item in data:
        item.startTime = period_int_to_time(item.startTime).strftime('%H:%M')
        item.endTime = period_int_to_time(item.endTime).strftime('%H:%M')
    return ext_success({'rows': data, 'total': len(data)})


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def add_period(request):
    post_data = request.POST
    p_list = []
    result = []
    for i in range(1, 7):
        startTime = 'startTime' + str(i)
        endTime = 'endTime' + str(i)
        if startTime in post_data.keys():
            p_list.append({
                'startTime': post_data[startTime],
                'endTime': post_data[endTime]
            })
    for item in p_list:
        data = {
            'seasonId': int(post_data['seasonId']),
            'gradeType': int(post_data['gradeType']),
            'startTime': period_str_to_int(item['startTime']),
            'endTime': period_str_to_int(item['endTime']),
        }
        result.append(PeriodService.add(data))
    if len(result) > 0:
        return ext_success()
    else:
        return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def edit_period(request):
    post_data = request.POST
    data = {
        'id': int(post_data['id']),
        'seasonId': int(post_data['seasonId']),
        'gradeType': int(post_data['gradeType']),
        'startTime': period_str_to_int(post_data['startTime']),
        'endTime': period_str_to_int(post_data['endTime']),
    }
    result = PeriodService.update(data)
    if result:
        return ext_success()
    else:
        return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def delete_period(request):
    post_data = request.POST
    period_id = int(post_data['id'])
    result = PeriodService.delete(period_id)
    if result:
        return ext_success()
    else:
        return ext_fail()


# =====================================
#
# 班型管理相关页面及ajax接口
#
# =====================================
@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def class_template_list_page(request):
    return render(request, 'tutor/class_template_list.tpl')


@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def class_template_reservation_page(request):
    return render(request, 'tutor/class_template_reservation.tpl')


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def class_template_list(request):
    offset = int(request.GET['start'])
    limit = int(request.GET['limit'])
    args = request.GET
    parameters = {}
    if args.get('seasonId'):
        parameters['season_id'] = int(request.GET['seasonId'])
    if args.get('grade'):
        parameters['grade'] = int(request.GET['grade'])
    if args.get('subjectId'):
        parameters['subject_id'] = int(request.GET['subjectId'])
    if args.get('periodId'):
        parameters['period_id'] = int(request.GET['periodId'])
    data, total = ClassTemplateService.filter_class_templates(
        limit, offset, **parameters)
    for item in data:
        item.startTime = period_int_to_time(item.startTime).strftime('%H:%M')
        item.endTime = period_int_to_time(item.endTime).strftime('%H:%M')
    return ext_success({'rows': data, 'total': total})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def reservation_list(request):
    offset = int(request.GET['start'])
    limit = int(request.GET['limit'])
    parameters = {}
    data, total = ClassTemplateService.filter_reservation_list(limit, offset, **parameters)
    for item in data:
        item.startTime = period_int_to_time(item.startTime).strftime('%H:%M')
        item.endTime = period_int_to_time(item.endTime).strftime('%H:%M')
    return ext_success({'rows': data, 'total': total})


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def add_class_template(request):
    post_data = request.POST
    data = {
        'seasonId': int(post_data['seasonId']),
        'periodId': int(post_data['periodId']),
        'subjectId': int(post_data['subjectId']),
        'grade': int(post_data['grade']),
        'cycleDay': int(post_data['cycleDay']),
        'startTime': 0,
        'endTime': 0,
        'maxClassNum': int(post_data['maxClassNum']),
        'maxStudentNum': int(post_data['maxStudentNum']),
    }
    result = ClassTemplateService.add(data)
    if result > 0:
        return ext_success()
    else:
        return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def edit_class_template(request):
    post_data = request.POST
    data = {
        'id': int(post_data['id']),
        'seasonId': int(post_data['seasonId']),
        'periodId': int(post_data['periodId']),
        'subjectId': int(post_data['subjectId']),
        'grade': int(post_data['grade']),
        'cycleDay': int(post_data['cycleDay']),
        'startTime': 0,
        'endTime': 0,
        'maxClassNum': int(post_data['maxClassNum']),
        'maxStudentNum': int(post_data['maxStudentNum']),
    }
    result = ClassTemplateService.update(data)
    if result:
        return ext_success()
    else:
        return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def delete_class_template(request):
    post_data = request.POST
    class_template_id = int(post_data['id'])
    result = ClassTemplateService.delete(class_template_id)
    if result:
        return ext_success()
    else:
        return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def export_reservation_data(request):
    book = xlwt.Workbook(encoding='utf8')
    sheet = book.add_sheet('sheet1')
    season_map = __get_season_map()
    data, total = ClassTemplateService.filter_reservation_list(1000, 0)
    title_list = ['班型编号', '学季', '科目', '年级', '循环日', '时段', '最大开班数', '每班最大人数', '班型总人数', '最小教练需求数',
                  '可用教练数', '已分班人数', '已报名还未分班人数',
                  '累计报名人数']
    row = 0
    today = arrow.now('+08:00')
    for title_item in title_list:
        sheet.write(0, row, title_item, style=xlwt.Style.default_style)
        row += 1
    start_line = 1
    for line_item in data:
        sheet.write(start_line, 0, line_item.id, style=xlwt.Style.default_style)
        sheet.write(start_line, 1, __trans_season_id_to_season_string(line_item.seasonId, season_map)
                    , style=xlwt.Style.default_style)
        sheet.write(start_line, 2, __SUBJECTS[line_item.subjectId], style=xlwt.Style.default_style)
        sheet.write(start_line, 3, __GRADES[line_item.grade], style=xlwt.Style.default_style)
        sheet.write(start_line, 4, __CYCLE_DAYS[line_item.cycleDay], style=xlwt.Style.default_style)
        sheet.write(start_line, 5, "%s~%s" %
                    (period_int_to_time(line_item.startTime).strftime('%H:%M')
                     , period_int_to_time(line_item.endTime).strftime('%H:%M'))
                    , style=xlwt.Style.default_style)
        sheet.write(start_line, 6, line_item.maxClassNum, style=xlwt.Style.default_style)
        sheet.write(start_line, 7, line_item.maxStudentNum, style=xlwt.Style.default_style)
        sheet.write(start_line, 8, line_item.maxStudentInClass, style=xlwt.Style.default_style)
        sheet.write(start_line, 9, line_item.minNeededCoachNumber, style=xlwt.Style.default_style)
        sheet.write(start_line, 10, line_item.usableCoachNumber, style=xlwt.Style.default_style)
        sheet.write(start_line, 11, line_item.allotStudentNumber, style=xlwt.Style.default_style)
        sheet.write(start_line, 12, line_item.unallotStudentNumber, style=xlwt.Style.default_style)
        sheet.write(start_line, 13, line_item.allStudentNumber, style=xlwt.Style.default_style)
        start_line += 1
    sheet.write(start_line+2, 0, "统计日期", style=xlwt.Style.default_style)
    today_str = today.format(u'YYYY年MM月DD日')
    sheet.write(start_line+2, 1, today_str, style=xlwt.Style.default_style)
    response = HttpResponse(content_type='application/ms-excel')

    response['Content-Disposition'] = 'attachment; filename=reservation%s.xls' % today.format('YYYYMMDD')
    book.save(response)
    return response

# =====================================
#
# 教练管理相关页面及ajax接口
#
# =====================================
@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def coach_list_page(request):
    return render(request, 'tutor/coach_list.tpl')


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def coach_list(request):
    offset = int(request.GET['start'])
    limit = int(request.GET['limit'])
    args = request.GET
    parameters = {}
    if args.get('userName'):
        parameters['userName'] = request.GET['userName']
    if args.get('phone'):
        parameters['phone'] = request.GET['phone']
    if args.get('subjectId'):
        parameters['subjectId'] = int(request.GET['subjectId'])
    if args.get('qq'):
        parameters['qq'] = request.GET['qq']
    if args.get('cycle_day'):
        parameters['cycle_day'] = request.GET['cycle_day']
    if args.get('period_id'):
        parameters['period_id'] = request.GET['period_id']
    data, total = CoachService.filter_coaches(limit, offset, **parameters)
    return ext_success({'rows': data, 'total': total})


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def coach_import(request):
    coach_names_text = request.POST['coachNames']
    coach_names = coach_names_text.replace('\r', '').split('\n')
    check_result = CoachService.check_import_coach_names(coach_names)

    if check_result.imported or check_result.notExists \
            or check_result.notTeacher:
        return ext_fail(check_result)
    result = CoachService.import_coaches(coach_names)
    if result:
        return ext_success()
    else:
        return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def dismiss_coach(request):
    coach_name = request.POST['coachName']
    remark = request.POST['remark']
    class_ids = CoachService.get_coach_class_ids(coach_name)
    if class_ids:
        return ext_fail(class_ids)
    result = CoachService.dismiss_coach(
        coach_name, request.user.username, remark)
    if result:
        return ext_success()
    else:
        return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def set_coach_retraining(request):
    coach_name = request.POST['coachName']
    remark = request.POST['remark']
    class_ids = CoachService.get_coach_class_ids(coach_name)
    if class_ids:
        return ext_fail(class_ids)
    result = CoachService.set_coach_retraining(coach_name, request.user.username, remark)
    if result:
        return ext_success()
    return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def set_coach_trial(request):
    coach_name = request.POST['coachName']
    remark = request.POST['remark']
    result = CoachService.set_coach_trial(coach_name, request.user.username, remark)
    if result:
        return ext_success()
    return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def set_coach_positive(request):
    coach_name = request.POST['coachName']
    remark = "转正"
    result = CoachService.set_coach_positive(coach_name, request.user.username, remark)
    if result:
        return ext_success()
    return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def cancel_coach_retraining(request):
    coach_name = request.POST['coachName']
    remark = "再培结束"
    result = CoachService.cancel_coach_retraining(coach_name, request.user.username, remark)
    if result:
        return ext_success()
    else:
        return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def set_coach_reserve(request):
    coach_name = request.POST['coachName']
    remark = "转储备"
    result = CoachService.set_coach_reserve(coach_name, request.user.username, remark)
    if result:
        return ext_success()
    else:
        return ext_fail()

@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def get_rank_class_num(request):
    """
    获取等级对应的班级数量
    """
    data = ClassService.get_rank_class_num()
    total = len(data)
    return ext_success({'rows': data, 'total': total})


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def update_rank_class_num(request):
    fields = ('id', 'rank', 'spring_base_num', 'spring_max_num', 'winter_base_num', 'winter_max_num')
    data = json.loads(request.body)
    print data
    for item in data:
        if item.get('id') < 0:
            return ext_fail(u"数据中缺少ID")
        flag = {k in fields for k in item.keys()}
        if False in flag:
            return ext_fail(u"非法数据")
    if ClassService.update_rank_class_num(request.body):
        return ext_success()
    return ext_fail(u"数据错误")

@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def set_coach_class_num(request):
    data = request.POST
    coachName = data.get('coachName')
    coachRank = data.get('coachRank')
    if not coachName or not coachRank:
        return ext_fail()
    CoachService.set_coach_class_num(coachName, int(coachRank))
    return ext_success()

# =====================================
#
# 学员管理相关页面及ajax接口
#
# =====================================


@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def student_list_page(request):
    return render(request, 'tutor/student_list.tpl')


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def student_list(request):
    offset = int(request.GET['start'])
    limit = int(request.GET['limit'])
    args = request.GET
    parameters = {}
    if args.get('userName'):
        parameters['userName'] = request.GET['userName']
    if args.get('grade'):
        parameters['grade'] = int(request.GET['grade'])
    if args.get('areaCode'):
        parameters['areaCode'] = request.GET['areaCode']
    data, total = StudentService.filter_students(limit, offset, **parameters)
    return ext_success({'rows': data, 'total': total})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def area_data(request):
    data = DistrictService.get_all_area_data()
    result = [(key, value) for key, value in data.iteritems()]
    return ext_success(result)


# =====================================
#
# 组班管理相关页面及ajax接口
#
# =====================================
@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def class_create_list_page(request):
    return render(request, 'tutor/class_create_list.tpl')


def __is_near(class_day, start_time):
    start_time = arrow.get('%s %s' % (class_day, start_time)).replace(tzinfo='+08:00')
    line_time = arrow.now('+08:00').replace(hours=+26)
    return line_time >= start_time


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def class_create_task_list(request):
    offset = int(request.GET['start'])
    limit = int(request.GET['limit'])
    data, total = ClassAdminService.get_class_create_list(limit, offset)
    for item in data:
        item.startTime = period_int_to_time(item.startTime).strftime('%H:%M')
        item.endTime = period_int_to_time(item.endTime).strftime('%H:%M')
        item.isNear = item.taskStatus < 2 and __is_near(item.classDay, item.startTime)
    return ext_success({'rows': data, 'total': total})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def export_class_create_tasks(request):
    book = xlwt.Workbook(encoding='utf8')
    sheet = book.add_sheet('sheet1')
    data, total = ClassAdminService.get_class_create_list(2000, 0)
    title_list = ['任务编号', '年级', '科目', '开班日期', '时段', '空余名额', '报名人数', '需组班数量', '已确认教练',
                  '完成测试教练']
    row = 0
    today = arrow.now('+08:00')
    for title_item in title_list:
        sheet.write(0, row, title_item, style=xlwt.Style.default_style)
        row += 1
    start_line = 1
    for line_item in data:
        sheet.write(start_line, 0, line_item.id, style=xlwt.Style.default_style)
        sheet.write(start_line, 1, __GRADES[line_item.grade], style=xlwt.Style.default_style)
        sheet.write(start_line, 2, __SUBJECTS[line_item.subjectId], style=xlwt.Style.default_style)
        sheet.write(start_line, 3, line_item.classDay, style=xlwt.Style.default_style)
        sheet.write(start_line, 4, "%s~%s" %
                    (period_int_to_time(line_item.startTime).strftime('%H:%M')
                     , period_int_to_time(line_item.endTime).strftime('%H:%M'))
                    , style=xlwt.Style.default_style)
        sheet.write(start_line, 5, line_item.remainNum, style=xlwt.Style.default_style)
        sheet.write(start_line, 6, line_item.studentNum, style=xlwt.Style.default_style)
        sheet.write(start_line, 7, line_item.newClassNum, style=xlwt.Style.default_style)
        sheet.write(start_line, 8, line_item.acceptCoachNum, style=xlwt.Style.default_style)
        sheet.write(start_line, 9, line_item.testSuccessCoachNum, style=xlwt.Style.default_style)
        start_line += 1
    sheet.write(start_line+2, 0, "统计日期", style=xlwt.Style.default_style)
    today_str = today.format(u'YYYY年MM月DD日')
    sheet.write(start_line+2, 1, today_str, style=xlwt.Style.default_style)
    response = HttpResponse(content_type='application/ms-excel')

    response['Content-Disposition'] = 'attachment; filename=taskList%s.xls' % today.format('YYYYMMDD')
    book.save(response)
    return response


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def task_invite_list(request):
    task_id = int(request.GET['taskId'])
    data = ClassAdminService.get_task_invite(task_id)
    total = len(data)
    return ext_success({'rows': data, 'total': total})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def task_apply_student_list(request):
    task_id = int(request.GET['taskId'])
    data = ClassAdminService.get_task_apply_students(task_id)
    total = len(data)
    return ext_success({'rows': data, 'total': total})


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def invite_coach(request):
    task_id = int(request.POST['taskId'])
    coach_name = request.POST['coachName']
    result = ClassAdminService.invite_coach(task_id, coach_name)
    if result > 0:
        return ext_success()
    messages = {
        0: u'数据错误，请重试',
        -1: u'教练不存在，请检查数据后重试',
        -2: u'教练已被邀请或未设置可用时段，不能被邀请',
        -3: u'此教练会导致分班冲突'
    }
    message = messages.get(result, u'操作失败，请您重试')
    return ext_fail(message)


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def cancel_invite_coach(request):
    task_id = int(request.POST['taskId'])
    coach_name = request.POST['coachName']
    result = ClassAdminService.cancel_invite(task_id, coach_name)
    if result:
        return ext_success()
    else:
        return ext_fail(u'该邀请不存在，请您重试')

# =====================================
#
# 班级管理相关页面及ajax接口
#
# =====================================


@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def class_list_page(request):
    return render(request, 'tutor/class_list.tpl')


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def class_list(request):
    offset = int(request.GET['start'])
    limit = int(request.GET['limit'])
    args = request.GET
    parameters = {}
    data = {}
    para_key = ['classID', 'templateID', 'teacherName', 'startDate', 'year', 'season', 'grade', 'subject']
    for key in para_key:
        if args.get(key):
            parameters[key] = request.GET[key]
    data, total = ClassService.filter_class(limit, offset, **parameters)
    for item in data:
        item.startTime = period_int_to_time(item.startTime).strftime('%H:%M')
        item.endTime = period_int_to_time(item.endTime).strftime('%H:%M')
    return ext_success({'rows': data, 'total': total})


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def exchange_coach(request):
    """
    更换教练
    """
    class_id = int(request.POST['class_id'])
    new_coach_name = request.POST['new_coach_user_name'].lstrip().rstrip()
    reason_type = int(request.POST['reason'])
    remark = request.POST['remark']
    state = ClassAdminService.exchange_coach(class_id, new_coach_name, reason_type, remark)
    return ext_success({'state': state})


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def close_class(request):
    class_id = int(request.POST['classId'])
    result = ClassAdminService.close_class(class_id)
    if result:
        return ext_success()
    else:
        return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def enlist_list_by_user_name(request):
    userName = request.GET['userName']
    # 学生用户名，去报名表里找信息形成列表
    data = StudentService.get_enlist_list(userName)
    # 获取报名列表
    return ext_success({'rows': data, 'total': ""})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def coach_usable_period_by_id(request):
    userName = request.GET['userName']
    data = CoachService.get_coach_period_list(userName)

    return ext_success({'rows': data, 'total': ''})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def fire_coach_info_by_name(request):
    user_name = request.GET['userName']
    data, total = CoachService.fire_coach_info_by_name(user_name)
    return ext_success({'rows': data, 'total': ''})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def student_info_in_class_by_class_id(request):
    class_id = int(request.GET['class_id'])
    data = ClassService.get_students_in_this_class(class_id)
    return ext_success({'rows': data, 'total': ''})


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def modify_class_for_student(request):
    para_list = request.POST
    student_id = int(para_list['student_id'])
    change_list = json.loads(para_list['change_list'])
    data = ClassService.modify_class_for_student(student_id, change_list)
    return ext_success({'rows': '', 'total': ''})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def class_list_of_student_by_user_name(request):
    userName = request.GET['userName']
    # 学生用户名，去上课表里找信息形成列表
    data = StudentService.get_class_list(userName)
    # 获取报名列表
    return ext_success({'rows': data, 'total': ""})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def temp_replace_class_time(request):
    class_id = int(request.GET['class_id'])
    class_info = ClassService.get_class_by_id(class_id)
    lesson_plan = json.loads(class_info[0].lessonPlan)
    now = arrow.now('+08:00').strftime('%Y-%m-%d %X')
    output_days = []
    for item in lesson_plan:
        cur_day = "%s %s" % (item['day'], item['start_time'])
        if now < cur_day:
            output_days.append({
                'classTime': item['day'],
                'startTime': item['start_time'][:5],
                'endTime': item['end_time'][:5]
            })
    return ext_success({'rows': output_days, 'total': len(output_days)})


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def temp_replace_coach(request):
    class_id = int(request.POST['class_id'])
    new_coach_name = request.POST['new_coach_user_name'].lstrip().rstrip()
    days = json.loads(request.POST['days'])
    remark = request.POST['reason']
    state = ClassAdminService.temp_replace_coach(class_id, new_coach_name, days, remark)
    return ext_success({'state': state})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def class_temporary_substitute_state_page(request):
    return render(request, 'tutor/class_temporary_substitute_state.tpl')


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def class_temporary_substitute_state(request):
    params = {}
    offset = int(request.GET['start'])
    limit = int(request.GET['limit'])
    data, total = ClassService.get_temporary_substitute_list(limit, offset, **params)
    for item in data:
        item.startTime = period_int_to_time(item.startTime).strftime('%H:%M')
        item.endTime = period_int_to_time(item.endTime).strftime('%H:%M')
    return ext_success({'rows': data, 'total': total})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def class_temporary_enrollment_schedule_page(request):
    return render(request, 'tutor/class_temporary_enrollment_schedule.tpl')


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def class_template_enrollment_schedule(request):
    params = {}
    offset = int(request.GET['start'])
    limit = int(request.GET['limit'])
    data, total = ClassTemplateService.get_class_template_enrollment_schedule(limit, offset)
    for item in data:
        item.startTime = period_int_to_time(item.startTime).strftime('%H:%M')
        item.endTime = period_int_to_time(item.endTime).strftime('%H:%M')
    return ext_success({'rows': data, 'total': total})


__SEASON_TYPE = ['', '秋季', '寒假', '春季', '暑假']
__SUBJECTS = ['', '语文', '数学', '英语', '物理', '化学', '生物',
              '历史', '地理', '政治', '文科综合', '理科综合', '其他', '科学']
__GRADES = ['', '一年级', '二年级', '三年级', '四年级',
            '五年级', '六年级', '初一', '初二', '初三', '高一', '高二', '高三']
__CYCLE_DAYS = ['', '每周一', '每周二', '每周三', '每周四', '每周五', '每周六', '每周日', '周一到周六', '周六日']


@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def export_excel_class_template_enrollment_schedule(request):
    book = xlwt.Workbook(encoding='utf8')
    sheet = book.add_sheet('sheet1')
    season_map = __get_season_map()
    data, total = ClassTemplateService.get_class_template_enrollment_schedule(500, 0)
    title_list = ['编号', '学季', '科目', '年级', '循环日', '时段', '招生名额', '占用名额报名人数', '报名本次课的学员', '剩余名额',
                  '本次课剩余名额', '上次课需续约数', '上次课未续约数',
                  '需要在本次课续约数', '上次课新约课总人数', '上周新约课总人数']
    row = 0
    today = arrow.now('+08:00')
    for title_item in title_list:
        sheet.write(0, row, title_item, style=xlwt.Style.default_style)
        row += 1
    start_line = 1
    for line_item in data:
        sheet.write(start_line, 0, line_item.templateId, style=xlwt.Style.default_style)
        sheet.write(start_line, 1, __trans_season_id_to_season_string(line_item.seasonId, season_map), style=xlwt.Style.default_style)
        sheet.write(start_line, 2, __SUBJECTS[line_item.subjectId], style=xlwt.Style.default_style)
        sheet.write(start_line, 3, __GRADES[line_item.grade], style=xlwt.Style.default_style)
        sheet.write(start_line, 4, __CYCLE_DAYS[line_item.cycleDay], style=xlwt.Style.default_style)
        sheet.write(start_line, 5, "%s~%s" %
                    (period_int_to_time(line_item.startTime).strftime('%H:%M'), period_int_to_time(line_item.endTime).strftime('%H:%M')), style=xlwt.Style.default_style)
        sheet.write(start_line, 6, line_item.totalNumber, style=xlwt.Style.default_style)
        sheet.write(start_line, 7, line_item.usedNumber, style=xlwt.Style.default_style)
        sheet.write(start_line, 8, line_item.currentClassNumber, style=xlwt.Style.default_style)
        sheet.write(start_line, 9, line_item.totalRestNumber, style=xlwt.Style.default_style)
        sheet.write(start_line, 10, line_item.currentRestNumber, style=xlwt.Style.default_style)
        sheet.write(start_line, 11, line_item.lastClassContinueNumber, style=xlwt.Style.default_style)
        sheet.write(start_line, 12, line_item.lastClassUnContinueNumber, style=xlwt.Style.default_style)
        sheet.write(start_line, 13, line_item.currentContinueNumber, style=xlwt.Style.default_style)
        sheet.write(start_line, 14, line_item.lastClassNewNumber, style=xlwt.Style.default_style)
        sheet.write(start_line, 15, line_item.lastWeekTotalNumber, style=xlwt.Style.default_style)
        start_line += 1
    sheet.write(start_line + 2, 0, "统计日期", style=xlwt.Style.default_style)
    today_str = today.format(u'YYYY年MM月DD日')
    sheet.write(start_line + 2, 1, today_str, style=xlwt.Style.default_style)
    response = HttpResponse(content_type='application/ms-excel')

    response['Content-Disposition'] = 'attachment; filename=schedule%s.xls' % today.format('YYYYMMDD')
    book.save(response)
    return response


def __get_season_map():
    season_data = SeasonService.get_season_list()
    season_map = {}
    for item in season_data:
        season_map[item.id] = item
    return season_map


def __trans_season_id_to_season_string(season_id, season_map):
    if season_id in season_map:
        return "%d-%d%s" % (season_map[season_id].year, season_map[season_id].year + 1, __SEASON_TYPE[season_map[season_id].seasonType])
    else:
        return "学季数据有误"


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def send_notification(request):
    """
    发送通知
    """
    alltarget = [u'coach', u'student_in_class', u'student_not_in_class']
    class_id = request.POST.get('classId')
    notification = request.POST.get('notification')
    target = request.POST.getlist('target')
    target = [alltarget.index(identify) for identify in target]
    if not notification or not target:
        return ext_fail()
    if ClassAdminService.send_notification(int(class_id), notification, target):
        message = u'通知发送成功'
    else:
        message = u'未查询到发送对象手机号, 未发送短信'
    return ext_success(message)


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def modify_student_to_another_class(request):
    """
    调班
    """
    student_name = request.GET.get('studentName')
    origin_class_id = request.GET.get('originClassId')
    target_class_id = request.GET.get('targetClassId')
    if not student_name or not origin_class_id or not target_class_id:
        return ext_fail(u'无法获取学生名/目标班级ID/原班级ID')

    try:
        origin_class_id = int(origin_class_id)
        target_class_id = int(target_class_id)
    except:
        return ext_fail(u'请输入正确的班级ID')

    remark = u'前台暂未要求输入备注原因'
    result = ClassAdminService.modify_student_to_another_class(student_name,
                                                               origin_class_id,
                                                               target_class_id,
                                                               request.user.username,
                                                               remark)
    if result != 1:
        messages = {
            0: u'数据错误，请重试',
            -1: u'调班失败: 该学员已在目标班级中',
            -2: u'调班失败：目标班级不存在或已结束',
            -3: u'调班失败: 目标班级不符',
            -4: u'调班失败: 本班级正在上课',
            -5: u'调班失败: 目标班级正在上课',
            -6: u'调班失败：目标班级剩余课次为0',
            -7: u'调班失败: 目标班级无剩余名额',
            -8: u'调班失败: 目标班型剩余课次不足',
            -9: u'调班失败: 教练学生冲突',
            -10: u'调班失败: 目标班型剩余名额不足',
            -11: u'调班失败: 当前时间已过调班有效时间',
            -12: u'调班失败: 未找到该学生合法的约课记录'
        }
        message = messages.get(result, u'操作失败, 请重试')
        return ext_fail(message)
    return ext_success()


# =====================================
#
# 课堂监控相关页面及ajax接口
#
# =====================================
@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def class_monitor_page(request):
    return render(request, 'tutor/class_monitor.tpl')


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def monitor_class_list(request):
    offset = int(request.GET['start'])
    limit = int(request.GET['limit'])
    coachOrStudent = int(request.GET['type'])
    # 1表示异常，0表示不异常
    unusual = int(request.GET['unusual'])
    args = request.GET
    parameters = {}
    data = {}
    para_key = ['classID', 'templateID', 'teacherName', 'startDate', 'year', 'season', 'grade', 'subject']
    for key in para_key:
        if args.get(key):
            parameters[key] = request.GET[key]
    if coachOrStudent == 0:
        if unusual:
            data, total = MonitorService.filter_unusual_coach_class(limit, offset, **parameters)
        else:
            data, total = MonitorService.filter_coach_class(limit, offset, **parameters)
    elif coachOrStudent == 1:
        if unusual:
            data, total = MonitorService.filter_unusual_student_class(limit, offset, **parameters)
        else:
            data, total = MonitorService.filter_student_class(limit, offset, **parameters)
    else:
        totol = 0
    for item in data:
        item.startTime = period_int_to_time(item.startTime).strftime('%H:%M')
        item.endTime = period_int_to_time(item.endTime).strftime('%H:%M')
    return ext_success({'rows': data, 'total': total})


# =====================================
#
# 教练招培相关页面及ajax接口
#
# =====================================
@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def coach_hiring_list_page(request):
    return render(request, 'tutor/coach_hiring_list.tpl')


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def coach_hiring_list(request):
    offset = int(request.GET['start'])
    limit = int(request.GET['limit'])
    args = request.GET
    parameters = {}
    if args.get('userName'):
        parameters['userName'] = request.GET['userName']
    if args.get('phone'):
        parameters['phone'] = request.GET['phone']
    if args.get('subjectId'):
        parameters['subjectId'] = int(request.GET['subjectId'])
    if args.get('qq'):
        parameters['qq'] = request.GET['qq']
    data, total = CoachService.filter_hiring_coaches(limit, offset, **parameters)
    return ext_success({'rows': data, 'total': total})


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def coach_hiring_import(request):
    coach_names_text = request.POST['coachNames']
    coach_names = coach_names_text.replace('\r', '').split('\n')
    check_result = CoachService.check_import_hiring_coach_names(coach_names)
    if check_result.imported or check_result.notExists \
            or check_result.notTeacher:
        return ext_fail(check_result)
    result = CoachService.import_hiring_coaches(coach_names)
    if result:
        return ext_success()
    return ext_fail()


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def set_coach_reserve(request):
    coach_name = request.POST['coachName']
    remark = '转储备'
    result = CoachService.set_coach_reserve(coach_name, request.user.username, remark)
    if result:
        return ext_success()
    return ext_fail()

# =====================================
#
# 教练更换状态相关页面及ajax接口
#
# =====================================
@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def change_coach_status_page(request):
    return render(request, 'tutor/change_coach_status_list.tpl')


@ensure_csrf_cookie
@require_http_methods(['GET'])
@json_service()
def change_coach_status_list(request):
    offset = int(request.GET['start'])
    limit = int(request.GET['limit'])
    data, total = ClassService.get_change_class_coach_list(limit, offset)
    for item in data:
        item.startTime = period_int_to_time(item.startTime).strftime('%H:%M')
        item.endTime = period_int_to_time(item.endTime).strftime('%H:%M')
    return ext_success({'rows': data, 'total': total})


@ensure_csrf_cookie
@require_http_methods(['POST'])
@json_service()
def change_coach_list_invite_coach(request):
    """
    教练更换状态邀请教练
    """
    class_id = int(request.POST['class_id'])
    new_coach_name = request.POST['new_coach_user_name'].lstrip().rstrip()
    # 公司要求
    reason_type = 1
    remark = u'教练更换状态页面邀请教师'
    state = ClassAdminService.exchange_coach(class_id, new_coach_name, reason_type, remark)
    return ext_success({'state': state})
