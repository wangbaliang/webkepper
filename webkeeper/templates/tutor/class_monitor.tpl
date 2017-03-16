{% extends 'common/base_layout.tpl' %}
{% block title %}课堂监控{% endblock %}
{% block page_style %}
<link rel="stylesheet" type="text/css" href="{{ static('assets/plugins/extjs/writer.css') }}"/>
<style>tr.x-grid-record-near .x-grid-td {background: #ffd4d4;}</style>
{% endblock %}
{% block bottom_js %}
  <script type="text/javascript" src="{{ static('assets/js/tutor/common.js') }}"></script>
  <script type="text/javascript" src="{{ static('assets/js/tutor/stores.js') }}"></script>
  <script type="text/javascript">
    (function () {
      function renderPeriod(value, p, record) {
        return record.data.startTime + ' ~ ' + record.data.endTime;
      };

      function rendercoachStatus(value, p, record){
        var coachStatus=record.data.coachStatus;
        if(coachStatus==0){return "未登陆"}
        else if (coachStatus==1){return "已登陆"}
        else {return "数据错误"}
      }

      function rendercoachOnline(value, p, record){
        var coachOnline=record.data.coachOnline;
        if(coachOnline==0){return "断线"}
        else if (coachOnline==1){return "正常在线"}
        else {return "数据错误"}
      }

      function renderdisconnectTime(value, p, record){
        var disconnectTime=record.data.disconnectTime;
        if (disconnectTime!=0){
          return disconnectTime + '分钟';
        }
        else{return '/'}
      }

      function renderLoginPercent(value, p, record){
        return (record.data.loginPercent*100).toFixed(1) + '%';
      }

      function renderOnlinePercent(value, p ,record){
        return (record.data.onlinePercent*100).toFixed(1) + '%';
      }

      function rowStyle(record, rowIndex, rowParams, store) {
        var data = record.data;
        // 教练监控和学生监控共用，先根据数据项判断是哪个
        if(data.coachOnline || data.coachOnline==0){
          if (data.disconnectTime>=5 || data.coachOnline==0) {
            return 'x-grid-record-near';
          }
        }
        if(data.loginNum || data.loginNum==0){
          if(data.loginNum==0){
            return 'x-grid-record-near';
          }
        }
      }

      function loadCoachStore(){
        seasonStore.load(function () {
            uMonitorCoachStore.load(function () {
              monitorCoachStore.load(function () {
                coachgrid.getView().refresh();
                loadSummarizeCoachData();
              });
            });
          });
      };

      function loadStudentStore(){
        seasonStore.load(function () {
            uMonitorStudentStore.load(function () {
              monitorStudentStore.load(function () {
                studentgrid.getView().refresh();
                loadSummarizeStuData();
              });
            });
          });
      };

      function loadSummarizeCoachData(){
        var totalClasses=monitorCoachStore.getTotalCount();
        var loginCoachNum=monitorCoachStore.sum('coachStatus');
        var notloginCoachNum=totalClasses-loginCoachNum;
        var onlineCoachNum=monitorCoachStore.sum('coachOnline');
        var offlineCoachNum=totalClasses-onlineCoachNum;
        // var errorClassNum=offlineCoachNum
        var errorClassNum=0;
        monitorCoachStore.each(function(record){
          var disconnectTime = record.data.disconnectTime;
          var coachStatus = record.data.coachStatus;
          if(disconnectTime>=5 || coachStatus==0){
            errorClassNum++;
          }
        });
        var coachtml = '<big>' + '应上课的班级：' + totalClasses + '个' + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + '异常班级：' + errorClassNum + '个' + '</big>' + '<br><br>' + '<big>' + '已登录教练：' + loginCoachNum + '人' + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + '未登陆教练：' + notloginCoachNum + '人' + '</big>' + '<br><br>' + '<big>' + '当前在线的教练：' + onlineCoachNum + '人' + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp' + '当前断线的教练'  + offlineCoachNum + '人' + '</big>';
        Ext.getCmp('summarizepanel').body.update(coachtml);
      };

      function loadSummarizeStuData(){
        var nowClasses=monitorStudentStore.getTotalCount();
        var classStuNum=monitorStudentStore.sum('studentNum');
        var loginStuNum=monitorStudentStore.sum('loginNum');
        var onlineStuNum=monitorStudentStore.sum('onlineNum');
        var totalLoginPer=(loginStuNum/classStuNum * 100).toFixed(1) + '%';
        var totalOnlinePer=(onlineStuNum/loginStuNum * 100).toFixed(1) + '%';
        if(totalOnlinePer=="NaN%"){
          var totalOnlinePer= 0+'%';
        }
        if(totalLoginPer=="NaN%"){
          var totalLoginPer= 0+'%';
        }
        var errorClassNum=uMonitorStudentStore.count();
        var studenthtml = '<big>' + '当前正在上课的班级：' + nowClasses + '个' + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' +  '异常班级：' + errorClassNum + '个' + '</big>' + '<br><br>' + '<big>' + '班级学生数量：' + classStuNum + '人' +  '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + '已登陆学生：' + loginStuNum + '人' + '</big>' + '<br><br>' + '<big>' + '当前在线的学生：' + onlineStuNum + '人' + '</big>' + '<br><br>' + '<big>' + '总体学生登陆比例：' + totalLoginPer +  '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + '总体学生在线比例：' + totalOnlinePer + '</big>';
        Ext.getCmp('summarizepanel').body.update(studenthtml);
      }

      function changeStore(grid, pagingtoolbar, store){
        grid.reconfigure(store);
        store.loadPage(1);
        Ext.getCmp(pagingtoolbar).bindStore(store);
      }

      Ext.define('ClassSearch.Form',
        {
          extend: 'Ext.window.Window',
          xtype: 'class-search-form',

          title: '查询',
          width: 500,
          height: 400,
          minWidth: 300,
          minHeight: 340,
          layout: 'fit',
          modal: true,
          closeAction: 'hide',

          initComponent: function () {
            this.seasonStore = getSeasonSelectStore();
            this.gradeStore = gradeSelectStore;
            this.subjectStore = subjectSelectStore;
            this.cycleStore = getCycleDaySelectStore();
            this.periodStore = getPeriodSelectStore();
            this.YearStore = getYearSelectStore();

            this.seasonId = undefined;
            this.grade = undefined;
            Ext.apply(this, {
              items: [{
                id: 'class_search_form',
                xtype: 'form',
                border: false,
                bodyPadding: 10,
                layout: {
                  type: 'vbox',
                  align: 'stretch'
                },
                items: [{
                  xtype: 'textfield',
                  fieldLabel: '班级ID',
                  name: 'classID',
                  allowBlank: true
                }, {
                  xtype: 'textfield',
                  fieldLabel: '教练姓名',
                  name: 'teacherName',
                  allowBlank: true
                }, {
                  xtype: 'datefield',
                  fieldLabel: '开班日期',
                  format: 'Y-m-d',
                  name: 'startDate',
                  allowBlank: true
                }, {
                  xtype: 'combobox',
                  fieldLabel: '学年',
                  name: 'year',
                  allowBlank: true,
                  displayField: 'year_out',
                  store: this.YearStore,
                  valueField: 'year_get',
                  queryMode: 'local',
                  editable: false
                }, {
                  xtype: 'combobox',
                  fieldLabel: '学季',
                  name: 'season',
                  allowBlank: true,
                  store: this.seasonStore,
                  displayField: 'text',
                  valueField: 'id',
                  queryMode: 'local',
                  editable: false
                }, {
                  xtype: 'combobox',
                  fieldLabel: '年级',
                  name: 'grade',
                  allowBlank: true,
                  store: this.gradeStore,
                  valueField: 'grade',
                  queryMode: 'local',
                  editable: false
                }, {
                  xtype: 'combobox',
                  fieldLabel: '科目',
                  name: 'subject',
                  allowBlank: true,
                  store: this.subjectStore,
                  valueField: 'subject',
                  queryMode: 'local',
                  editable: false
                }]
              }],

              buttons: [{
                text: '确定',
                scope: this,
                handler: function (button, e) {
                  var form = Ext.getCmp('class_search_form').getForm();
                  if (!form.isValid()) {
                    return;
                  }
                  var identityTab = Ext.getCmp('identityTab').getActiveTab().title;
                  if(identityTab=="教练"){
                    monitorStore = coachgrid.store;
                  }
                  else if (identityTab=="学生"){
                    monitorStore = studentgrid.store;
                  }
                  monitorStore.currentPage = 1;
                  monitorStore.getProxy().extraParams = form.getFieldValues();
                  monitorStore.load({
                    scope: this,
                    params: form.getFieldValues(),
                    callback: function () {
                      Ext.toast({
                        html: '操作成功',
                        closable: false,
                        align: 't',
                        slideInDuration: 400,
                        minWidth: 400
                      });
                      this.hide();
                    }
                  });
                }
              }]
            });
            this.callParent();
          }
        });

      var coachgrid = Ext.create('Ext.grid.Panel', {
        layout: 'fit',
        referenceHolder: true,
        store: uMonitorCoachStore,
        _searchWin: null,
        viewConfig:{ getRowClass: rowStyle },
        columns: [
          {
            text: '班级ID',
            dataIndex: 'classID',
            width: 100,
            align: 'center'
          }, {
            text: '学季',
            dataIndex: 'season',
            width: 200,
            align: 'left',
            flex: 1,
            renderer: renderSeason
          }, {
            text: '年级',
            dataIndex: 'grade',
            width: 100,
            align: 'center',
            flex: 1,
            renderer: getGradeName
          }, {
            text: '科目',
            dataIndex: 'subject',
            renderer: getSubjectName,
            width: 100,
            align: 'center',
            flex: 1
          }, {
            text: '循环日',
            dataIndex: 'circleDay',
            renderer: getCycleDayName,
            width: 150,
            align: 'center',
            flex: 1,
          }, {
            text: '开班日期',
            dataIndex: 'startDate',
            align: 'center',
            flex: 1,
          }, {
            text: '时间段',
            dataIndex: 'startTime',
            renderer: renderPeriod,
            align: 'center',
            flex: 1,
          }, {
            text: '教练用户名',
            dataIndex: 'coach',
            flex: 1,
            align: 'center'
          }, {
            text: '教练姓名',
            dataIndex: 'realName',
            flex: 1,
            align: 'center'
          }, {
            text: '教练当前状态',
            dataIndex: 'coachStatus',
            renderer: rendercoachStatus,
            flex: 1,
            align: 'center'
          }, {
            text: '教练是否断线',
            dataIndex: 'coachOnline',
            renderer: rendercoachOnline,
            flex: 1,
            align: 'center'
          }, {
            text: '断线时间',
            dataIndex: 'disconnectTime',
            renderer: renderdisconnectTime,
            flex: 1,
            align: 'center'
          }, {
            text: '手机号',
            dataIndex: 'phone',
            flex: 1,
            align: 'center'
          }],
        dockedItems: [{
          dock: 'top',
          xtype: 'toolbar',
          items: [{
              text: '筛选',
              iconCls: 'icon-search',
              handler: function () {
                this._searchWin = this._searchWin || Ext.create('ClassSearch.Form', {});
                this._searchWin.show();
                var ref = coachgrid.getReferences();
                ref.clearSearchButton.setDisabled(false);
              }
            },{
              reference: 'clearSearchButton',
              text: '取消筛选',
              disabled: true,
              iconCls: 'icon-search',
              handler: function () {
                coachstore = coachgrid.store;
                coachstore.getProxy().extraParams = [];
                // coachstore.getProxy().setExtraParam("type", 0);
                coachstore.currentPage = 1;
                coachstore.load();
                var ref = coachgrid.getReferences();
                ref.clearSearchButton.setDisabled(true);
              }
            },{
            xtype: 'radiogroup',
            id: 'coachradio',
            defaults: {
                flex: 1
            },
            layout: 'hbox',
            items: [{
                xtype: "radio",
                boxLabel : '异常班级',
                inputValue: 'unusualcoach',
                name: 'coachClass',
                checked : true,
                handler: function(radio,isCheck){
                  if (isCheck){
                    changeStore(coachgrid, 'coachpagingtoolbar', uMonitorCoachStore);
                  }
                }
              },{
                xtype: "radio",
                boxLabel: "所有班级",
                inputValue: 'allcoach',
                name: 'coachClass',
                handler: function(radio,isCheck){
                  if(isCheck){
                    changeStore(coachgrid, 'coachpagingtoolbar', monitorCoachStore);
                  }
                }
              }, ]
          }]
        }, {
          xtype: 'pagingtoolbar',
          store: uMonitorCoachStore,
          id: 'coachpagingtoolbar',
          dock: 'bottom',
          displayInfo: true
        }],
      });

      var studentgrid = Ext.create('Ext.grid.Panel', {
        store: uMonitorStudentStore,
        layout: 'fit',
        referenceHolder: true,
        _searchWin: null,
        viewConfig:{ getRowClass: rowStyle },
        columns: [
          {
            text: '班级ID',
            dataIndex: 'classID',
            width: 100,
            align: 'center'
          }, {
            text: '学季',
            dataIndex: 'season',
            width: 200,
            align: 'left',
            flex: 1,
            renderer: renderSeason
          }, {
            text: '年级',
            dataIndex: 'grade',
            width: 100,
            align: 'center',
            flex: 1,
            renderer: getGradeName
          }, {
            text: '科目',
            dataIndex: 'subject',
            renderer: getSubjectName,
            width: 100,
            flex: 1,
            align: 'center'
          }, {
            text: '循环日',
            dataIndex: 'circleDay',
            renderer: getCycleDayName,
            width: 150,
            align: 'center',
            flex: 1,
          }, {
            text: '开班日期',
            dataIndex: 'startDate',
            flex: 1,
            align: 'center'
          }, {
            text: '时间段',
            dataIndex: 'startTime',
            renderer: renderPeriod,
            flex: 1,
            align: 'center'
          }, {
            text: '已分班学生数',
            dataIndex: 'studentNum',
            flex: 1,
            align: 'center'
          }, {
            text: '登陆学生数',
            dataIndex: 'loginNum',
            flex: 1,
            align: 'center'
          }, {
            text: '未登陆学生数',
            dataIndex: 'notlogNum',
            flex: 1,
            align: 'center'
          }, {
            text: '当前在线学生数',
            dataIndex: 'onlineNum',
            flex: 1,
            align: 'center'
          }, {
            text: '当前不在线学生数',
            dataIndex: 'offlineNum',
            flex: 1,
            align: 'center'
          },{
            text: '学生登陆比例',
            dataIndex: 'loginPercent',
            flex: 1,
            align: 'center',
            renderer:renderLoginPercent,
          }, {
            text: '学生在线比例',
            dataIndex: 'onlinePercent',
            flex: 1,
            align: 'center',
            renderer:renderOnlinePercent,
          }],
        dockedItems: [{
          dock: 'top',
          xtype: 'toolbar',
          items: [{
              text: '筛选',
              iconCls: 'icon-search',
              handler: function () {
                this._searchWin = this._searchWin || Ext.create('ClassSearch.Form', {});
                this._searchWin.show();
                var ref = studentgrid.getReferences();
                ref.clearSearchButton.setDisabled(false);
              }
            },{
              reference: 'clearSearchButton',
              text: '取消筛选',
              disabled: true,
              iconCls: 'icon-search',
              handler: function () {
                coachstore = studentgrid.store;
                coachstore.getProxy().extraParams = [];
                coachstore.currentPage = 1;
                coachstore.load();
                var ref = studentgrid.getReferences();
                ref.clearSearchButton.setDisabled(true);
              }
            },{
            xtype: 'radiogroup',
            // defaultType: 'radiofield',
            id: 'sturadio',
            defaults: {
                flex: 1
            },
            layout: 'hbox',
            items: [{
                xtype: "radio",
                boxLabel : '异常班级',
                inputValue: 'unusualstu',
                name: 'stuClass',
                checked : true,
                handler: function(radio,isCheck){
                  if (isCheck){
                    changeStore(studentgrid, 'stupagingtoolbar', uMonitorStudentStore);
                  }
                }
              },{
                xtype: "radio",
                boxLabel: "所有班级",
                inputValue: 'allstu',
                name: 'stuClass',
                handler: function(radio,isCheck){
                  if(isCheck){
                    changeStore(studentgrid, 'stupagingtoolbar', monitorStudentStore);
                  }
                }
              }, ]
          }]
        }, {
          xtype: 'pagingtoolbar',
          store: uMonitorStudentStore,
          id: 'stupagingtoolbar',
          dock: 'bottom',
          displayInfo: true
        }]
      });

      Ext.onReady(function () {
        var grid = Ext.create('Ext.panel.Panel', {
          renderTo: Ext.getBody(),
          title: '班级监控列表',
          // bodyPadding: 50,
          // layout: 'hbox',
          // layout: { left:10, top:20, right:10},
          referenceHolder: true,
          items: [{
              xtype: 'panel',
              title: '正在上课的班级总体情况',
              id: "summarizepanel",
              layout: 'fit',
              height: 50,
              minHeight: 250,
              align: 'center',
            },{
              xtype: "tabpanel",
              id: 'identityTab',
              layout: 'fit',
              activeTab: 0,
              plain: true,
              items: [{
                title: "教练",
                items: [coachgrid],
              },{
                title: "学生",
                items: [studentgrid],
              }],
              listeners: {
                tabchange: function(tp, p){
                  if(p.title=='教练'){
                    loadCoachStore();
                  }
                  else if(p.title=='学生'){
                    loadStudentStore();
                  }
                }
              }
            }]

        });

        loadCoachStore();

        // 定时任务每分钟刷新一次数据
        var loadInterval = 1000*60;
        var loadMonitorStore={
          run:function(){
            var identityTab = Ext.getCmp('identityTab').getActiveTab().title;
            if(identityTab=="教练"){
              var coachradio = Ext.getCmp('coachradio').getValue()['coachClass'];
              if(coachradio=="unusualcoach"){
                uMonitorCoachStore.load();
              }
              // 统计需要加载monitorCoachStore
              monitorCoachStore.load(function(){
                loadSummarizeCoachData();
              });
            }
            else if (identityTab=="学生"){
              monitorStudentStore.load(function(){
                uMonitorStudentStore.load(function(){
                  loadSummarizeStuData();
                });
              });
            }

          },
          interval:loadInterval,
          scope:this
        }
        Ext.TaskManager.start(loadMonitorStore);
        // #############

      });

    })();
  </script>
{% endblock %}
