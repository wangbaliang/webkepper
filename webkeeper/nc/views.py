# -*- coding: utf-8 -*-
from __future__ import unicode_literals, division

from django.shortcuts import render
from django.views.decorators.csrf import ensure_csrf_cookie
from django.views.decorators.http import require_http_methods
from django.http import HttpResponse
from django.conf import settings
from django.contrib import auth
from libs.json_service_helper import success, fail, objects_to_array, \
    check_input, data_to_json, str_to_data
from nc.models import Course, Lesson, Meetings, SurveySettings, SurveyCourses, SurveyResults, Users
import time
from libs.common import require_login, get_beijing_time, get_utc_time
from datetime import datetime, timedelta
from bson.objectid import ObjectId
from django.forms import Form, CharField, DateField, IntegerField


class LessonForm(Form):
    startTime = CharField(min_length=5, max_length=5, required=True)
    endTime = CharField(min_length=5, max_length=5, required=True)
    startDate = DateField(required=True)
    courseId = CharField(min_length=1, max_length=50, required=True)
    id = CharField(max_length=50)
    _id = CharField(min_length=24, max_length=24, required=False)


class SurveySettingForm(Form):
    title = CharField(required=True, min_length=1, max_length=30)
    count = IntegerField(required=False, min_value=0)
    surveyType = IntegerField(required=True, min_value=0, max_value=1)
    questionsStr = CharField(required=True)
    _id = CharField(max_length=24, min_length=24, required=False)


# Create your views here.


@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def course_list(request):
    page_info = ['nc', 'nc.course_list']
    return render(request, 'nc/course_list.tpl',
                  {'current_page_names': page_info})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def lesson_list(request, course_id):
    page_info = ['nc', 'nc.lesson_list']
    now = get_beijing_time().strftime('%Y-%m-%d %H:%M:%S')
    return render(request, 'nc/lesson_list.tpl',
                  {'current_page_names': page_info, 'course_id': course_id, 'now': now})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def survey_list(request, survey_type='0'):
    page_info = ['nc', 'nc.survey_list']
    return render(request, 'nc/survey_list.tpl',
                  {'current_page_names': page_info, 'survey_type': survey_type})


@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login()
def survey_opt(request, survey_type='1', survey_id=''):
    page_info = ['nc', 'nc.survey_opt']
    return render(request, 'nc/survey_opt.tpl', {'current_page_names': page_info, 'survey_type': survey_type,
                                                 'survey_id': survey_id})


@ensure_csrf_cookie
@require_http_methods(['GET'])
def course_lists(request):
    start_str = request.GET.get('start', '0')
    limit_str = request.GET.get('limit', '1')
    start = int(start_str)
    limit = int(limit_str)
    end = start + limit

    objects = Course.objects().order_by("-insert_time")[start:end]
    rows = objects_to_array(objects)
    # 学科列表
    subjects = {1: "语文", 2: "数学", 3: "英语", 4: "物理", 5: "化学", 6: "生物", 7: "历史", 8: "地理",
                9: "政治", 10: "文科综合", 11: "理科综合", 12: "其他", 13: "科学"}

    for key in range(0, len(rows)):
        row = rows[key]
        if "subject" in row.keys():
            if row["subject"] in subjects.keys():
                row["subject"] = subjects[row["subject"]]
            else:
                row["subject"] = ""
        else:
            row["subject"] = ""
    num = Course.objects().count()
    data = {"success": True, "message": "", "rows": rows, "total": num}
    return success(data)


# 适用课程列表
@ensure_csrf_cookie
@require_http_methods(['GET'])
def course_apply_list(request):
    now = datetime.utcnow()
    objects = Course.objects(end_day__gt=now)
    rows = objects_to_array(objects)
    data = {"success": True, "rows": rows}
    return success(data)


@ensure_csrf_cookie
@require_http_methods(['GET'])
def lesson_list_json(request, course_id):
    objects = Lesson.objects(course_id=course_id).order_by('start_time')
    rows = objects_to_array(objects)
    now = get_beijing_time()
    # time.localtime(time.time())
    for key in range(0, len(rows)):
        row = rows[key]
        # 根据指定的格式把一个时间字符串解析为时间元组
        start = datetime.strptime(row["startTime"], '%Y-%m-%d %H:%M:%S')
        end = datetime.strptime(row["endTime"], '%Y-%m-%d %H:%M:%S')
        delta = start - now
        # 未开始备课（无论是否已到了上课时间）：未开始
        # 备课中（无论是否已到了上课时间）\已完成备课且未到上课时间：备课中
        # 已备课且到了上课的时间：上课中
        # 老师结束听课：已结束 字段“isEnd”=true

        if row["readyStatus"] == 0:
            rows[key]["readyStatus"] = '未开始'
        elif row["readyStatus"] == 1:
            rows[key]["readyStatus"] = '备课中'
        else:
            # 上课时间未到
            if delta.total_seconds() > 0:
                rows[key]["readyStatus"] = '备课中'
            elif row["isEnd"] is False:
                rows[key]["readyStatus"] = '上课中'
            else:
                rows[key]["readyStatus"] = '已结束'

        rows[key]["startDate"] = start.strftime('%Y-%m-%d')
        rows[key]["startTime"] = start.strftime('%H:%M')
        rows[key]["endTime"] = end.strftime('%H:%M')
        rows[key]["time"] = start.strftime('%H:%M') + "-" + end.strftime('%H:%M')

        # if start.hour < 6 or start.hour > 21:
        # rows[key]["startTime"] = ''
        # if end.hour < 6 or end.hour > 22 or (end.hour == 6 and end.minute == 0):
        #     rows[key]["endTime"] = ''
        # b、开始上课前一小时之前可修改，一小时之内不可再修改。

        before = delta.days * 24 * 60 * 60 + delta.seconds
        count = before / (60 * 60)
        if count <= 1:
            rows[key]["isEdit"] = False
        else:
            rows[key]["isEdit"] = True
    num = Lesson.objects(course_id=course_id).count()
    data = {"success": True, "message": "", "rows": rows, "total": num}
    return success(data)


@ensure_csrf_cookie
@require_http_methods(['POST'])
@check_input(LessonForm, True)
def lesson_save(request, form):
    message = ''
    error = 0
    now = datetime.utcnow()
    post = request.POST

    # 获取form参数
    # startDate:开课日期 startTime:开课时间开始 endTime:开课时间结束 courseId:所属课程id
    start_date = post.get('startDate', '')
    start_time_str = post.get('startTime', '')
    end_time_str = post.get('endTime', '')
    course_id = form.cleaned_data['courseId']
    format_str = "%Y-%m-%d %H:%M:%S"

    start_time = datetime.strptime(start_date + " " + start_time_str + ":00", format_str)
    end_time = datetime.strptime(start_date + " " + end_time_str + ":00", format_str)
    start_time = get_utc_time(start_time)
    end_time = get_utc_time(end_time)

    delta = start_time - now
    before = delta.days * 24 * 60 * 60 + delta.seconds
    count = before / (60 * 60)
    _id = post.get('_id', '')
    lesson_id = post.get('id', '0')
    name = post.get('name', '')

    if _id != '':
        object_id = ObjectId(_id)
    else:
        object_id = ObjectId()
    # print(object_id)
    lesson = {}
    if count <= 1:
        message = '开课时间应该在当前时间的一小时以后'
    else:
        if _id != '':
            # 开始上课前一小时之前可修改，一小时之内不可再修改
            lesson = Lesson.objects(_id=object_id).first()
            if lesson:
                delta = lesson.start_time - now
                before = delta.days * 24 * 60 * 60 + delta.seconds
                count = before / (60 * 60)
                if count <= 1:
                    message = '开始上课前一小时之内不可再修改'
                    pass
            else:
                message = '参数有误'
        if message == '':
            is_exist = Lesson.is_exist_time(start_time, course_id, lesson_id)
            if is_exist:
                message = '同一课程的讲次在同一天时间段不能有重叠'
    if message != '':
        error = 1
    else:

        if _id != '':
            message = '修改'
        else:
            message = '添加'

        if lesson_id == '0' or not lesson:
            count = Lesson.lesson_count(course_id)
            while 1:
                count += 1
                if count > 99:
                    count_str = "-"
                elif count > 9:
                    count_str = '-0'
                else:
                    count_str = '-00'
                lesson_id = course_id + count_str + str(count)
                count_exist = Lesson.objects(lesson_id=lesson_id).count()
                if count_exist == 0:
                    break

        if lesson:
            lesson.lesson_id = lesson_id
            lesson.name = name
            lesson.start_time = start_time
            lesson.end_time = end_time
        else:
            lesson = Lesson(_id=object_id, lesson_id=lesson_id, name=name, course_id=course_id, start_time=start_time,
                            end_time=end_time)

        effect_rows = lesson.save()

        if effect_rows > 0:
            start_time_s = start_time - timedelta(days=1)
            end_time_s = end_time + timedelta(hours=2)

            meeting = {}
            if lesson:
                meeting_old = Meetings.objects(lesson_id=lesson_id).first()
                if meeting_old:
                    if meeting_old.start_time != start_time_s or meeting_old.end_time != end_time_s:
                        Meetings.del_meeting(meeting_old)
                    else:
                        meeting = meeting_old
                        meeting.name = name
            if not meeting:
                meeting = Meetings(lesson_id=lesson_id, name=name,
                                   start_time=(start_time - timedelta(days=settings.MEETINGMANAGE["beforeDays"])),
                                   end_time=(end_time + timedelta(hours=2)))
            meeting.save()
            message += '成功'
        else:
            message += '失败'
            error = 1
    data = {"success": True, "message": message, "error": error}
    return success(data)


@ensure_csrf_cookie
@require_http_methods(['POST'])
def lesson_destroy(request):
    message = ''
    success_state = False
    now = datetime.utcnow()
    post = request.POST
    _id = post.get('_id', '')
    course_id = post.get('course_id', '')

    if _id != '' and course_id != '':
        object_id = ObjectId(_id)
        lesson = Lesson.objects(_id=object_id, course_id=course_id).first()
        if lesson:
            delta = lesson.start_time - now
            before = delta.days * 24 * 60 * 60 + delta.seconds
            count = before / (60 * 60)
            if count <= 1:
                message = '离讲次开始还剩一小时内不可删除'
                pass
            if message == '':
                Lesson.del_lesson(lesson)
                # 状态删除会议
                meeting_old = Meetings.objects(lesson_id=lesson.lesson_id).first()
                if meeting_old:
                    Meetings.del_meeting(meeting_old)
                success_state = True
                message = '删除成功'
        else:
            message = '删除失败，此讲次不存在'
    else:
        message = '参数有误'

    data = {"success": success_state, "message": message}
    return success(data)


@ensure_csrf_cookie
@require_http_methods(['GET'])
def survey_list_json(request, survey_type):
    start_str = request.GET.get('start', '0')
    limit_str = request.GET.get('limit', '1')
    start = int(start_str)
    limit = int(limit_str)
    survey_type_int = int(survey_type)
    end = start + limit
    objects = SurveySettings.objects(survey_type=survey_type_int).order_by("-_id")[start:end]
    rows = objects_to_array(objects)
    for key in range(0, len(rows)):
        row = rows[key]
        if 'publishTime' in row.keys():
            if row["publishTime"] is None:
                rows[key]["state"] = '未发布'
            else:
                rows[key]["state"] = '已发布'
                if 'endTime' in row.keys():
                    if row["endTime"] is not None:
                        rows[key]["state"] = '已结束'
        else:
            rows[key]["state"] = '未发布'

    num = SurveySettings.objects(survey_type=survey_type_int).count()
    data = {"success": True, "message": "", "rows": rows, "total": num}
    return success(data)


# 查看调研结果页
@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login(url_hash='#/nc/survey_list')
def survey_show(request, survey_type, survey_id):
    page_info = ['nc', 'nc.survey_show']
    return render(request, 'nc/survey_show.tpl', {'current_page_names': page_info, 'survey_type': survey_type,
                                                  'survey_id': survey_id})


# 查看调研详情页
@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login('#/nc/survey_list')
def survey_detail(request, survey_type, survey_id):
    page_info = ['nc', 'nc.survey_detail']
    return render(request, 'nc/survey_detail.tpl', {'current_page_names': page_info, 'survey_type': survey_type,
                                                    'survey_id': survey_id})


# 查询调研问卷
@ensure_csrf_cookie
@require_http_methods(['GET'])
def survey_get(request, survey_type, survey_id):
    message = ''
    success_state = False
    survey_settings = {}
    if survey_id != '':
        _id = ObjectId(survey_id)
        objects = SurveySettings.objects(_id=_id, survey_type=survey_type).limit(1)
        if objects:
            success_state = True
            survey_settings = objects_to_array(objects)[0]
            if survey_settings["questions"]:
                survey_settings["questions"] = objects_to_array(survey_settings["questions"])
                survey_settings["questionsStr"] = data_to_json(survey_settings["questions"])

            # 获取已选择适用班级
            survey_courses_objects = SurveyCourses.objects(sid=survey_id)
            ssurvey_courses_array = objects_to_array(survey_courses_objects)
            survey_settings["surveyCourses"] = []
            survey_course_data = []
            for key in range(0, len(ssurvey_courses_array)):
                row = ssurvey_courses_array[key]
                if 'courseId' in row.keys():
                    survey_course_obs = Course.objects(course_id=row["courseId"]).limit(1)
                    if survey_course_obs:
                        survey_course = objects_to_array(survey_course_obs)[0]
                        if survey_course:
                            survey_settings["surveyCourses"].append(survey_course["name"])
                            survey_course_data.append(survey_course["id"])

            survey_settings["survey_course"] = data_to_json(survey_course_data)
        else:
            message = "问卷数据查询失败"
    else:
        message = "参数有误"
    data = {"success": success_state, "data": survey_settings, "message": message}
    return success(data)


# @ensure_csrf_cookie
@require_http_methods(['POST'])
@check_input(SurveySettingForm, True)
def survey_save(request, form):
    message = ''
    success_state = False
    post = request.POST
    # 获取form参数
    # title:调研标题 count:调研次数 surveyType:调研类型（0：课中调研，1：课后调研）questions:问卷中的问题
    title = post.get('title', '')
    count_str = post.get('count', '0')
    questions_str = post.get('questionsStr', '[]')

    count = int(count_str)
    questions = str_to_data(questions_str)

    _id = post.get('_id', '')
    if _id != '':
        object_id = ObjectId(_id)
    else:
        object_id = ObjectId()
    survey = {}

    if _id != '':
        survey = SurveySettings.objects(_id=object_id).first()
        if survey:
            if survey.publish_time is not None:
                message = '已发布的调研不能修改'
        else:
            message = '参数有误'

    if message == '':
        if _id != '':
            message = '修改'
        else:
            message = '添加'

        if survey:
            survey.title = title
            survey.count = count
            survey.questions = questions
        else:
            survey_type_str = post.get('surveyType')
            survey = SurveySettings(_id=object_id, title=title, survey_type=int(survey_type_str), count=count,
                                    questions=questions)

        effect_rows = survey.save()

        if effect_rows > 0:
            # 保存适用班级
            # 班级id
            courses_ids_str = post.get('survey_course', '')
            if courses_ids_str:
                _id = str(object_id)
                effect_rows2 = 0
                course_ids = str_to_data(courses_ids_str)
                survey_courses_ids = []
                # SurveyCourses
                for key in range(0, len(course_ids)):
                    course_id = str(course_ids[key])
                    # 是否已经存在此课程
                    survey_course_old = SurveyCourses.objects(sid=_id, course_id=course_id).limit(1)
                    if not survey_course_old:
                        # 保存
                        survey_courses_id = ObjectId()
                        survey_course = SurveyCourses(_id=survey_courses_id, sid=_id, course_id=course_id)
                        effect_rows20 = survey_course.save()
                        if effect_rows20 > 0:
                            effect_rows2 += 1
                    else:
                        survey_courses_id = str(survey_course_old[0].id)
                        effect_rows2 += 1

                    survey_courses_ids.append(survey_courses_id)

                if effect_rows2 > 0:  # 班级保存成功
                    not_survey_course = SurveyCourses.objects(course_id__nin=course_ids, sid=_id)
                    # 删除之前的班级
                    if not_survey_course:
                        not_survey_course.delete()

            success_state = True
            message += '成功'
        else:
            message += '失败'

    data = {"success": success_state, "message": message}
    return success(data)


@ensure_csrf_cookie
@require_http_methods(['POST'])
def survey_destroy(request):
    # message = ''
    success_state = False

    post = request.POST
    _id = post.get('_id', '')
    if _id != '':
        object_id = ObjectId(_id)
        lesson = SurveySettings.objects(_id=object_id).first()
        if lesson:
            lesson.delete()
            success_state = True
            message = '删除成功'
        else:
            message = '删除失败，此讲次不存在'
    else:
        message = '参数有误'

    data = {"success": success_state, "message": message}
    return success(data)


# 发布调研
@ensure_csrf_cookie
@require_http_methods(['POST'])
def survey_issue(request):
    message = ''
    success_state = False
    post = request.POST
    _id = post.get('_id', '')
    survey_type = post.get('survey_type', '')
    message2 = ''
    if _id != '' and survey_type != '':
        if survey_type == "1":
            # 课后调研类型时，查询是否存在已经发布的
            survey_old = SurveySettings.objects(publish_time__ne=None, end_time=None, survey_type=survey_type).limit(1)
            if survey_old:
                message = '请结束已经发布的调研'

        if message == "":
            object_id = ObjectId(_id)
            survey = SurveySettings.objects(_id=object_id, survey_type=survey_type).first()
            if survey:
                if survey.publish_time is not None:
                    message = '此调研已发布，请勿重复发布'
                if message == "":
                    # 用户
                    get_user = auth.get_user(request)
                    survey["publish_time"] = datetime.utcnow()
                    if get_user:
                        survey["user_name"] = get_user.first_name + get_user.last_name  # user.username

                    if survey_type == '0':  # 修改问卷调研班级表
                        survey_courses_obs = SurveyCourses.objects(sid=_id)
                        for survey_course in survey_courses_obs:
                            # 查询当前lessson的id
                            lesson = Lesson.objects(start_time__lte=survey["publish_time"],
                                                    course_id=survey_course.course_id).order_by("-start_time").first()
                            lesson_id = "0"
                            if lesson:
                                lesson_id = lesson.lesson_id
                            if lesson_id is not survey_course.current_lesson_id:
                                survey_course.current_lesson_id = lesson_id
                                # 执行修改
                                survey_course.save()
                                message2 = '执行修改'

                    row_count = survey.save()
                    if row_count > 0:
                        success_state = True
                        message = '发布成功'
            else:
                message = '发布失败，此调研不存在或已删除'

    else:
        message = '参数有误'
    data = {"success": success_state, "message": message, "message2": message2}
    return success(data)


# 结束调研
@ensure_csrf_cookie
@require_http_methods(['POST'])
def survey_end(request):
    message = ''
    success_state = False
    post = request.POST
    _id = post.get('_id', '')

    if _id != '':
        # 查询是否已经结束
        object_id = ObjectId(_id)
        survey_ob = SurveySettings.objects(_id=object_id).first()
        if survey_ob:
            if survey_ob.publish_time is not None:
                if survey_ob.end_time is not None:
                    message = '此调研已经结束'
            else:
                message = '结束调研失败，此调研未发布'
            if message == '':
                survey_ob["end_time"] = datetime.utcnow()
                row_count = survey_ob.save()
                if row_count > 0:
                    success_state = True
                    message = '结束调研成功'
        else:
            message = '结束调研失败，此调研不存在或已删除'
    else:
        message = '参数有误'
    if success_state is False and message == '':
        message = '结束调研失败'
    data = {"success": success_state, "message": message}
    return success(data)


# 查询调研问卷
@ensure_csrf_cookie
@require_http_methods(['GET'])
def survey_detail_get(request, survey_type, survey_id):
    message = ''
    success_state = False
    survey_settings = {}
    if survey_id != '':
        _id = ObjectId(survey_id)
        objects = SurveySettings.objects(_id=_id, survey_type=survey_type).limit(1)
        if objects:
            success_state = True

            survey_settings = objects_to_array(objects)[0]
            if 'publishTime' in survey_settings.keys():
                if survey_settings["publishTime"] is None:
                    survey_settings["state"] = '未发布'
                else:
                    survey_settings["state"] = '已发布'
                    if 'endTime' in survey_settings.keys():
                        if survey_settings["endTime"] is not None:
                            survey_settings["state"] = '已结束'
            else:
                survey_settings["state"] = '未发布'

            survey_settings["surveyTypeStr"] = "课中调研"
            if survey_type == '1':
                survey_settings["surveyTypeStr"] = "课后调研"
            survey_settings["questionsStr"] = ''
            if survey_settings["questions"]:
                survey_settings["questions"] = objects_to_array(survey_settings["questions"])
                for key in range(0, len(survey_settings["questions"])):
                    question = survey_settings["questions"][key]
                    options_str = ''
                    option_sc = ["A", "B", "C", "D", "E"]
                    if "option" in question.keys():
                        for i in range(0, len(question["option"])):
                            options_str += (option_sc[i] + '&nbsp;' + question["option"][i] +
                                            '&nbsp;&nbsp;&nbsp;&nbsp;')
                    survey_settings["questionsStr"] += """<div class='view_html'><p>{0}、{1}</p>
                    <p class='p_option'>{2}</p></div>""".format((key + 1), question["question"], options_str)

            # 获取已选择适用班级
            survey_courses_objects = SurveyCourses.objects(sid=survey_id)
            ssurvey_courses_array = objects_to_array(survey_courses_objects)
            survey_settings["surveyCourses"] = []

            for key in range(0, len(ssurvey_courses_array)):
                row = ssurvey_courses_array[key]
                if 'courseId' in row.keys():
                    survey_course_obs = Course.objects(course_id=row["courseId"]).limit(1)
                    if survey_course_obs:
                        survey_course = objects_to_array(survey_course_obs)[0]
                        if survey_course:
                            survey_settings["surveyCourses"].append(survey_course["name"])
        else:
            message = "问卷数据查询失败"
    else:
        message = "参数有误"
    data = {"success": success_state, "data": survey_settings, "message": message}
    return success(data)


# 查询调研结果json数据
@ensure_csrf_cookie
@require_http_methods(['GET'])
def results_list_json(request, survey_id):
    message = ''
    start_str = request.GET.get('start', '0')
    limit_str = request.GET.get('limit', '1')
    start = int(start_str)
    limit = int(limit_str)

    end = start + limit
    survey_settings = SurveySettings.objects(_id=ObjectId(survey_id)).first()
    questions = []
    if survey_settings:
        questions_array = survey_settings.questions
        for key in range(0, len(questions_array)):
            if "question" in questions_array[key].keys():
                question = questions_array[key]["question"]
                questions.append({"questions" + str(key): question})

    num = SurveyResults.objects(sid=survey_id).count()
    if num < end:
        end = num
    results_obs = SurveyResults.objects(sid=survey_id).order_by("-_id")[start:end]
    # objects = SurveySettings.objects(survey_id=ObjectId(survey_id)).first()
    rows = objects_to_array(results_obs)
    for key in range(0, len(rows)):
        row = rows[key]
        rows[key]["realName"] = Users.get_real_name(row["userName"])
        answers_array = row["answers"]
        for key2 in range(0, len(answers_array)):
            rows[key]["questions" + str(key2)] = answers_array[key2]

    num = SurveyResults.objects(sid=survey_id).count()
    if num == 0:
        message = '无数据'
        success_state = False
    else:
        success_state = True

    data = {"success": success_state, "message": message, "rows": rows, "total": num, "questions": questions}
    return success(data)


# 查询调研结果json数据，并导出xls
@ensure_csrf_cookie
@require_http_methods(['GET'])
@require_login(skip_type='self')
def results_export(request, survey_id):
    _id = ObjectId(survey_id)
    survey_settings = SurveySettings.objects(_id=_id).first()
    if survey_settings:
        import xlwt

        # 字段标题
        columns = ['userName', 'realName', 'tel', 'postTime', 'course', 'lesson', 'teacher']
        titles = ["客户", "姓名", "联系方式", "提交时间", "所在课程", "所在课程讲次", "授课老师"]

        objects = SurveyResults.objects(sid=survey_id)
        rows = objects_to_array(objects)
        questions_array = survey_settings.questions
        for key in range(0, len(questions_array)):
            if "question" in questions_array[key].keys():
                columns.append("questions" + str(key))
                titles.append(questions_array[key]["question"])

        for key in range(0, len(rows)):
            row = rows[key]
            rows[key]["realName"] = Users.get_real_name(row["userName"])
            answers_array = row["answers"]
            for key2 in range(0, len(answers_array)):
                value = answers_array[key2]
                if isinstance(value, list):
                    value2 = ''
                    for key3 in range(0, len(value)):
                        if key3 is not len(value) - 1:
                            value2 += (value[key3] + "，")
                        else:
                            value2 += value[key3]
                    rows[key]["questions" + str(key2)] = value2
                else:
                    rows[key]["questions" + str(key2)] = value

        now = get_beijing_time().strftime('%Y-%m-%d %H.%M')
        name = 'attachment; filename="%s--调研结果--%s.xls"' % (survey_settings.title, now)

        response = HttpResponse(content_type='application/ms-excel')
        response['Content-Disposition'] = name.encode('cp936')

        wb = xlwt.Workbook()
        ws = wb.add_sheet('调研结果')
        row_x = 0

        # 冻结标题行
        ws.set_panes_frozen(True)
        ws.set_horz_split_pos(row_x + 1)

        head_style = xlwt.easyxf('font: bold on; align: vert centre, horiz center', num_format_str='@')

        for col, item in enumerate(titles):
            ws.write(row_x, col, item, head_style)
        row_x += 1
        style = xlwt.easyxf(num_format_str='@')
        for row in rows:
            array = []
            for column in columns:
                value = ''
                if column in row.keys():
                    value = row[column]
                array.append(value)

            for col, item in enumerate(array):
                ws.write(row_x, col, item, style)
            row_x += 1
        wb.save(response)
        return response
    return fail('参数错误')


# 查询调研结果json数据，并导出(已不使用)
@ensure_csrf_cookie
@require_http_methods(['GET'])
def results_export_csv(request, survey_id):
    from django.http import HttpResponse
    import csv
    import sys

    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="survey_results.csv"'
    writer = csv.writer(response)

    # 字段标题
    columns = ['userName', 'tel', 'postTime', 'course', 'lesson', 'teacher']
    titles = ["客户", "联系方式", "提交时间", "所在课程", "所在课程讲次", "授课老师"]
    objects = SurveyResults.objects(sid=survey_id)
    rows = objects_to_array(objects)
    _id = ObjectId(survey_id)
    survey_settings = SurveySettings.objects(_id=_id).first()
    if survey_settings:
        questions_array = survey_settings.questions
        for key in range(0, len(questions_array)):
            if "question" in questions_array[key].keys():
                columns.append("questions" + str(key))
                titles.append(questions_array[key]["question"])

    for key in range(0, len(rows)):
        row = rows[key]
        answers_array = row["answers"]
        for key2 in range(0, len(answers_array)):
            value = answers_array[key2]
            if isinstance(value, list):
                value2 = ''
                for key3 in range(0, len(value)):
                    if key3 is not len(value) - 1:
                        value2 += (value[key3] + "，")
                    else:
                        value2 += value[key3]
                rows[key]["questions" + str(key2)] = value2
            else:
                rows[key]["questions" + str(key2)] = value

    reload(sys)
    sys.setdefaultencoding("gb2312")
    writer.writerow(titles)
    for row in rows:
        array = []
        for column in columns:
            value = ''
            if column in row.keys():
                value = row[column]
            array.append(value)
        writer.writerow(array)

    return response


@ensure_csrf_cookie
@require_http_methods(['GET'])
def test(request):
    from bson.son import SON
    from django.http import HttpResponse
    from mongoengine.common import _import_class

    if Meetings.objects(lesson_id='123'):
        Meetings.objects(lesson_id='123').delete()

    now = datetime.utcnow()
    object_id = ObjectId()
    meeting = Meetings(_id=object_id, name='测试', platform_meeting_id=None, lesson_id='123')
    self = meeting
    fields = None
    if not fields:
        fields = []

    data = SON()
    data["_id"] = None
    data['_cls'] = self._class_name
    EmbeddedDocumentField = _import_class("EmbeddedDocumentField")
    # only root fields ['test1.a', 'test2'] => ['test1', 'test2']
    root_fields = set([f.split('.')[0] for f in fields])

    for field_name in self:
        if root_fields and field_name not in root_fields:
            continue
        print(field_name)

    my_s = meeting.to_mongo()
    # print(my_s)
    # print(meeting._fields)
    meeting.save(clean=False, validate=False)
    # //rows = objects_to_array(meeting)
    # //str2 = str+"<br/>"+meeting.to_mongo
    # meeting.validate(clean=False)
    return HttpResponse(my_s)

    # t_str = '2015-06-16 06:00:00'
    # start = datetime.strptime(t_str, '%Y-%m-%d %H:%M:%S')  # "2015-04-07T19:11:21"
    # delta = now-start
    # before = delta.days * 24 * 60 * 60 + delta.seconds
    # count = before / (60 * 60)
    get_user = auth.get_user(request)
    return success(get_user)
    return success(time.ctime())
    data = {"totalCount": "100", "topics": [
        {"title": "XTemplate with in EditorGridPanel", "threadid": "133690", "username": "kpr@emco", "userid": "272497",
         "dateline": "1305604761", "postid": "602876", "forumtitle": "Ext 3.x: Help", "forumid": "40",
         "replycount": "2", "lastpost": "1305857807", "lastposter": "kpr@emco",
         "excerpt": "Hihen i render the EditorGri..."},
        {"title": "IFrame error  &quot;_flyweights is undefined&quot;", "threadid": "133571", "username": "Daz",
         "userid": "52119", "dateline": "1305533577", "postid": "602456", "forumtitle": "Ext 3.x: Help",
         "forumid": "40", "replycount": "1", "lastpost": "1305857313", "lastposter": "Daz",
         "excerpt": "For Ext 3.3.0 usingYet, this ..."}]}
    return success(data)
