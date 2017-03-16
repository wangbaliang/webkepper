{% extends 'common/base_layout.tpl' %}
{% block title %}班级列表{% endblock %}
{% block page_style %}
<link rel="stylesheet" type="text/css"
      href="{{ static('assets/plugins/extjs/writer.css') }}"/>
  <style>
  tr.x-grid-record-near .x-grid-td {
    color: #e6e6e6;
  }
  </style>
{% endblock %}
{% block bottom_js %}
<script type="text/javascript" src="{{ static('assets/js/tutor/common.js') }}"></script>
<script type="text/javascript" src="{{ static('assets/js/tutor/stores.js') }}"></script>
<script type="text/javascript">
  (function () {

    var CLASS_CLOSE = {0: '', 1: '已关闭'};
    function renderIsClassClose(value, p, record) {
      return CLASS_CLOSE[record.data.isClosed];
    }

    function renderPeriod(value, p, record) {
      return record.data.startTime + ' ~ ' + record.data.endTime;
    }

    function rowStyle(record, rowIndex, rowParams, store) {
      if (record.get('isClosed')) {
        return 'x-grid-record-near';
      }
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

    function renderTimeBlock(value, p, record){
      return (record.data.startTime + "~" + record.data.endTime)
    }

    //以下是班级管理的筛选功能模态弹窗以及功能设计
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
                classStore.currentPage = 1;
                classStore.getProxy().extraParams = form.getFieldValues();
                classStore.load({
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

    Ext.define('CoachExchange.Form', {
      extend: 'Ext.window.Window',
      xtype: 'coach-exchange-form',
      title: '更换教练',
      width: 600,
      height: 600,
      minWidth: 600,
      minHeight: 600,
      defaults: {
        border: false,
        xtype: 'form',
        flex: 1,
        layout: 'anchor'
      },
      layout: {
        type: 'vbox',
        align: 'stretch'
      },
      modal: true,
      oldCoachInfo: {},
      initComponent: function () {

        Ext.apply(this, {
          bodyPadding: '0 0 0 0',
          defaults: {frame: false},
          layout: {
            type: 'vbox',
            pack: 'start',
            align: 'stretch'
          },

          items: [
            {
              title: '当前教练信息',
              flex: 1,
              layout: {
                type: 'hbox',
                align: 'middle ',
                pack: 'center'
              },
              bodyPadding: "0 0 15 15",
              defaults: {width: 190, border: false, align: 'center'},
              items: [
                {
                  items: [{
                    xtype: 'displayfield',
                    fieldLabel: '用户名',
                    labelWidth: 50,
                    anchor: '-10',
                    name: 'coach_user_name',
                    value: this.oldCoachInfo['userName']
                  }, {
                    xtype: 'displayfield',
                    fieldLabel: '省/市/（区）县',
                    labelWidth: 200,
                    anchor: '-10'
                  }]
                },
                {
                  items: [
                    {
                      xtype: 'displayfield',
                      fieldLabel: '姓名',
                      labelWidth: 50,
                      anchor: '-10',
                      value: this.oldCoachInfo['realName']
                    }, {
                      xtype: 'displayfield',
                      labelWidth: 200,
                      anchor: '-10',
                      value: this.oldCoachInfo['areaDisplay']
                    }]
                },
                {
                  items: [{
                    xtype: 'displayfield',
                    fieldLabel: '年级',
                    labelWidth: 50,
                    anchor: '-10',
                    value: this.oldCoachInfo['grade']
                  }]
                }]
            },
            {
              id: 'coach_exchange_form',
              xtype: 'form',
              title: '更换为',
              layout: {
                type: 'vbox',
                align: 'middle'
              },
              bodyPadding: "20 0 0 0",
              flex: 3,
              defaults: {width: 400},
              border: false,
              items: [
                {
                  xtype: 'textfield',
                  fieldLabel: '班级ID',
                  labelWidth: 50,
                  name: 'class_id',
                  value: this.classId,
                  hidden: true
                },
                {
                  xtype: 'textfield',
                  fieldLabel: '用户名',
                  emptyText: '请输入教练用户名',
                  labelWidth: 50,
                  anchor: '-10',
                  name: 'new_coach_user_name'
                }, {
                  xtype: 'textfield',
                  fieldLabel: '原教练',
                  hidden: true,
                  labelWidth: 50,
                  anchor: '-10',
                  name: 'old_coach_user_name',
                  value: this.oldCoachInfo['userName']
                },
                {
                  xtype: 'radiogroup',
                  fieldLabel: '理由',
                  cls: 'x-check-group-alt',
                  defaults: {labelWidth: 50},
                  items: [
                    {boxLabel: '公司要求', name: 'reason', inputValue: 1, checked: true},
                    {boxLabel: '教练要求', name: 'reason', inputValue: 2}
                  ]
                },
                {
                  xtype: 'textareafield',
                  name: 'remark',
                  fieldLabel: '备注',
                  allowBlank: true
                }
              ]
            }
          ],
          buttons: [
            {
              text: '确定',
              scope: this,
              handler: function (button, e) {
                var form = Ext.getCmp('coach_exchange_form').getForm();
                if (!form.isValid()) {
                  return;
                }
                var url = '/tutor/ajax/exchange_coach';
                form.submit({
                  scope: this,
                  waitMsg: '操作处理中...',
                  url: url,
                  params: {'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken")},
                  success: function (form, action) {
                    var data_back = action.result;
                    var state = data_back.data.state;
                    var values = form.getValues();
                    var erro_list = {
                      '-1': '更换失败:班级【id=' + values['class_id'] + '】不存在，请刷新后再试',
                      '-2': '更换失败:班级【id=' + values['class_id'] + '】正在更换教练中',
                      '-3': '更换失败:班级【id=' + values['class_id'] + '】班型不存在',
                      '-4': '更换失败:教练【用户名=' + values['new_coach_user_name'] + '】不存在，请重新核对教练用户名',
                      '-5': '更换失败:教练【用户名=' + values['new_coach_user_name'] + '】科目不符，请重新核对教练科目',
                      '-6': '更换失败:教练【用户名=' + values['new_coach_user_name'] + '】当前状态非在岗或待岗',
                      '-7': '更换失败:教练【用户名=' + values['new_coach_user_name'] + '】时段非法，请核对教练年级情况，时段是否可用或已被占用',
                      '-8': '更换失败:当前班级已无课程安排计划，不必更换教练',
                      '-9': '更换失败:教练的地区与该班型冲突，无法更换'
                    };
                    if (state == 1) {
                      Ext.toast({
                        html: '更换成功！',
                        closable: false,
                        align: 't',
                        slideInDuration: 400,
                        minWidth: 400
                      });
                      this.close();
                      classStore.reload();
                    } else {
                      Ext.toast({
                        html: erro_list[state],
                        closable: false,
                        align: 't',
                        slideInDuration: 400,
                        minWidth: 400
                      });
                    }
                  },
                  failure: function (form, action) {
                    Ext.toast({
                      html: '系统错误，请稍后再试，如一直出现错误，请联系管理员',
                      closable: false,
                      align: 't',
                      slideInDuration: 400,
                      minWidth: 400
                    });
                  }
                });
              }
            }, {
              text: '取消',
              scope: this,
              handler: function (button, e) {
                this.close();
              }
            }]
        });
        this.callParent();
      }
    });

    Ext.define('TempReplaceClass.Form', {
      extend: 'Ext.window.Window',
      title: '代课教练',
      width: 600,
      height: 600,
      minWidth: 600,
      minHeight: 600,
      layout: 'fit',
      modal: true,
      record: {},
      oldCoachInfo: {},
      initComponent: function () {
        this.temp_replace_class_time_store = getTempReplaceClassTimeStore(this.classId)
        Ext.apply(this, {
          autoScroll: true,
          items: [
            {
              border: false,
              bodyPadding: 10,
              layout: {
                type: 'vbox',
                align: 'stretch'
              },
              scrollable: true,
              items: [
                {
                  title: '当前教练信息',
                  flex: 1,
                  layout: {
                    type: 'hbox',
                    align: 'middle ',
                    pack: 'center'
                  },
                  bodyPadding: "0 0 15 15",
                  defaults: {width: 190, border: false, align: 'center'},
                  items: [
                    {
                      items: [{
                        xtype: 'displayfield',
                        fieldLabel: '用户名',
                        labelWidth: 50,
                        anchor: '-10',
                        name: 'coach_user_name',
                        value: this.oldCoachInfo['userName']
                      }, {
                        xtype: 'displayfield',
                        fieldLabel: '科目',
                        labelWidth: 50,
                        anchor: '-10',
                        value: getSubjectName(this.oldCoachInfo['subjectId'])
                      }]
                    },
                    {
                      items: [
                        {
                          xtype: 'displayfield',
                          fieldLabel: '姓名',
                          labelWidth: 50,
                          anchor: '-10',
                          value: this.oldCoachInfo['realName']
                        }]
                    },
                    {
                      items: [{
                        xtype: 'displayfield',
                        fieldLabel: '年级',
                        labelWidth: 50,
                        anchor: '-10',
                        value: this.oldCoachInfo['grade']
                      }]
                    }]
                },
                {
                  id: 'temp_replace_class_form',
                  xtype: 'form',
                  title: '更换为',
                  layout: {
                    type: 'vbox',
                    align: 'middle'
                  },
                  bodyPadding: "10 0 0 0",
                  flex: 3,
                  defaults: {border: false, width: 400},
                  items: [
                    {
                      xtype: 'textfield',
                      fieldLabel: '班级ID',
                      labelWidth: 50,
                      name: 'class_id',
                      value: this.classId,
                      hidden: true
                    },
                    {
                      xtype: 'textfield',
                      fieldLabel: '用户名',
                      emptyText: '请输入教练用户名',
                      labelWidth: 50,
                      name: 'new_coach_user_name',
                      width: 200,
                      allowBlank: false
                    },
                    {
                      xtype: 'textfield',
                      fieldLabel: '原教练',
                      hidden: true,
                      labelWidth: 50,
                      anchor: '-10',
                      name: 'old_coach_user_name',
                      value: this.oldCoachInfo['userName']
                    },
                    {
                      xtype: 'grid',
                      layout: 'fit',
                      store: this.temp_replace_class_time_store,
                      height: 200,
                      width: 500,
                      title: '代课次数',
                      bodyStyle: 'overflow-x:hidden; overflow-y:auto',
                      border: true,
                      //frame: true,
                      columns: [
                        {text: '上课日期', dataIndex: 'classTime', width: 210, align: 'center'},
                        {text: '上课时间段', dataIndex: 'timeBlock', width: 210, align: 'center',renderer:renderTimeBlock},
                        {
                          text: '选择', xtype: 'templatecolumn', width: 50,
                          tpl: '<input name=days type=checkbox value={classTime} />'
                        },

                      ],
                    }
                    , {
                      style: 'margin-top:10px;',
                      xtype: 'textareafield',
                      fieldLabel: '具体原因说明',
                      name: 'reason',
                      allowBlank: false
                    }
                  ]
                }
              ],
            }
          ],

          buttons: [
            {
              text: '确定',
              scope: this,
              handler: function (button, e) {
                var form = Ext.getCmp('temp_replace_class_form').getForm();
                var values = form.getValues();
                var days_list = Ext.query("*[name=days]:checked");
                var days = [];
                for (var item in days_list) {
                  days.push(days_list[item].value);
                }
                days.sort();
                if (!form.isValid()) {
                  return;
                }
                var url = '/tutor/ajax/temp_replace_coach';
                form.submit({
                  scope: this,
                  waitMsg: '操作处理中...',
                  url: url,
                  params: {
                    'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken"),
                    'days': Ext.encode(days)
                  },
                  success: function (form, action) {
                    var data_back = action.result;
                    var state = data_back.data.state;
                    var values = form.getValues();
                    var erro_list = {
                      '-1': '代课失败:请选择代课日期',
                      '-2': '代课失败:班级【id=' + values['class_id'] + '】不存在，请刷新列表重新查阅',
                      '-3': '代课失败:班级【id=' + values['class_id'] + '】班型不存在',
                      '-4': '代课失败:教练【用户名=' + values['new_coach_user_name'] + '】不存在，请仔细核对教练用户名',
                      '-5': '代课失败:教练【用户名=' + values['new_coach_user_name'] + '】科目与班级科目不符',
                      '-6': '代课失败:教练【用户名=' + values['new_coach_user_name'] + '】当前状态非在岗或待岗',
                      '-7': '代课失败:教练【用户名=' + values['new_coach_user_name'] + '】于当前班型不可用，请检查时段、年级、科目等班型信息与教练是否匹配',
                      '-8': '代课失败:代课日期中包含已上课的日期，请确认',
                      '-9': '代课失败:代课日期中存在不在课程计划中的日期，请确认',
                      '-10': '代课失败:当前班级存在学生地区与教练冲突'
                    };
                    if (state == 1) {
                      Ext.toast({
                        html: '代课成功！',
                        closable: false,
                        align: 't',
                        slideInDuration: 400,
                        minWidth: 400
                      });
                      this.close();
                      classStore.reload();
                    } else {
                      Ext.toast({
                        html: erro_list[state],
                        closable: false,
                        align: 't',
                        slideInDuration: 400,
                        minWidth: 400
                      });
                    }
                  },
                  failure: function (form, action) {
                    Ext.toast({
                      html: '系统错误，请稍后再试，如一直出现错误，请联系管理员',
                      closable: false,
                      align: 't',
                      slideInDuration: 400,
                      minWidth: 400
                    });
                  }
                });
              }
            }, {
              text: '取消',
              scope: this,
              handler: function (button, e) {
                this.close();
              }
            }]
        });
        this.callParent();
      }
    });

    Ext.define('ClassInformation.Form',
      {
        extend: 'Ext.window.Window',
        title: '班级详情',
        width: 1000,
        height: 600,
        minWidth: 660,
        minHeight: 600,
        layout: 'fit',
        modal: true,
        closeAction: 'close',
        base_info: {},
        record: {},
        referenceHolder: true,
        initComponent: function () {
          var classInfo = this.base_info;
          var userName = this.base_info['coach'];
          this.useablePeriod = getUsablePeriod(userName);//获取可用时段
          this.classId = this.base_info['classID'];
          this.student_list_Store = getStudentInClassList(this.classId);
          if (!seasonStore.isLoaded()) {
            seasonStore.load();
          }
          if (!periodStore.isLoaded()) {
            periodStore.load();
          }
          if (!areaStore.isLoaded()) {
            areaStore.load();
          }
          Ext.apply(this, {
            items: [{
              border: false,
              bodyPadding: 10,
              layout: {
                type: 'vbox',
                align: 'stretch'
              },
              scrollable: true,
              items: [{
                  title: '班级信息',
                  layout: {
                    type: 'vbox',
                    align: 'stretch'
                  },
                  defaults: {border: false, bodyPadding: "5 0 15 15", align: 'center'},
                  items: [{
                    layout: {
                      type: 'hbox',
                      align: 'stretch'
                    },
                    defaults: {
                      width: 180, border: false, align: 'center',
                      bodyStyle: 'overflow-x:visible;overflow-y:true'
                    },
                    items: [
                      {
                        flex: 1,
                        html: '班级ID:' + this.base_info['classID'] + '<br><br>' +
                        '年级:' + getGradeName(this.base_info['grade']) + '<br><br>' +
                        '循环日:' + getCycleDayName(this.base_info['circleDay'])
                      }, {
                        flex: 1,
                        html: '开班日期:' + this.base_info['startDate'] + '<br><br>' +
                        '学季:' + renderSeason(this.base_info['season']) + '<br><br>' +
                        '时间段:' + renderPeriod(0, 0, this.record)

                      }, {
                        flex: 1,
                        html: '关闭日期:' + this.base_info['endDate'] + '<br><br>' +
                        '科目:' + getSubjectName(this.base_info['subject']) + '<br><br>' +
                        '班级最大人数:' + this.base_info['maxOneClass']
                      }
                    ]
                  }
                  ]
                },{
                  title: '教练信息',
                  layout: {
                    type: 'vbox',
                    align: 'stretch'
                  },
                  defaults: {border: false, bodyPadding: "5 0 15 15", align: 'center'},
                  items: [{
                    layout: {
                      type: 'hbox',
                      align: 'stretch'
                    },
                    defaults: {
                      width: 180, border: false, align: 'center',
                      bodyStyle: 'overflow-x:visible;overflow-y:true'
                    },
                    items: [
                      {
                        flex: 1,
                        html: '用户名:' + this.base_info['coach']
                      }
                    ]
                  }
                  ]
                },{
                  xtype: 'grid',
                  title: '学生信息',
                  store: this.student_list_Store,
                  layout: 'fit',
                  reference: 'student_info_grid',
                  columns: [
                    {
                      text: '学生账号',
                      flex: 1,
                      sortable: true,
                      dataIndex: 'userName',
                    }, {
                      text: '姓名',
                      flex: 1,
                      sortable: true,
                      dataIndex: 'realName'
                    }, {
                      text: '手机',
                      flex: 1,
                      sortable: true,
                      dataIndex: 'phone'
                    }, {
                      text: '地区',
                      flex: 1,
                      sortable: true,
                      dataIndex: 'areaDisplay',
                    }, {
                      text: '首次课日期',
                      flex: 1,
                      sortable: true,
                      dataIndex: 'firstClassDate',
                    }
                    , {
                      text: '末次课日期',
                      flex: 1,
                      sortable: true,
                      dataIndex: 'lastClassDate',
                    }
                  ],
                  dockedItems: [{
                    dock: 'top',
                    xtype: 'toolbar',
                    items: [{
                      xtype: 'textfield',
                      reference: 'target_class'
                    },{
                      text: '调班',
                      reference: 'modify_class',
                      disabled: true,
                      scope: this,
                      handler: function () {
                        var modify_class = this.lookupReference('modify_class');
                        var student_grid = this.lookupReference('student_info_grid')
                        var studentInfo = student_grid.getSelection();
                        if (!studentInfo.length){
                          modify_class.setDisabled(true);
                          return;
                        }
                        var prompt_message = this.lookupReference('prompt_message');
                        var targetClassID = this.lookupReference('target_class').getValue();
                        if (!targetClassID){
                          prompt_message.setText('请输入目标班级ID');
                          return;
                        }
                        prompt_message.setText('');
                        var originClassID = classInfo.classID;
                        var studentName = studentInfo[0].data.userName;
                        var url = '/tutor/ajax/modify_student_to_another_class?';
                        url += 'studentName=' + studentName + '&originClassId=' + originClassID + '&targetClassId=' + targetClassID;
                        Ext.Ajax.request({
                          url: url,
                          method: 'get',
                          success: function (resp, opts) {
                            var response = Ext.util.JSON.decode(resp.responseText);
                            var success = response['success'];
                            console.log(response, success)
                            if(success){
                              prompt_message.setText('调班成功');
                              // 加载学生信息
                              classStore.reload();
                              student_grid.store.reload();
                              modify_class.setDisabled(true);
                            }
                            else{
                              var prompt = response['message'];
                              prompt_message.setText(prompt);
                            }
                          },
                          failure: function () {
                            Ext.toast({
                              html: '系统错误，请稍后再试，如一直出现错误，请联系管理员',
                              closable: false,
                              align: 't',
                              slideInDuration: 400,
                              minWidth: 400
                            });
                          }
                        });
                      }
                    },{
                      xtype: 'label',
                      reference: 'prompt_message'
                      // text: 'error'
                    }]
                  }],
                  listeners: {
                    select: {
                      scope: this,
                      fn: function (component, record, index, eOpts) {
                        var ref = this.getReferences();
                        var lastClassDate = record.data.lastClassDate + 'T' + classInfo.startTime;
                        var lastClassDate = new Date(lastClassDate);
                        var now = Date.now();
                        console.log(lastClassDate, now);
                        if (lastClassDate > now){
                          ref.modify_class.setDisabled(false);
                        }
                        else{
                          ref.modify_class.setDisabled(true);
                        }
                      }
                    }
                  },

                }
              ]
            }],

            buttons: [{
              text: '确定',
              scope: this,
              handler: function (button, e) {
                this.close();
              }
            }]
          });
          this.callParent();
        }
      }
    );

    Ext.define('SendNotification.Form', {
      extend: 'Ext.window.Window',
      classid: '',
      initComponent: function () {
        Ext.apply(this, {
          bodyPadding: '0 10 0 10',
          defaults: {frame: false},
          layout: {
            type: 'vbox',
            pack: 'start',
            align: 'stretch'
          },
          title: '发送通知',
          items: [
            {
              id: 'notification_form',
              xtype: 'form',
              layout: {
                type: 'vbox',
                align: 'left'
              },
              bodyPadding: "20 0 5 0",
              flex: 3,
              defaults: {width: 400},
              border: false,
              items: [
                {
                  xtype: 'checkboxgroup',
                  fieldLabel: '通知对象',
                  vertical: false,
                  items:[{
                    boxLabel: '教师',
                    name: 'target',
                    inputValue: 'coach'
                  },{
                    boxLabel: '未结课学员',
                    name: 'target',
                    inputValue: 'student_in_class'
                  },{
                    boxLabel: '已结课学员',
                    name: 'target',
                    inputValue: 'student_not_in_class'
                  }]
                }, {
                  xtype: 'label',
                  text: '通知内容:',
                }, {
                  xtype: 'textareafield',
                  name: 'notification',
                  height: 150,
                  grow: true,
                  anchor: '100%',
                }]
            }
          ],
          buttons: [
            {
              text: '确定',
              scope: this,
              handler: function (button, e) {
                var form = Ext.getCmp('notification_form').getForm();
                if (!form.isValid()) {
                  return;
                }
                // 没有选发送对象
                var target = form.getFieldValues().target;
                var flag = false;
                Ext.Array.each(target, function(name, index, countriesItSelf) {
                  if (name === true) {
                    flag= true;
                  }
                })
                if (!flag){
                  // Ext.Msg.alert("请选择通知对象");
                  Ext.toast({
                    html: '请选择通知对象',
                    closable: false,
                    align: 't',
                    slideInDuration: 400,
                    minWidth: 400
                  });
                  return;
                }

                // 没有填写内容
                var notification = form.getFieldValues().notification;
                if (!notification){
                  // Ext.Msg.alert("请填写通知内容");
                  Ext.toast({
                    html: '请填写通知内容',
                    closable: false,
                    align: 't',
                    slideInDuration: 400,
                    minWidth: 400
                  });
                  return;
                }

                var class_id = this.classId;
                var url = '/tutor/ajax/send_notification';
                form.submit({
                  scope: this,
                  waitMsg: '操作处理中...',
                  url: url,
                  params: {'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken"), 'classId': class_id},
                  success: function (form, action) {
                    var message = action.result.data;
                    Ext.toast({
                        html: message,
                        closable: false,
                        align: 't',
                        slideInDuration: 400,
                        minWidth: 400
                      });
                    this.close();
                  },
                  failure: function (form, action) {
                    Ext.toast({
                      html: '系统错误，请稍后再试，如一直出现错误，请联系管理员',
                      closable: false,
                      align: 't',
                      slideInDuration: 400,
                      minWidth: 400
                    });
                  }
                });
              }
            }, {
              text: '取消',
              scope: this,
              handler: function (button, e) {
                this.close();
              }
            }]
        });
        this.callParent();
      }
    })

    Ext.onReady(function () {
      var grid = Ext.create('Ext.grid.Panel', {
        renderTo: Ext.getBody(),
        title: '班级列表',
        store: classStore,//修改好外部之后去这里面修改内容
        layout: 'fit',
        referenceHolder: true,
        _searchWin: null,
        viewConfig:{ getRowClass: rowStyle },
        //下面的是表格的样式创建
        columns: [
          {
            text: '班级ID',
            dataIndex: 'classID',
            width: 60,
            align: 'center'
          }, {
            text: '开班日期',
            dataIndex: 'startDate',
            flex: 1,
            align: 'center'
          }, {
            text: '关闭日期',
            dataIndex: 'endDate',
            width: 100,
            align: 'center',
            flex: 1
          }, {
            text: '教师',
            dataIndex: 'coach',

            width: 100,
            flex: 1,
            align: 'center'
          }, {
            text: '学年',
            dataIndex: 'year',
            renderer: getSeasonYearName,
            width: 100,
            align: 'center',
            flex: 1
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
            text: '班级最大人数',
            dataIndex: 'maxOneClass',
            flex: 1,
            align: 'center'
          }, {
            text: '班级人数',
            dataIndex: 'numberOfPeople',
            flex: 1,
            align: 'center'
          }, {
            text: '满班率',
            dataIndex: 'percent',
            renderer: renderPercent,
            flex: 1,
            align: 'center'
          }, {
            text: '教练更换',
            dataIndex: 'changeCoach',
            flex: 1,
            renderer: renderCoachExchangeState,
            align: 'center'
          }, {
            text: '是否关闭',
            dataIndex: 'isClosed',
            flex: 1,
            renderer: renderIsClassClose,
            align: 'center'
          }
        ],
        //下面的是一些功能按钮的创建
        dockedItems: [{
          dock: 'top',
          xtype: 'toolbar',
          items: [{
              text: '筛选',
              iconCls: 'icon-search',
              handler: function () {
                this._searchWin = this._searchWin || Ext.create('ClassSearch.Form', {});
                this._searchWin.show();
                var ref = grid.getReferences();
                ref.clearSearchButton.setDisabled(false);
              }
            }, {
              text: '取消筛选',
              reference: 'clearSearchButton',
              disabled: true,
              iconCls: 'icon-search',
              handler: function () {
                classStore.getProxy().extraParams = [];
                classStore.currentPage = 1;
                classStore.load();
                var ref = grid.getReferences();
                ref.clearSearchButton.setDisabled(true);

              }
            }, '-', {
              text: '更换教练',
              reference: 'exchange_button',
              disabled:true,
              iconCls: 'icon-cog-edit',
              handler: function (view, record, item, index, e) {
                var selection = grid.getSelection();
                if (!selection.length) {
                  return;
                }
                var success = function (resp, opts) {
                  var response = Ext.util.JSON.decode(resp.responseText);
                  var coach_num = response['data']['rows'].length;
                  if (coach_num == 0) {
                    console.log('教练信息不存在，请查看数据库中是否有该教练');
                    return;
                  } else if (coach_num > 1) {
                    console.log('教练信息有重复，请查看数据库中用户名是否重复');
                    return;
                  }
                  var grade = transGradeType2Grade(selection[0].data.grade);
                  var coach_info = response['data']['rows'][0];
                  coach_info['grade'] = grade;
                  var win = Ext.create('CoachExchange.Form', {oldCoachInfo: coach_info, classId: class_id});
                  win.show();
                };
                var coachName = selection[0].data.coach;
                var class_id = selection[0].data.classID;
                aJaxGetCoachByUserName(coachName, success)
              }
            }, {
              text: '取消课次',
              iconCls: 'icon-reset',
              disabled: true,
              handler: function () {
              }
            }, {
              text: '教练代课',
              iconCls: 'icon-reset',
              reference:'temp_replace',
              disabled:true,
              handler: function (view, record, item, index, e) {
                var selection = grid.getSelection();
                if (!selection.length) {
                  return;
                }
                var success = function (resp, opts) {
                  var response = Ext.util.JSON.decode(resp.responseText);
                  var coach_num = response['data']['rows'].length;
                  if (coach_num == 0) {
                    console.log('教练信息不存在，请查看数据库中是否有该教练');
                    return;
                  } else if (coach_num > 1) {
                    console.log('教练信息有重复，请查看数据库中用户名是否重复');
                    return;
                  }
                  var grade = transGradeType2Grade(selection[0].data.grade);
                  var coach_info = response['data']['rows'][0];
                  coach_info['grade'] = grade;
                  var win = Ext.create('TempReplaceClass.Form', {
                    oldCoachInfo: coach_info
                    , classId: class_id, lesson_plan: selection[0].data.lessonPlan
                  });
                  win.show();
                };
                var coachName = selection[0].data.coach;
                var class_id = selection[0].data.classID
                aJaxGetCoachByUserName(coachName, success)
              }
            }, {
              text: '发送通知',
              reference:'send_notification',
              disabled: true,
              handler: function (view, record, item, index, e) {
                var selection = grid.getSelection();
                if (!selection.length) {
                  return;
                }
                var class_id = selection[0].data.classID;
                var win = Ext.create('SendNotification.Form', {classId: class_id});
                win.show();
              }
            }, {
              text: '关闭班级',
              iconCls: 'icon-edit',
              reference:'close_class',
              disabled:true,
              handler: function () {
                var selection = grid.getSelection();
                if (!selection.length) {
                  return;
                }
                Ext.Ajax.request({
                  url: '/tutor/ajax/close_class',
                  params: {
                    'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken"),
                    'classId': selection[0].data.classID
                  },
                  success: function (response) {
                    var responseText = Ext.decode(response.responseText);
                    var success = responseText.success;
                    if(success) {
                      Ext.toast({
                      html: '操作成功',
                      closable: false,
                      align: 't',
                      slideInDuration: 400,
                      minWidth: 400
                      });
                    classStore.reload();
                    }
                    else{
                      Ext.toast({
                      html: '操作失败,关闭该班可能导致后续分班失败！',
                      closable: false,
                      align: 't',
                      slideInDuration: 400,
                      minWidth: 400
                    });
                    classStore.reload();
                    }

                  },
                  failure: function (response) {
                    Ext.MessageBox.show({
                      msg: '操作失败，请您重试',
                      icon: Ext.MessageBox.ERROR
                    });
                  }
                });
              }
            }]
          }, {
            xtype: 'pagingtoolbar',
            store: classStore, // same store GridPanel is using
            dock: 'bottom',
            displayInfo: true
          }],
          listeners: {
            select: {
              scope: grid,
              fn: function (component, record, index, eOpts) {
                var changeCoach = record.data.changeCoach;
                var ref = this.getReferences();
                ref.temp_replace.setDisabled(false);
                if (changeCoach == 1) {
                  //更换中置灰
                  ref.exchange_button.setDisabled(true)
                } else {
                  ref.exchange_button.setDisabled(false)
                }
                // 发送通知按钮
                var ClassStuNum = record.data.numberOfPeople;
                if (ClassStuNum<=0){
                  ref.send_notification.setDisabled(true)
                } else {
                  ref.send_notification.setDisabled(false)
                }
                // 关闭班级按钮
                var is_closed = record.data.isClosed;
                var classNum = record.data.numberOfPeople;
                if (is_closed == 0 && classNum == 0){
                  ref.close_class.setDisabled(false)
                } else {
                  ref.close_class.setDisabled(true)
                }
              }
            },
            'rowdblclick': function (view, record, item, index, e) {
              var base_info = record.data;
              this._student_info_window = Ext.create('ClassInformation.Form', {
                base_info: base_info,
                record: record
              });
              this._student_info_window.show();
              var ref = grid.getReferences();
              //ref.clearSearchButton.setDisabled(false);
            }
          }
        });

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
