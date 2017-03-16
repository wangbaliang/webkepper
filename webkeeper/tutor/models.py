# -*- coding: utf-8 -*-
import json
import thriftpy

from django.conf import settings
from django.db import models

from libs.thrift_helper import ThriftClient

tutor_thrift = thriftpy.load('thriftfiles/tutor.thrift', 'tutor_thrift',
                             include_dirs=['thriftfiles'])
upland_thrift = thriftpy.load('thriftfiles/upland.thrift', 'upland_thrift',
                              include_dirs=['thriftfiles'])
from tutor_thrift import (
    StudentInClassDef,
    ClassDef,
    ClassExchangeDef,
    common as thrift_common,
)


class SeasonService(object):

    @classmethod
    def _get_thrift_client(cls):
        return ThriftClient(
            tutor_thrift.SeasonService,
            settings.THRIFT_SERVICES['tutor_service'],
            'season_service'
        )

    @classmethod
    def get_season_list(cls):
        client = cls._get_thrift_client()
        return client.getAll()

    @classmethod
    def _trans_season(cls, data):
        season = tutor_thrift.SeasonDef()
        season.year = data['year']
        season.seasonType = data['season_type']
        season.startDay = data['start_day']
        season.endDay = data['end_day']
        season.exceptDays = data['except_days']
        return season

    @classmethod
    def add_season(cls, data):
        client = cls._get_thrift_client()
        season = cls._trans_season(data)
        return client.addSeason(season)

    @classmethod
    def update_season(cls, data):
        client = cls._get_thrift_client()
        season = cls._trans_season(data)
        season.id = data['id']
        return client.updateSeason(season)

    @classmethod
    def delete_season(cls, season_id):
        client = cls._get_thrift_client()
        return client.deleteSeason(season_id)


class PeriodService(object):

    @classmethod
    def _get_thrift_client(cls):
        return ThriftClient(
            tutor_thrift.PeriodService,
            settings.THRIFT_SERVICES['tutor_service'],
            'period_service'
        )

    @classmethod
    def get_period_list(cls, limit, offset):
        client = cls._get_thrift_client()
        data = client.getAll(limit, offset)
        total = client.getAllCount()
        return data, total

    @classmethod
    def add(cls, data):
        client = cls._get_thrift_client()
        season = tutor_thrift.PeriodDef(**data)
        return client.add(season)

    @classmethod
    def update(cls, data):
        client = cls._get_thrift_client()
        season = tutor_thrift.PeriodDef(**data)
        return client.update(season)

    @classmethod
    def delete(cls, period_id):
        client = cls._get_thrift_client()
        return client.remove(period_id)

    @classmethod
    def get_by_season_and_grade_type(cls, season_id, grade_type):
        client = cls._get_thrift_client()
        return client.getBySeasonAndGradeType(season_id, grade_type)


class ClassTemplateService(object):

    @classmethod
    def _get_thrift_client(cls):
        return ThriftClient(
            tutor_thrift.ClassTemplateService,
            settings.THRIFT_SERVICES['tutor_service'],
            'class_template_service'
        )

    @classmethod
    def filter_reservation_list(cls, limit, offset, **kwargs):
        client = cls._get_thrift_client()
        data = client.getFilteredReservationData(limit, offset)
        total = client.getReservationDataCount()
        return data, total

    @classmethod
    def get_class_template_list(cls, limit, offset):
        client = cls._get_thrift_client()
        data = client.getAll(limit, offset)
        total = client.getAllCount()
        return data, total

    @classmethod
    def get_class_template_enrollment_schedule(cls, limit, offset):
        client = cls._get_thrift_client()
        data = client.getEnrollmentSchedule()
        total = len(data)
        return data, total

    @classmethod
    def filter_class_templates(cls, limit, offset, **kwargs):
        season_id = kwargs.get('season_id', 0)
        subject_id = kwargs.get('subject_id', 0)
        grade = kwargs.get('grade', 0)
        period_id = kwargs.get('period_id', 0)
        client = cls._get_thrift_client()
        data = client.getFilteredData(
            limit, offset, season_id, subject_id, grade, period_id)
        total = client.getFilteredDataCount(
            season_id, subject_id, grade, period_id)
        return data, total

    @classmethod
    def add(cls, data):
        client = cls._get_thrift_client()
        season = tutor_thrift.ClassTemplateDef(**data)
        return client.add(season)

    @classmethod
    def update(cls, data):
        client = cls._get_thrift_client()
        season = tutor_thrift.ClassTemplateDef(**data)
        return client.update(season)

    @classmethod
    def delete(cls, class_template_id):
        client = cls._get_thrift_client()
        return client.remove(class_template_id)


class CoachService(object):

    @classmethod
    def _get_thrift_client(cls):
        return ThriftClient(
            tutor_thrift.CoachService,
            settings.THRIFT_SERVICES['tutor_service'],
            'coach_service'
        )

    @classmethod
    def get_coach_list(cls, limit, offset):
        client = cls._get_thrift_client()
        data = client.getAll(limit, offset)
        total = client.getAllCount()
        return data, total

    @classmethod
    def get_coach_period_list(cls, userName):
        client = cls._get_thrift_client()
        data = client.getAllUsablePeriod(userName)
        return data

    @classmethod
    def filter_coaches(cls, limit, offset, **kwargs):
        client = cls._get_thrift_client()
        condition = json.dumps(kwargs)
        data = client.getFilteredCoaches(limit, offset, condition)
        total = client.getFilteredCoachesCount(condition)
        return data, total

    @classmethod
    def check_import_coach_names(cls, coach_names):
        client = cls._get_thrift_client()
        return client.importCheck(coach_names)

    @classmethod
    def import_coaches(cls, coach_names):
        client = cls._get_thrift_client()
        return client.importCoaches(coach_names)

    @classmethod
    def get_coach_class_ids(cls, coach_name):
        client = cls._get_thrift_client()
        return client.getCoachClassIds(coach_name)

    @classmethod
    def dismiss_coach(cls, coach_name, op_admin, remark):
        client = cls._get_thrift_client()
        return client.dismissCoach(coach_name, op_admin, remark)

    @classmethod
    def set_coach_retraining(cls, coach_name, op_admin, remark):
        client = cls._get_thrift_client()
        return client.setCoachRetraining(coach_name, op_admin, remark)

    @classmethod
    def cancel_coach_retraining(cls, coach_name, op_admin, remark):
        client = cls._get_thrift_client()
        return client.cancelCoachRetraining(coach_name, op_admin, remark)

    @classmethod
    def set_coach_trial(cls, coach_name, op_admin, remark):
        client = cls._get_thrift_client()
        return client.setCoachTrial(coach_name, op_admin, remark)

    @classmethod
    def set_coach_positive(cls, coach_name, op_admin, remark):
        client = cls._get_thrift_client()
        return client.setCoachPositive(coach_name, op_admin, remark)

    @classmethod
    def fire_coach_info_by_name(cls, user_name):
        client = cls._get_thrift_client()
        data = client.getFiredCoachInfoByUserName(user_name)
        return data, 0

    # 以下为教练招培
    @classmethod
    def filter_hiring_coaches(cls, limit, offset, **kwargs):
        client = cls._get_thrift_client()
        condition = json.dumps(kwargs)
        data = client.getFilteredHiringCoaches(limit, offset, condition)
        total = client.getFilteredHiringCoachesCount(condition)
        return data, total

    @classmethod
    def check_import_hiring_coach_names(cls, coach_names):
        client = cls._get_thrift_client()
        return client.importHiringCheck(coach_names)

    @classmethod
    def import_hiring_coaches(cls, coach_names):
        client = cls._get_thrift_client()
        return client.importHiringCoaches(coach_names)

    @classmethod
    def set_coach_reserve(cls, coach_name, op_admin, remark):
        client = cls._get_thrift_client()
        return client.setCoachReserve(coach_name, op_admin, remark)

    @classmethod
    def set_coach_class_num(cls, coach_name, coach_rank):
        client = cls._get_thrift_client()
        return client.setCoachClassNum(coach_name, coach_rank)


class DistrictService(object):

    @classmethod
    def _get_thrift_client(cls):
        return ThriftClient(
            upland_thrift.AreaService,
            settings.THRIFT_SERVICES['upland_service'],
            'area_service'
        )

    @classmethod
    def get_all_area_data(cls):
        client = cls._get_thrift_client()
        result = json.loads(client.getAllDistrictData())
        return result['area']


class StudentService(object):

    @classmethod
    def get_class_list(cls, user_name):
        client = cls._get_thrift_client()
        data = client.getClassList(user_name)
        return data

    @classmethod
    def _get_thrift_client(cls):
        return ThriftClient(
            tutor_thrift.StudentService,
            settings.THRIFT_SERVICES['tutor_service'],
            'student_service'
        )

    @classmethod
    def __get_upland_service_client(cls):
        return ThriftClient(
            upland_thrift.AreaService,
            settings.THRIFT_SERVICES['upland_service'],
            'area_service'
        )

    @classmethod
    def get_student_list(cls, limit, offset):
        client = cls._get_thrift_client()
        data = client.getAll(limit, offset)
        total = client.getAllCount()
        return data, total

    @classmethod
    def filter_students(cls, limit, offset, **kwargs):
        client = cls._get_thrift_client()
        condition = json.dumps(kwargs)
        data = client.getFilteredStudents(limit, offset, condition)
        total = client.getFilteredStudentsCount(condition)
        return data, total

    @classmethod
    def get_enlist_list(cls, userName):
        client = cls._get_thrift_client()
        data = client.getEnlistResult(userName)
        return data


class ClassAdminService(object):

    @classmethod
    def _get_thrift_client(cls):
        return ThriftClient(
            tutor_thrift.ClassAdminService,
            settings.THRIFT_SERVICES['tutor_service'],
            'class_admin_service'
        )

    @classmethod
    def get_class_create_list(cls, limit, offset):
        client = cls._get_thrift_client()
        data = client.getAllClassCreateTasks(limit, offset)
        total = client.getAllClassCreateTaskCount()
        return data, total

    @classmethod
    def get_task_invite(cls, task_id):
        client = cls._get_thrift_client()
        data = client.getClassCreateTaskCoachInviteInfo(task_id)
        return data

    @classmethod
    def get_task_apply_students(cls, task_id):
        client = cls._get_thrift_client()
        data = client.getApplyStudentInfo(task_id)
        return data

    @classmethod
    def invite_coach(cls, task_id, coach_name):
        client = cls._get_thrift_client()
        return client.inviteCoach(task_id, coach_name)

    @classmethod
    def cancel_invite(cls, task_id, coach_name):
        client = cls._get_thrift_client()
        return client.cancelInvite(task_id, coach_name)

    @classmethod
    def exchange_coach(cls, class_id, new_coach_name, reason_type, remark):
        client = cls._get_thrift_client()
        return client.startChangeClassCoach(class_id, new_coach_name, reason_type, remark)

    @classmethod
    def temp_replace_coach(cls, class_id, new_coach_name, days, remark):
        client = cls._get_thrift_client()
        return client.startTemporarySubstituteCoach(class_id, new_coach_name, days, remark)

    @classmethod
    def send_notification(cls, class_id, notification, target):
        """
        发送通知
        """
        client = cls._get_thrift_client()
        return client.sendNotification(class_id, notification, target)

    @classmethod
    def modify_student_to_another_class(
        cls, student_name, origin_class_id, target_class_id, op_admin, remark):
        """
        调班
        """
        client = cls._get_thrift_client()
        return client.modifyStudentToAnotherClass(student_name,
                                                origin_class_id,
                                                target_class_id,
                                                op_admin,
                                                remark)

    @classmethod
    def close_class(cls, class_id):
        """
        关闭班级
        """
        client = cls._get_thrift_client()
        return client.closeClass(class_id)


class ClassService(object):

    @classmethod
    def _get_thrift_client(cls):
        return ThriftClient(
            tutor_thrift.ClassService,
            settings.THRIFT_SERVICES['tutor_service'],
            'class_service'
        )

    @classmethod
    def get_class_list(cls, limit, offset):
        client = cls._get_thrift_client()
        data = client.getAll(limit, offset)
        total = client.getAllCount()
        return data, total

    @classmethod
    def get_class_by_id(cls, class_id):
        client = cls._get_thrift_client()
        data = client.getClassById(class_id)
        return data

    @classmethod
    def filter_class(cls, limit, offset, **kwargs):
        client = cls._get_thrift_client()
        condition = json.dumps(kwargs)
        data = client.getFilteredClass(limit, offset, condition)
        total = client.getFilteredClassCount(condition)
        return data, total

    @classmethod
    def get_students_in_this_class(cls, class_id):
        client = cls._get_thrift_client()
        data = client.getStudentInfoInClassById(class_id)
        return data

    @staticmethod
    def _trans_data_to_class_exchange_def(item):
        classExchange = ClassExchangeDef()
        classExchange.oldClassID = item['oldClassID']
        classExchange.newClassID = item['newClassID']
        classExchange.modified = True
        return classExchange

    @classmethod
    def modify_class_for_student(cls, student_id, change_list):
        client = cls._get_thrift_client()
        change_list_arr = [ClassService._trans_data_to_class_exchange_def(item) for item in change_list]
        data = client.modifyStudentToAnotherClass(student_id, change_list_arr)
        return data

    @classmethod
    def get_temporary_substitute_list(cls, limit, offset, **kwargs):
        client = cls._get_thrift_client()
        condition = json.dumps(kwargs)
        data = client.getFilteredTemporaryInfo(limit, offset, condition)
        total = client.getFilteredTemporaryInfoCount(condition)
        return data, total

    @classmethod
    def get_change_class_coach_list(cls, limit, offset, **kwargs):
        """
        教练更换状态监控
        """
        client = cls._get_thrift_client()
        condition = json.dumps(kwargs)
        data = client.getChangeClassCoachStatus(limit, offset, condition)
        total = client.getChangeClassCoachStatusCount(condition)
        return data, total

    @classmethod
    def get_rank_class_num(cls):
        """
        获取带班数
        """
        client = cls._get_thrift_client()
        return client.getRankClassNum()

    @classmethod
    def update_rank_class_num(cls, data):
        client = cls._get_thrift_client()
        return client.updateRankClassNum(data)


class MonitorService(object):

    @classmethod
    def _get_thrift_client(cls):
        return ThriftClient(
            tutor_thrift.MonitorService,
            settings.THRIFT_SERVICES['tutor_service'],
            'monitor_service'
        )

    @classmethod
    def filter_coach_class(cls, limit, offset, **kwargs):
        client = cls._get_thrift_client()
        condition = json.dumps(kwargs)
        data = client.filterCoachClass(limit, offset, condition)
        total = client.filterCoachClassCount(condition)
        return data, total

    @classmethod
    def filter_student_class(cls, limit, offset, **kwargs):
        client = cls._get_thrift_client()
        condition = json.dumps(kwargs)
        data = client.filterStudentClass(limit, offset, condition)
        total = client.filterStudentClassCount(condition)
        return data, total

    @classmethod
    def filter_unusual_coach_class(cls, limit, offset, **kwargs):
        client = cls._get_thrift_client()
        condition = json.dumps(kwargs)
        data = client.filterUnusualCoach(limit, offset, condition)
        total = client.filterUnusualCoachCount(condition)
        return data, total

    @classmethod
    def filter_unusual_student_class(cls, limit, offset, **kwargs):
        client = cls._get_thrift_client()
        condition = json.dumps(kwargs)
        data = client.filterUnusualStudent(limit, offset, condition)
        total = client.filterUnusualStudentCount(condition)
        return data, total
