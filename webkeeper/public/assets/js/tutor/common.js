/**
 * Created by Mars on 2016/1/20.
 */
'use strict';

var SEASON_TYPE_NAMES = ['', '秋季', '寒假', '春季', '暑假'];
var GRADE_TYPES = ['小学', '初中', '高中'];
var GRADES = ['', '一年级', '二年级', '三年级', '四年级', '五年级', '六年级', '初一', '初二', '初三', '高一', '高二', '高三'];
var CYCLE_DAYS = ['', '每周一', '每周二', '每周三', '每周四', '每周五', '每周六', '每周日', '周一到周六', '周六日'];
var SUBJECTS = ['', '语文', '数学', '英语', '物理', '化学', '生物', '历史', '地理', '政治', '文科综合', '理科综合', '其他', '科学'];
var COACH_EXCHANGE = ['','已变更','未变更'];
function getSeasonYearName(year) {
  var nextYear = year + 1;
  return year + '-' + nextYear;
}


function getSeasonTypeName(seasonType) {
  return SEASON_TYPE_NAMES[seasonType];
}

function getSeasonName(year, seasonType) {
  return getSeasonYearName(year) + getSeasonTypeName(seasonType);
}

function getGradeTypeName(gradeType) {
  return GRADE_TYPES[gradeType];
}

function getGradeName(grade) {
  return GRADES[grade];
}

function getCycleDayName(cycle) {
  return CYCLE_DAYS[cycle];
}

function getSubjectName(subject) {
  return SUBJECTS[subject];
}

function getCoachJobStatusText(jobStatus) {
  switch (jobStatus) {
    case -1: return '解聘';
    case 0: return '再培';
    case 1: return '储备';
    case 2: return '待岗';
    case 3: return '在岗';
    default: return '';
  }
}

function periodIntToString(periodIntValue) {
  var hour = Math.floor(periodIntValue / 60);
  var minute = periodIntValue % 60;
  return (hour < 10 ? '0' : '') + hour + ':' + (minute < 10 ? '0' : '') + minute;
}

Ext.define('KitchenSink.AdvancedVType', {
  override: 'Ext.form.field.VTypes',

  daterange: function (val, field) {
    var date = field.parseDate(val);

    if (!date) {
      return false;
    }
    if (field.startDateField) {
      var start = field.up('form').down('#' + field.startDateField);
      if (!start.__dateRangeMax || (date.getTime() != start.__dateRangeMax.getTime())) {
        start.setMaxValue(date);
        start.validate();
        start.__dateRangeMax = date;
      }
    }
    else if (field.endDateField) {
      var end = field.up('form').down('#' + field.endDateField);
      if (!end.__dateRangeMin || (date.getTime() != end.__dateRangeMin.getTime())) {
        end.setMinValue(date);
        end.validate();
        end.__dateRangeMin = date;
      }
    }
    /*
     * Always return true since we're only using this vtype to set the
     * min/max allowed values (these are tested for after the vtype test)
     */
    return true;
  },

  daterangeText: '开始日期必须小于结束日期',

  timerange: function (val, field) {
    var date = field.parseDate(val);
    //console.log(date);

    if (!date) {
      return false;
    }
    if (field.startTimeField) {
      var start = field.up('form').down('#' + field.startTimeField);
      if (!start.__dateRangeMax || (date.getTime() != start.__dateRangeMax.getTime())) {
        start.setMaxValue(date);
        start.validate();
        start.__dateRangeMax = date;
      }
    }
    else if (field.endTimeField) {
      var end = field.up('form').down('#' + field.endTimeField);
      if (!end.__dateRangeMin || (date.getTime() != end.__dateRangeMin.getTime())) {
        end.setMinValue(date);
        end.validate();
        end.__dateRangeMin = date;
      }
    }
    /*
     * Always return true since we're only using this vtype to set the
     * min/max allowed values (these are tested for after the vtype test)
     */
    return true;
  },

  timerangeText: '开始时间必须小于时间日期',

  password: function (val, field) {
    if (field.initialPassField) {
      var pwd = field.up('form').down('#' + field.initialPassField);
      return (val == pwd.getValue());
    }
    return true;
  },

  passwordText: '密码不一致'
});
