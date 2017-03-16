# 教练伴学服务定义文件

include "common.thrift"

namespace py etthrift.tutor
namespace php EtThrift.Tutor

struct PeriodDef {
    1: required i32 id,
    2: required i32 seasonId,
    3: required byte gradeType,
    4: required i16 startTime,
    5: required i16 endTime
}

struct SeasonDef {
    1: required i32 id,
    2: required i16 year,
    3: required byte seasonType,
    4: required string startDay,
    5: required string endDay,
    6: optional set<string> exceptDays,
    7: optional byte status
}

service SeasonService {
    void ping(),

    list<SeasonDef> getAll()
        throws (1:common.ServerError se),

    i32 addSeason(1:required SeasonDef season)
        throws (1:common.ServerError se),

    bool updateSeason(1:required SeasonDef season)
        throws (1:common.ServerError se),

    bool deleteSeason(1:required i32 seasonId)
        throws (1:common.ServerError se)
}

service PeriodService {
    void ping(),

    list<PeriodDef> getAll(1:required i32 limit, 2:required i32 offset)
        throws (1:common.ServerError se),

    i32 getAllCount()
        throws (1:common.ServerError se),

    list<PeriodDef> getBySeasonAndGradeType(1:required i32 seasonId, 2:required i32 gradeType)
        throws (1:common.ServerError se),

    i32 add(1:required PeriodDef period)
        throws (1:common.ServerError se),

    bool update(1:required PeriodDef period)
        throws (1:common.ServerError se),

    bool remove(1:required i32 periodId)
        throws (1:common.ServerError se)
}

struct ClassTemplateDef {
    1: required i32 id,
    2: required i32 seasonId,
    3: required i32 subjectId,
    4: required i16 grade,
    5: optional i32 periodId,
    6: optional i16 cycleDay,
    7: optional i16 startTime,
    8: optional i16 endTime,
    9: optional i16 maxClassNum,
    10: optional i16 maxStudentNum
}

struct ReservationTemplateDef{
    1: required i32 id,
    2: required i32 seasonId,
    3: required i32 periodId,
    4: required i32 subjectId,
    5: required i16 grade,
    6: required i16 cycleDay,
    7: required i16 startTime,
    8: required i16 endTime,
    9: required i16 maxClassNum,
    10: required i16 maxStudentNum,
    11: required i16 maxStudentInClass,
    12: required i32 minNeededCoachNumber,
    13: required i32 usableCoachNumber,
    14: required i32 allotStudentNumber,
    15: required i32 unallotStudentNumber,
    16: required i32 allStudentNumber
}

struct EnrollmentScheduleDef{
    1: required i32 templateId,
    2: required i32 seasonId,
    3: required i32 periodId,
    4: required i32 subjectId,
    5: required i16 grade,
    6: required i16 cycleDay,
    7: required i16 startTime,
    8: required i16 endTime,
    9: required i16 maxClassNum,
    10: required i16 maxStudentNum,
    11: required i32 totalNumber,  # 招生名额
    12: required i32 usedNumber,  # 占用名额报名
    13: required i32 currentClassNumber,  # 报名本次课的学员
    14: required i32 totalRestNumber,  # 剩余名额
    15: required i32 currentRestNumber,  # 本次课剩余名额
    16: required i32 lastClassContinueNumber,  # 上次课需续约数
    17: required i32 lastClassUnContinueNumber,  # 上次课未续约数
    18: required i32 currentContinueNumber,  # 需要在本次课续约数
    19: required i32 lastClassNewNumber,  # 上次课新约课总人数
    20: required i32 lastWeekTotalNumber  # 上周新约课总人数
}

service ClassTemplateService {
    void ping(),

    list<ClassTemplateDef> getAll(1:required i32 limit, 2:required i32 offset)
        throws (1:common.ServerError se),

    list<ReservationTemplateDef>getFilteredReservationData(
        1:required i32 limit,
        2:required i32 offset
    )
        throws (1:common.ServerError se),

    i32 getReservationDataCount()
        throws (1:common.ServerError se),


    i32 getAllCount()
        throws (1:common.ServerError se),

    list<ClassTemplateDef> getFilteredData(
        1:required i32 limit,
        2:required i32 offset,
        3:required i32 seasonId,
        4:required i32 subjectId,
        5:required i16 grade,
        6:required i32 periodId
    )
        throws (1:common.ServerError se),

    list<EnrollmentScheduleDef> getEnrollmentSchedule(
        1:required i32 limit,
        2:required i32 offset
    ) throws (1:common.ServerError se),

    i32 getFilteredDataCount(
        1:required i32 seasonId,
        2:required i32 subjectId,
        3:required i16 grade,
        4:required i32 periodId
    )
        throws (1:common.ServerError se),

    i32 add(1:required ClassTemplateDef classTemplate)
        throws (1:common.ServerError se),

    bool update(1:required ClassTemplateDef classTemplate)
        throws (1:common.ServerError se),

    bool remove(1:required i32 classTemplateId)
        throws (1:common.ServerError se)
}

struct CoachDef {
    1: required string userName,
    2: required string realName,
    3: required string areaCode,
    4: required string schoolName,
    5: required byte gradeType,
    6: required i32 subjectId,
    7: required string phone,
    8: required string qq,
    9: required i16 jobStatus,
    10: required i16 jobStage,
    11: required byte isForbidCity,
    12: required i16 rank,
    13: optional string areaDisplay
}


struct CoachImportCheckResultDef {
    1: required list<string> imported,
    2: required list<string> notExists,
    3: required list<string> notTeacher
}
struct CoachAvailableTimeDef {
    1: required i32 id,
    2: required string coach,
    3: required i32 periodId,
    4: required i32 seasonId,
    5: required i16 cycleDay,
    6: required i16 startTime,
    7: required i16 endTime,
    8: required string startDay,
    9: required string endDay,
    10: required bool isUsed
}

struct FiredInfoDef{
    1: required string firedDate,
    2: required string firedReason,
    3: required string operator,
    4: required i16 operateType,
}

struct CoachAvailableTimeDef {
    1: required i32 id,
    2: required string coach,
    3: required i32 periodId,
    4: required i32 seasonId,
    5: required i16 cycleDay,
    6: required i16 startTime,
    7: required i16 endTime,
    8: required string startDay,
    9: required string endDay,
    10: required bool isUsed
}

struct CoachHiringDef {
    1: required string userName,
    2: required string realName,
    3: required string areaCode,
    4: required string schoolName,
    5: required byte gradeType,
    6: required i32 subjectId,
    7: required string phone,
    8: required string qq,
    9: optional string areaDisplay
}

service CoachService {

    list<FiredInfoDef> getFiredCoachInfoByUserName(1:required string userName)
        throws (1:common.ServerError se),

    list<CoachAvailableTimeDef> getAllUsablePeriod(1:required string userName)
        throws (1:common.ServerError se),


    list<CoachDef> getAll(1:required i32 limit, 2:required i32 offset)
        throws (1:common.ServerError se),

    list<CoachDef> getFilteredCoaches(
        1:required i32 limit,
        2:required i32 offset,
        3:required string condition)
        throws (1:common.ServerError se),

    i32 getFilteredCoachesCount(
        1:required string condition)
        throws (1:common.ServerError se),

    i32 getAllCount()
        throws (1:common.ServerError se),

    CoachImportCheckResultDef importCheck(
        1:required list<string> coachNames)
        throws (1:common.ServerError se),

    bool importCoaches(
        1:required list<string> coachNames)
        throws (1:common.ServerError se),

    list<i32> getCoachClassIds(
        1:required string coachName)
        throws (1:common.ServerError se),

    bool dismissCoach(
        1:required string coachName,
        2:required string opAdmin,
        3:required string remark)
        throws (1:common.ServerError se),

    bool setCoachRetraining(
        1:required string coachName,
        2:required string opAdmin,
        3:required string remark)
        throws (1:common.ServerError se),

    bool setCoachTrial(
        1:required string coachName,
        2:required string opAdmin,
        3:required string remark)
        throws (1:common.ServerError se),

    bool setCoachPositive(
        1:required string coachName,
        2:required string opAdmin,
        3:required string remark)
        throws (1:common.ServerError se),

    bool cancelCoachRetraining(
        1:required string coachName,
        2:required string opAdmin,
        3:required string remark)
        throws (1:common.ServerError se),

    list<CoachAvailableTimeDef> getCoachAvailableTime(
        1:required string coachName)
        throws (1:common.ServerError se),

    # 以下为教练招培
    list<CoachHiringDef> getFilteredHiringCoaches(
        1:required i32 limit,
        2:required i32 offset,
        3:required string condition)
        throws (1:common.ServerError se),

    i32 getFilteredHiringCoachesCount(
        1:required string condition)
        throws (1:common.ServerError se),

    CoachImportCheckResultDef importHiringCheck(
        1:required list<string> coachNames)
        throws (1:common.ServerError se),

    bool importHiringCoaches(1:required list<string> coachNames)
        throws (1:common.ServerError se),

    bool setCoachReserve(
        1:required string coachName,
        2:required string opAdmin,
        3:required string remark)
        throws (1:common.ServerError se),

    # 以下为教练招培
    list<CoachHiringDef> getFilteredHiringCoaches(
        1:required i32 limit,
        2:required i32 offset,
        3:required string condition)
        throws (1:common.ServerError se),

    i32 getFilteredHiringCoachesCount(
        1:required string condition)
        throws (1:common.ServerError se),

    CoachImportCheckResultDef importHiringCheck(
        1:required list<string> coachNames)
        throws (1:common.ServerError se),

    bool importHiringCoaches(1:required list<string> coachNames)
        throws (1:common.ServerError se),

    bool setCoachClassNum(
        1:required string coachName,
        2:required i16 coachRank)
        throws (1:common.ServerError se),

    void ping()
}

struct StudentDef {
    1: required string userName,
    2: required string realName,
    3: required string areaCode,
    4: required string schoolName,
    5: required i16 grade,
    6: required string phone,
    7: required string qq,
    8: optional string areaDisplay,
    9: optional i16 giftServiceTotal,
    10: optional i16 usedServiceTotal,
    11: optional i16 buyServiceTotal
}

struct EnlistDef {
    1: required i32 subjectId,
    2: required i32 classId,
    3: required i16 cycleDay,
    4: required i32 period_id,
}


service StudentService {

    list<StudentDef> getAll(1:required i32 limit, 2:required i32 offset)
        throws (1:common.ServerError se),

    i32 getAllCount()
        throws (1:common.ServerError se),

    list<EnlistDef> getEnlistResult(1:required string student_user_name)
        throws (1:common.ServerError se),

    list<EnlistDef> getClassList(1:required string student_user_name)
        throws (1:common.ServerError se),

    list<StudentDef> getFilteredStudents(
        1:required i32 limit,
        2:required i32 offset,
        3:required string condition)
        throws (1:common.ServerError se),

    i32 getFilteredStudentsCount(
        1:required string condition)
        throws (1:common.ServerError se),

    void ping()
}

struct ClassCreateTaskDef {
    1: required i32 id,
    2: required i16 grade,
    3: required i32 subjectId,
    4: required i32 periodId,
    5: required string classDay,
    6: required i16 startTime,
    7: required i16 endTime,
    8: required i32 studentNum,
    9: required i16 remainNum,
    10: required i16 taskStatus,
    11: required i32 newClassNum,
    12: optional i32 acceptCoachNum,
    13: optional i32 testSuccessCoachNum
}

struct CoachInviteDef {
    1: required i32 id,
    2: required i32 taskId,
    3: required i32 classTemplateId,
    4: required string coach,
    5: required i16 inviteStatus,
    6: required i16 inviteType,
    7: required string expireTime,
    8: required string inviteTime,
    9: optional string coachPhone,
    10: optional string coachRealName
}

service ClassAdminService {

    list<ClassCreateTaskDef> getAllClassCreateTasks(1:required i32 limit, 2:required i32 offset)
        throws (1:common.ServerError se),

    i32 getAllClassCreateTaskCount()
        throws (1:common.ServerError se),

    list<CoachInviteDef> getClassCreateTaskCoachInviteInfo(1:required i32 taskId)
        throws (1:common.ServerError se),

    list<StudentDef> getApplyStudentInfo(1:required i32 taskId)
        throws (1:common.ServerError se),

    i16 inviteCoach(1:required i32 taskId, 2:required string coachName)
        throws (1:common.ServerError se),

    bool cancelInvite(1:required i32 taskId, 2:required string coachName)
        throws (1:common.ServerError se),

    i16 startChangeClassCoach(1:required i32 classId, 2:required string newCoachName, 3:required i16 reasonType, 4:required string remark)
        throws (1:common.ServerError se),

    i16 startTemporarySubstituteCoach(1:required i32 classId, 2:required string newCoachName, 3:required list<string> days, 4:required string remark)
        throws (1:common.ServerError se),

    bool sendNotification(
        1:required i16 classId,
        2:required string notification,
        3:required list<i16> target
    )throws (1:common.ServerError se),

    i16 modifyStudentToAnotherClass(
        1:required string studentName,
        2:required i16 originClassId,
        3:required i16 targetClassId
        4:required string op_admin,
        5:required string remark
    )throws (1:common.ServerError se),

    bool closeClass(1:required i32 classId)
        throws (1:common.ServerError se),

    void ping()
}

struct QuotaDef {
    1: required i32 templateId,
    2: required i32 startTime,
    3: required i32 endTime,
    4: required string subject,
    5: required string coachName,
}


struct TutorInfoDef {
    1: required i32 templateId,
    2: required i32 status,
    3: required i16 startTime,
    4: required i16 endTime,
    5: required string startDay,
    6: required string endDay
}

struct DescriptionDef {
    1: required string Description
}

# 用户提交教练伴学服务订单
struct TutorOrderDef {
    1: required string userName,
    2: required i32 templateId,
    3: required i16 edition,
    4: required string startTime,
    5: required string endTime
}

# 导入教练伴学服务授权用户数据结构
struct InformationDef {
    1: required string userName,
    2: required i16 times,
    3: required string deadline
}

service QuotaService {

    # 根据用户名得到是否有权限报名教练伴学(试运营期间)
    bool getIsAuthorized(1:required string student)
        throws (1:common.ServerError se),

    # 用户的教练伴学服务
    list<QuotaDef> getCoachTutorService(1:required string student)
        throws (1:common.ServerError se),

    # 当前教练伴学服务详情
    list<TutorInfoDef> getAllEnrollmentInfo(1:required string student, 2:required i32 subject_id, 3:required i16 grade)
        throws (1:common.ServerError se),

    # 根据用户选择的开始时间得到终止日期
    string getFinishDayByStartDay(1:required string student, 2:required string start_day)
        throws (1:common.ServerError se),

    # 根据起止时间和班型得到区间内的同班型的所有日期
    list<DescriptionDef> getClassDescriptionByTimePoint(1:required i16 template_id, 2:required string start_day, 3:required string end_day)
        throws (1:common.ServerError se),

    # 用户提交教练伴学服务
    i16 submitTutorService(1: required TutorOrderDef order)
        throws (1:common.ServerError se),

    # 批量导入教练伴学服务授权用户信息
    bool patchImportTutorService(1: required InformationDef information)
        throws (1:common.ServerError se),

    # 同步用户信息
    bool syncUserInfo(1:required list<string> user_names)
        throws (1:common.ServerError se),

    void ping()
}

service TutorClientService {

    # 教练登陆客户端完成软件测试
    bool completeSoftwareTest(1:required string coach)
        throws (1:common.ServerError se),

    # 记录教练最新登陆客户端的时间
    bool logCoachLastLoginTime(1:required string coach)
        throws (1:common.ServerError se),

    void ping()
}


struct ClassDef{
    1: required i32 classID,
    2: required string startDate,
    3: required string endDate,
    4: required string coach,
    5: required i16 year ,
    6: required i16 season ,
    7: required i16 grade ,
    8: required i32 subject,
    9: required i16 circleDay,
   10: required i16 startTime,
   11: required i16 endTime,
   12: required i16 maxOneClass,
   13: required i32 maxClass,
   14: required i16 numberOfPeople,
   15: required double percent,
   16: required i16 changeCoach,
   17: required string lessonPlan,
   18: required i16 isClosed
}
struct StudentInClassDef{
    1:required string userName,
    2:required string realName,
    3:required string phone,
    4:required string areaDisplay,
    5:required string firstClassDate,
    6:required string lastClassDate
}
struct ClassExchangeDef{
    1:required i32 oldClassID,
    2:required i32 newClassID,
    3:required i32 state
}
struct TemporarySubstituteInfoDef{
    1: required i32 classID,
    2: required string oldCoach,
    3: required i16 season ,
    4: required i16 grade ,
    5: required i32 subject,
    6: required i16 circleDay,
    7: required i16 startTime,
    8: required i16 endTime,
    9: required string newCoach,
   10: required list<string> dateTime,
   11: required i32 times,
   12: required i16 status
}

struct ClassChangeCoachStatusDef{
    1: required i32 classID,
    2: required string originCoach,
    3: required i16 seasonId,
    4: required i16 grade,
    5: required i32 subjectId,
    6: required i16 circleDay,
    7: required i16 startTime,
    8: required i16 endTime,
    9: required string newCoach,
    10: required string beginDate,
    11: required i16 status,
    12: required i16 periodId
}

struct ClassNumDef{
    1: required string rank,
    2: required i16 id,
    3: required i16 spring_base_num,
    4: required i16 spring_max_num,
    5: required i16 winter_base_num,
    6: required i16 winter_max_num
}

service ClassService {

    list<StudentInClassDef>getStudentInfoInClassById(
        1:required i32 classId
    )throws (1:common.ServerError se),

    list<ClassExchangeDef> modifyStudentToAnotherClass(
        1:required i32 studentId,
        2:required list<ClassExchangeDef> changeList
    )throws (1:common.ServerError se),

    list<ClassDef> getFilteredClass(
        1:required i32 limit,
        2:required i32 offset,
        3:required string condition)
        throws (1:common.ServerError se),

    list<ClassDef> getClassById(
        1:required i32 classId
        )
        throws (1:common.ServerError se),

    i32 getFilteredClassCount(
        1:required string condition)
        throws (1:common.ServerError se),

    list<TemporarySubstituteInfoDef>getFilteredTemporaryInfo(
        1:required i32 limit,
        2:required i32 offset,
        3:required string condition
        )
        throws (1:common.ServerError se),

    i32 getFilteredTemporaryInfoCount(
        1:required string condition
        )
        throws (1:common.ServerError se),

    # 取出系统自动给班级更换老师的任务未完成的班级
    list<ClassChangeCoachStatusDef> getChangeClassCoachStatus(
        1:required i32 limit,
        2:required i32 offset)
        throws (1:common.ServerError se),

    i32 getChangeClassCoachStatusCount()
        throws (1:common.ServerError se),

    list<ClassNumDef> getRankClassNum()
        throws (1:common.ServerError se),

    bool updateRankClassNum(
        1:required string data)
        throws (1:common.ServerError se),

    void ping()
}


struct MonitorCoachDef{
    1: required i32 classID,
    2: required i16 season,
    3: required i16 year,
    4: required i16 grade,
    5: required i32 subject,
    6: required i16 circleDay,
    7: required string startDate,
    8: required i16 startTime,
    9: required i16 endTime,
   10: required string coach,
   11: required string realName,
   12: required i16 coachStatus,
   13: required i16 coachOnline,
   14: required i32 disconnectTime,
   15: required string phone
}

struct MonitorStudentDef{
    1: required i32 classID,
    2: required i16 season,
    3: required i16 year,
    4: required i16 grade,
    5: required i32 subject,
    6: required i16 circleDay,
    7: required string startDate,
    8: required i16 startTime,
    9: required i16 endTime,
    10: required i16 studentNum,
    11: required i16 loginNum,
    12: required i16 notlogNum,
    13: required i16 onlineNum,
    14: required i16 offlineNum,
    15: required double loginPercent,
    16: required double onlinePercent
}

service MonitorService {
    void ping(),

    list<MonitorCoachDef> filterCoachClass(
        1:required i32 limit,
        2:required i32 offset,
        3:required string condition)
        throws (1:common.ServerError se),

    list<MonitorStudentDef> filterStudentClass(
        1:required i32 limit,
        2:required i32 offset,
        3:required string condition)
        throws (1:common.ServerError se),

    i32 filterCoachClassCount(
        1:required string condition)
        throws (1:common.ServerError se),

    i32 filterStudentClassCount(
        1:required string condition)
        throws (1:common.ServerError se),

    list<MonitorCoachDef> filterUnusualCoach(
        1:required i32 limit,
        2:required i32 offset,
        3:required string condition)
        throws (1:common.ServerError se),

    list<MonitorStudentDef> filterUnusualStudent(
        1:required i32 limit,
        2:required i32 offset,
        3:required string condition)
        throws (1:common.ServerError se),

    i32 filterUnusualCoachCount(
        1:required string condition)
        throws (1:common.ServerError se),

    i32 filterUnusualStudentCount(
        1:required string condition)
        throws (1:common.ServerError se)
}
