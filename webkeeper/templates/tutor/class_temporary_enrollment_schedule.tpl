{% extends 'common/base_layout.tpl' %}
{% block title %}班级列表{% endblock %}
{% block page_style %}
<link rel="stylesheet" type="text/css"
      href="{{ static('assets/plugins/extjs/writer.css') }}"/>
{% endblock %}
{% block bottom_js %}
<script type="text/javascript" src="{{ static('assets/js/tutor/common.js') }}"></script>
<script type="text/javascript" src="{{ static('assets/js/tutor/stores.js') }}"></script>
<script type="text/javascript">
  (function () {
    function flexable(value, meta, record) {
      meta.style = 'overflow:auto;' +
        'padding: 0px 0px;' +
        'text-overflow: ellipsis;' +
        'white-space: nowrap;' +
        'white-space:normal;' +
        'line-height:20px;';
      return value;
    }

    function renderPeriod(value, p, record) {
      return record.data.startTime + ' ~ ' + record.data.endTime;
    }

    function renderDateTime(value, p, record) {
      if (record.data.dateTime.length == 0) {
        return "";
      }
      var out = record.data.dateTime[0];
      var date_time = record.data.dateTime;
      var length = date_time.length;
      for (var i = 1; i < length; i++) {
        out += "<br/>" + date_time[i];
      }
      return out;
    }

    var STATUS_LIST = {
      '0': '代课确认中',
      '1': '接受代课',
      '-1': '代课失败',
      '2': '代课完成'
    };

    function renderStatus(value, p, record) {
      return STATUS_LIST[value];
    }

    function aJaxGetCoachByUserName(userName, callBack) {
      Ext.Ajax.request({
        url: '/tutor/ajax/coach_list?start=0&limit=25&userName=' + userName,
        method: 'get',
        success: callBack,
        failure: function () {
          return null;
        }
      });
    }

    function renderPercent(value, p, percent) {
      return (percent.data.percent * 100).toFixed(1) + '%';
    }

    var COACH_EXCHANGE = {0: '', 1: '更换中', 2: '已更换', '-1': '更换失败'};

    function renderCoachExchangeState(value, p, changeState) {
      return COACH_EXCHANGE[changeState.data.changeCoach];
    }

    function renderMaxOneClassTemplate(value, p, record) {
      return (record.data.maxClass * record.data.maxOneClass);
    }

    //以下是班级管理的筛选功能模态弹窗以及功能设计

    Ext.onReady(function () {
      classTemplateEnrollmentScheduleStore.load();
      var grid = Ext.create('Ext.grid.Panel', {
          renderTo: Ext.getBody(),
          title: '招生进度表',
          store: classTemplateEnrollmentScheduleStore,//修改好外部之后去这里面修改内容
          layout: 'fit',
          referenceHolder: true,
          _searchWin: null,
          //下面的是表格的样式创建
          columns: [
            {
              text: '编号',
              dataIndex: 'templateId',
              width: 60,
              align: 'center'
            }, {
              text: '学季',
              dataIndex: 'seasonId',
              width: 120,
              align: 'center',
              renderer: renderSeason
            }, {
              text: '科目',
              dataIndex: 'subjectId',
              width: 60,
              align: 'center',
              renderer: getSubjectName
            }, {
              text: '年级',
              dataIndex: 'grade',
              width: 60,
              renderer: getGradeName,
              align: 'center'
            }, {
              text: '循环日',
              dataIndex: 'cycleDay',
              width: 60,
              renderer: getCycleDayName,
              align: 'center'
            }, {
              text: '时段',
              dataIndex: 'startTime',
              renderer: renderPeriod,
              align: 'center'
            }, {
              text: '招生名额',
              dataIndex: 'totalNumber',
              width: 70,
              align: 'center'
            }, {
              text: '占用名额<br>报名人数',
              dataIndex: 'usedNumber',
              width: 70,
              align: 'center'
            }, {
              text: '报名<br>本次课<br>的学员',
              dataIndex: 'currentClassNumber',
              flex:1,
              align: 'center'
            }, {
              text: '剩余名额',
              dataIndex: 'totalRestNumber',
              width: 70,
              align: 'center'
            }, {
              text: '本次课<br>剩余名额',
              dataIndex: 'currentRestNumber',
              flex:1,
              align: 'center'
            }, {
              text: '上次课<br>需续约数',
              dataIndex: 'lastClassContinueNumber',
              flex:1,
              align: 'center'
            }, {
              text: '上次课<br>未续约数',
              dataIndex: 'lastClassUnContinueNumber',
              flex:1,
              align: 'center'
            }, {
              text: '需要在<br>本次课<br>续约数',
              dataIndex: 'currentContinueNumber',
              flex:1,
              align: 'center'
            }, {
              text: '上次<br>课新约课<br>总人数',
              dataIndex: 'lastClassNewNumber',
              flex:1,
              align: 'center'
            }, {
              text: '上周<br>新约课<br>总人数',
              dataIndex: 'lastWeekTotalNumber',
              flex:1,
              align: 'center'
            }
          ],
          //下面的是一些功能按钮的创建
          dockedItems: [
            {
              dock: 'top',
              xtype: 'toolbar',
              items: [{
                text: '导出Excel',
                iconCls: 'icon-search',
                handler: function () {
                  window.open("excel/get_class_template_enrollment_schedule");
                }
              }]
            },
            {
              xtype: 'pagingtoolbar',
              store: classTemplateEnrollmentScheduleStore, // same store GridPanel is using
              dock: 'bottom',
              displayInfo: true
            }]
        }
      );

      Ext.on('resize', function () {
        if (grid) {
          if (grid.getView()) {
            grid.getView().refresh();
          }
        }
      });
      seasonStore.load(function () {
        periodStore.load(function () {
          classStore.load(function () {
            grid.getView().refresh();
          });
        });
      });
    });
  })();


</script>
{% endblock %}
