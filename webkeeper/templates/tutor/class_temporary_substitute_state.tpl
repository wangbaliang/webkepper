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

    function renderPeriod(value, p, record) {
      return record.data.startTime + ' ~ ' + record.data.endTime;
    }

    function renderDateTime(value, p, record) {
      if(record.data.dateTime.length == 0){
        return "";
      }
      var out = record.data.dateTime[0];
      var date_time = record.data.dateTime;
      var length = date_time.length;
      for(var i = 1 ; i < length;i++){
        out +="<br/>"+date_time[i];
      }
      return out;
    }
    var STATUS_LIST = {
      '0':'代课确认中',
      '1':'接受代课',
      '-1':'代课失败',
      '2':'代课完成'
    };
    function renderStatus(value, p, record){
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
      classTemporarySubstituteStore.load();
      var grid = Ext.create('Ext.grid.Panel', {
          renderTo: Ext.getBody(),
          title: '代课列表',
          store: classTemporarySubstituteStore,//修改好外部之后去这里面修改内容
          layout: 'fit',
          referenceHolder: true,
          _searchWin: null,
          //下面的是表格的样式创建
          columns: [
            {
              text: '班级ID',
              dataIndex: 'classID',
              width: 60,
              align: 'center'
            }, {
              text: '原教师',
              dataIndex: 'oldCoach',
              width: 100,
              flex: 1,
              align: 'center'
            }, {
              text: '学季',
              dataIndex: 'season',
              flex: 1,
              align: 'center',
              renderer: renderSeason
            }, {
              text: '年级',
              dataIndex: 'grade',
              flex: 1,
              renderer: getGradeName,
              align: 'center'
            }, {
              text: '科目',
              dataIndex: 'subject',
              flex: 1,
              align: 'center',
              renderer: getSubjectName
            }, {
              text: '循环日',
              dataIndex: 'circleDay',
              renderer: getCycleDayName,
              flex: 1,
              align: 'center'
            }, {
              text: '时段',
              dataIndex: 'startTime',
              renderer: renderPeriod,
              flex: 1,
              align: 'center'
            }, {
              text: '代课教练',
              dataIndex: 'newCoach',
              flex: 1,
              align: 'center'
            }, {
              text: '代课日期',
              dataIndex: 'dateTime',
              renderer: renderDateTime,
              flex: 1,
              align: 'center'
            }, {
              text: '代课次数',
              dataIndex: 'times',
              flex: 1,
              align: 'center'
            }, {
              text: '代课状态',
              dataIndex: 'status',
              renderer: renderStatus,
              flex: 1,
              align: 'center'
            }],
          //下面的是一些功能按钮的创建
        dockedItems: [
//          {
//          dock: 'top',
//          xtype: 'toolbar',
//          items: [{
//            text: '筛选',
//            iconCls: 'icon-search',
//            handler: function () {
//              this._searchWin = this._searchWin || Ext.create('ClassSearch.Form', {});
//              this._searchWin.show();
//              var ref = grid.getReferences();
//              ref.clearSearchButton.setDisabled(false);
//            }
//          }, {
//            reference: 'clearSearchButton',
//            text: '取消筛选',
//            disabled: true,
//            iconCls: 'icon-search',
//            handler: function () {
//              classStore.getProxy().extraParams = [];
//              classStore.currentPage = 1;
//              classStore.load();
//              var ref = grid.getReferences();
//              ref.clearSearchButton.setDisabled(true);
//
//            }
//          }, '-', {
//            reference: 'exchangeCoach',
//            text: '更换教练',
//            reference: 'exchange_button',
//            disabled:true,
//            iconCls: 'icon-cog-edit',
//            handler: function (view, record, item, index, e) {
//              var selection = grid.getSelection();
//              if (!selection.length) {
//                return;
//              }
//              var success = function (resp, opts) {
//                var response = Ext.util.JSON.decode(resp.responseText);
//                var coach_num = response['data']['rows'].length;
//                if (coach_num == 0) {
//                  console.log('教练信息不存在，请查看数据库中是否有该教练');
//                  return;
//                } else if (coach_num > 1) {
//                  console.log('教练信息有重复，请查看数据库中用户名是否重复');
//                  return;
//                }
//                var grade = transGradeType2Grade(selection[0].data.grade);
//                var coach_info = response['data']['rows'][0];
//                coach_info['grade'] = grade;
//                var win = Ext.create('CoachExchange.Form', {oldCoachInfo: coach_info, classId: class_id});
//                win.show();
//              };
//              var coachName = selection[0].data.coach;
//              var class_id = selection[0].data.classID
//              aJaxGetCoachByUserName(coachName, success)
//            }
//          }, {
//            text: '取消课次',
//            iconCls: 'icon-reset',
//            disabled: true,
//            handler: function () {
//            }
//          }, {
//            text: '教练代课',
//            iconCls: 'icon-reset',
//            reference:'temp_replace',
//            disabled:true,
//            handler: function (view, record, item, index, e) {
//              var selection = grid.getSelection();
//              if (!selection.length) {
//                return;
//              }
//              var success = function (resp, opts) {
//                var response = Ext.util.JSON.decode(resp.responseText);
//                var coach_num = response['data']['rows'].length;
//                if (coach_num == 0) {
//                  console.log('教练信息不存在，请查看数据库中是否有该教练');
//                  return;
//                } else if (coach_num > 1) {
//                  console.log('教练信息有重复，请查看数据库中用户名是否重复');
//                  return;
//                }
//                var grade = transGradeType2Grade(selection[0].data.grade);
//                var coach_info = response['data']['rows'][0];
//                coach_info['grade'] = grade;
//                var win = Ext.create('TempReplaceClass.Form', {
//                  oldCoachInfo: coach_info
//                  , classId: class_id, lesson_plan: selection[0].data.lessonPlan
//                });
//                win.show();
//              };
//              var coachName = selection[0].data.coach;
//              var class_id = selection[0].data.classID
//              aJaxGetCoachByUserName(coachName, success)
//            }
//          }]
//        },
           {
          xtype: 'pagingtoolbar',
          store: classTemporarySubstituteStore, // same store GridPanel is using
          dock: 'bottom',
          displayInfo: true
        }],
//        listeners: {
//          select: {
//            scope: grid,
//            fn: function (component, record, index, eOpts) {
//              var changeCoach = record.data.changeCoach;
//              var ref = this.getReferences();
//              ref.temp_replace.setDisabled(false);
//              if (changeCoach == 1) {
//                //更换中置灰
//                ref.exchange_button.setDisabled(true)
//              } else {
//                ref.exchange_button.setDisabled(false)
//              }
//            }
//          }
//          ,
//          'rowdblclick': function (view, record, item, index, e) {
//            var base_info = record.data;
//            this._student_info_window = Ext.create('ClassInformation.Form', {
//              base_info: base_info,
//              record: record
//            });
//            this._student_info_window.show();
//            var ref = grid.getReferences();
//            //ref.clearSearchButton.setDisabled(false);
//          }
//        }
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
