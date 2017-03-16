# -*- coding: utf-8 -*-
from mongoengine import Q, Document, StringField, IntField, DateTimeField, \
    ListField, ObjectIdField, BooleanField, DictField, ReferenceField
from datetime import datetime
import time
from bson.objectid import ObjectId

# Create your models here.
#     ne – 不相等
#     lt – 小于
#     lte – 小于等于
#     gt – 大于
#     gte – 大于等于
#     not – 取反
#     in – 值在列表中
#     nin – 值不在列表中
#     mod – 取模
#     all – 与列表的值相同
#     size – 数组的大小
#     exists – 字段的值存在
#     Document.objects((Q(country='uk') & Q(age__gte=18)) | Q(age__gte=20))  - 多个查询条件进行 &(与) 和 |(或) 操作


class Course(Document):
    _id = ObjectIdField(required=True, primary_key=True)
    course_id = StringField(required=True, db_field='id')
    name = StringField(required=True)
    status = IntField(required=True, default=0)
    begin_day = DateTimeField(required=True, db_field='beginDay')
    end_day = DateTimeField(required=True, db_field='endDay')
    subject = IntField(required=False)
    grade = IntField(required=True)
    type = IntField(required=True, default=0)
    teachers = ListField(StringField())
    students = ListField(StringField())
    lessons = ListField(StringField())
    insert_time = DateTimeField(required=True, db_field='insertTime')
    v = IntField(required=False, db_field='__v')
    meta = {
        'collection': 'courses'
    }


# 讲次
class Lesson(Document):
    _id = ObjectIdField(required=True, primary_key=True, default=ObjectId)
    lesson_id = StringField(required=True, db_field='id')
    course_id = StringField(required=True, db_field='courseId')
    name = StringField(required=True)
    # 备课状态：0-未开始，1-进行中，2-已完成
    ready_status = IntField(required=True, default=0, db_field='readyStatus')
    start_time = DateTimeField(required=True, db_field='startTime')
    end_time = DateTimeField(required=True, db_field='endTime')
    is_end = BooleanField(required=True, default=False, db_field='isEnd')
    teacher = StringField(required=False)
    join_teachers = ListField(StringField(), db_field='joinTeachers', default=[])
    join_students = ListField(StringField(), db_field='joinStudents', default=[])
    sections = ListField(StringField())
    used_steps = ListField(StringField(), required=False, db_field='usedSteps',)
    v = IntField(required=False, db_field='__v')
    v2 = IntField(required=False, db_field='_v')
    insert_time = DateTimeField(required=True, default=datetime.utcnow, db_field='insertTime')
    meta = {
        'collection': 'lessons',
        'ordering': ['startTime']
    }

    @classmethod
    def del_lesson(cls, lesson):
        lesson.course_id += '-del'
        result = lesson.save()
        return result

    # 查询课程的讲次总数
    @classmethod
    def lesson_count(cls, course_id):
        course_id_del = course_id + '-del'
        count = cls.objects(Q(course_id=course_id) | Q(course_id=course_id_del)).count()
        return count

    # 检测时间是否重复
    @classmethod
    def is_exist_time(cls, start_time, course_id, lesson_id=''):
        count = cls.objects(course_id=course_id, start_time__lte=start_time,
                            end_time__gte=start_time, lesson_id__ne=lesson_id).count()

        if count > 0:
            result = True
        else:
            result = False
        return result


# 会议
class Meetings(Document):
    _id = ObjectIdField(required=True, primary_key=True, default=ObjectId)
    lesson_id = StringField(required=True, db_field='lessonId')  # 对应讲座id
    name = StringField(required=True)
    # 会议平台类型：0-自己平台，1-好视通，2-展视
    platform_type = IntField(required=False, default='1', db_field='platformType')
    # 对应平台会议id
    platform_meeting_id = StringField(required=False, default='', null=True, db_field='platformMeetingId')
    auth_password = DictField(required=False, db_field='authPassword')  # 授权密码
    status = IntField(required=True, default=0)  # 会议状态：0-未创建，1-已创建，2-已删除
    start_time = DateTimeField(required=True, db_field='startTime')
    end_time = DateTimeField(required=True, db_field='endTime')
    is_end = BooleanField(required=True, default=False, db_field='isEnd')
    v = IntField(required=False, default='0', db_field='__v')
    insert_time = DateTimeField(required=True, default=datetime.now, db_field='insertTime')
    url = DictField(required=False)  # // 会议url地址，如果是通过url方式的会有此属性，否则为null，其结构为：
    meta = {
        'collection': 'meetings',
        'ordering': 'start_time'
    }

    @classmethod
    def del_meeting(cls, meeting):
        meeting.is_end = True
        meeting.lesson_id += str(time.time())
        meeting.save()
        return meeting


# 问卷调研设定表
class SurveySettings(Document):
    _id = ObjectIdField(required=True, primary_key=True, default=ObjectId)
    title = StringField(required=True)  # 调研标题
    user_name = StringField(required=True, db_field='userName', default='')  # 发布人
    publish_time = DateTimeField(required=False, db_field='publishTime')  # 发布时间
    end_time = DateTimeField(required=False, db_field='endTime')  # 结束时间
    count = IntField(required=True, default=0)  # 调研次数
    survey_type = IntField(required=True, db_field='surveyType')  # 调研类型（0：课中调研，1：课后调研）
    questions = ListField(DictField())  # 问卷中的问题[1]
    v = IntField(required=False, db_field='__v')
    meta = {
        'collection': 'surveysettings',
        'ordering': '_id'
    }


# 问卷调研班级表
class SurveyCourses(Document):
    _id = ObjectIdField(required=True, primary_key=True, default=ObjectId)
    sid = StringField(required=True)  # 调研问卷ID
    course_id = StringField(required=True, db_field='courseId')  # 课程id
    current_lesson_id = StringField(required=True, db_field='currentLessonId', default='0')  # 当前的讲次
    v = IntField(required=False, db_field='__v')
    meta = {
        'collection': 'surveycourses'
    }


# 问卷调研结果表
class SurveyResults(Document):
    _id = ObjectIdField(required=True, primary_key=True, default=ObjectId)  # 主键
    sid = StringField(required=True)  # 对应的调研问卷ID
    user_name = StringField(required=True, db_field='userName')  # 学生
    tel = StringField()  # 联系方式
    post_time = DateTimeField(required=True, db_field='postTime')  # 学生提交问卷时间
    course = StringField(required=True)  # 所在课程
    lesson = StringField(required=True)  # 课程讲次
    teacher = StringField(required=True)  # 授课老师
    answers = ListField(ListField(StringField()))  # 答案
    v = IntField(required=False, db_field='__v')
    meta = {
        'collection': 'surveyresults'
    }


# 问卷调研结果表
class Users(Document):
    _id = ObjectIdField(required=True, primary_key=True, default=ObjectId)  # 主键
    name = StringField(required=True)  # 用户id
    real_name = StringField(required=False, db_field='realName')  # 姓名
    type = IntField()  # 用户类型：0-学生，1-老师
    insert_time = DateTimeField(required=True, db_field='insertTime')  # 创建时间
    v = IntField(required=False, db_field='__v')

    @classmethod
    def get_real_name(cls, name):
        real_name = ''
        users = cls.objects(name=name).first()
        if users:
            real_name = users.real_name

        return real_name
