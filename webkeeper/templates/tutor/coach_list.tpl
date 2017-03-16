{% extends 'common/base_layout.tpl' %}
{% block title %}教练列表{% endblock %}
{% block page_style %}
<link rel="stylesheet" type="text/css"
      href="{{ static('assets/plugins/extjs/writer.css') }}"/>
{% endblock %}
{% block bottom_js %}
<script type="text/javascript" src="{{ static('assets/js/tutor/common.js') }}"></script>
<script type="text/javascript" src="{{ static('assets/js/tutor/stores.js') }}"></script>
<script type="text/javascript">
  (function () {
    var renderOperateType = function renderOperateType(type){
      var type_list = {'1': '解聘', '2': '再培','3':'解除再培'}
      return type_list[type];
    };

    var getRankText = function getRankText(rank){
      return RankStore.findRecord('id', rank).data.rank;
    }

    var setComboClassNum = function setComboClassNum(ref, data){
      // fields = ['spring_base_num', 'spring_max_num', 'winter_base_num', 'winter_max_num'];
      ref.spring_base_num.setValue(data.spring_base_num);
      ref.spring_max_num.setValue(data.spring_max_num);
      ref.winter_base_num.setValue(data.winter_base_num);
      ref.winter_max_num.setValue(data.winter_max_num);
    }

    Ext.define('CoachImport.Form', {
      extend: 'Ext.window.Window',
      xtype: 'coach-import-form',
      title: '批量导入教练',
      width: 500,
      height: 300,
      minWidth: 300,
      minHeight: 220,
      layout: 'fit',
      modal: true,

      initComponent: function () {

        Ext.apply(this, {
          items: [{
            id: 'coach_import_form',
            xtype: 'form',
            border: true,
            bodyPadding: 10,
            layout: {
              type: 'vbox',
              align: 'stretch'
            },
            items: [{
              xtype: 'textareafield',
              name: 'coachNames',
              allowBlank: false,
              height: 200
            }]
          }],

          buttons: [{
            text: '确定',
            scope: this,
            handler: function (button, e) {
              var form = Ext.getCmp('coach_import_form').getForm();
              if (!form.isValid()) {
                return;
              }
              var url = '/tutor/ajax/import_coaches';
              form.submit({
                scope: this,
                waitMsg: '操作处理中...',
                url: url,
                params: {'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken")},
                success: function (form, action) {
                  Ext.toast({
                    html: '操作成功',
                    closable: false,
                    align: 't',
                    slideInDuration: 400,
                    minWidth: 400
                  });
                  this.close();
                  coachStore.reload();
                },
                failure: function (form, action) {
                  var checkResult = action.result && action.result.message;
                  var msg = '';
                  if (checkResult) {
                    if (checkResult.imported.length > 0) {
                      msg += '教练' + checkResult.imported.join(', ') + '已存在。';
                    }
                    if (checkResult.notExists.length > 0) {
                      msg += '用户名为' + checkResult.notExists.join(', ') + '的用户不存在。';
                    }
                    if (checkResult.notTeacher.length > 0) {
                      msg += '用户名为' + checkResult.notTeacher.join(', ') + '的用户不是教师身份。';
                    }
                    if (msg) {
                      msg = '检查失败：' + msg;
                    }
                  }
                  Ext.MessageBox.show({
                    msg: msg || '操作失败，请您重试',
                    icon: Ext.MessageBox.ERROR
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

    Ext.define('CoachSearch.Form', {
      extend: 'Ext.window.Window',
      xtype: 'coach-search-form',
      title: '查询',
      width: 500,
      height: 300,
      minWidth: 300,
      minHeight: 220,
      layout: 'fit',
      modal: true,
      closeAction: 'hide',
      periodStore: {},
      initComponent: function () {
        this.subjectStore = subjectSelectStore;
        this.gradeStore = gradeSelectStore;
        this.periodStore = getPeriodAllSelectStore();
        this.cycleStore = getAllCycleDaySelectStore();
        Ext.apply(this, {
          items: [{
            id: 'coach_search_form',
            xtype: 'form',
            border: false,
            bodyPadding: 10,
            layout: {
              type: 'vbox',
              align: 'stretch'
            },
            items: [{
              xtype: 'textfield',
              fieldLabel: '用户名',
              name: 'userName',
              allowBlank: true
            }, {
              xtype: 'textfield',
              fieldLabel: '手机号',
              name: 'phone',
              allowBlank: true
            }, {
              xtype: 'combobox',
              fieldLabel: '科目',
              name: 'subjectId',
              store: this.subjectStore,
              valueField: 'subject',
              queryMode: 'local',
              editable: false,
              allowBlank: true
            }, {
              xtype: 'textfield',
              fieldLabel: 'QQ',
              name: 'qq',
              allowBlank: true
            }, {
              xtype: 'combobox',
              fieldLabel: '循环日',
              name: 'cycle_day',
              store: this.cycleStore,
              valueField: 'cycle',
              queryMode: 'local',
              editable: false,
              allowBlank: true
            },{
              xtype: 'combobox',
              fieldLabel: '全部可用时段',
              name: 'period_id',
              store: this.periodStore,
              valueField: 'period_id',
              queryMode: 'local',
              editable: false,
              allowBlank: true
            }]
          }],

          buttons: [{
            text: '确定',
            scope: this,
            handler: function (button, e) {
              var form = Ext.getCmp('coach_search_form').getForm();
              if (!form.isValid()) {
                return;
              }
              coachStore.currentPage = 1;//将当前页翻回第一页，才能正确刷新
              coachStore.getProxy().extraParams = form.getFieldValues();
              coachStore.load({
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

    Ext.define('CoachDismiss.Form', {
      extend: 'Ext.window.Window',
      xtype: 'coach-dismiss-form',

      title: '解聘教练',
      width: 500,
      height: 300,
      minWidth: 300,
      minHeight: 220,
      layout: 'fit',
      modal: true,

      coachName: '',

      initComponent: function () {

        Ext.apply(this, {
          items: [{
            id: 'coach_dismiss_form',
            xtype: 'form',
            border: false,
            bodyPadding: 10,
            layout: {
              type: 'vbox',
              align: 'stretch'
            },
            items: [{
              xtype: 'hiddenfield',
              name: 'coachName',
              value: this.coachName
            }, {
              xtype: 'displayfield',
              value: '你确认要解聘【' + this.coachName + '】教练么？',
              hideLabel: true
            }, {
              xtype: 'textareafield',
              name: 'remark',
              fieldLabel: '解聘理由',
              allowBlank: false
            }]
          }],

          buttons: [{
            text: '确定',
            scope: this,
            handler: function (button, e) {
              var form = Ext.getCmp('coach_dismiss_form').getForm();
              if (!form.isValid()) {
                return;
              }
              var url = '/tutor/ajax/dismiss_coach';
              form.submit({
                scope: this,
                waitMsg: '操作处理中...',
                url: url,
                params: {'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken")},
                success: function (form, action) {
                  Ext.toast({
                    html: '操作成功',
                    closable: false,
                    align: 't',
                    slideInDuration: 400,
                    minWidth: 400
                  });
                  this.close();
                  coachStore.reload();
                },
                failure: function (form, action) {
                  var checkResult = action.result && action.result.message;
                  var msg;
                  if (checkResult.length > 0) {
                    msg = '该教练正在给编号为：【' + checkResult.join('】,【 ') + '】的班级上课，请更换这些班级教练后再解聘';
                  }
                  Ext.MessageBox.show({
                    msg: msg || '操作失败，请您重试',
                    icon: Ext.MessageBox.ERROR
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

    Ext.define('CoachRetrain.Form', {
      extend: 'Ext.window.Window',
      xtype: 'coach-dismiss-form',

      title: '教练再培',
      width: 500,
      height: 300,
      minWidth: 300,
      minHeight: 220,
      layout: 'fit',
      modal: true,

      coachName: '',

      initComponent: function () {

        Ext.apply(this, {
          items: [{
            id: 'coach_dismiss_form',
            xtype: 'form',
            border: false,
            bodyPadding: 10,
            layout: {
              type: 'vbox',
              align: 'stretch'
            },
            items: [{
              xtype: 'hiddenfield',
              name: 'coachName',
              value: this.coachName
            }, {
              xtype: 'displayfield',
              value: '你确认要对教练【' + this.coachName + '】进行再培？',
              hideLabel: true
            }, {
              xtype: 'textareafield',
              name: 'remark',
              fieldLabel: '再培理由',
              allowBlank: false
            }]
          }],

          buttons: [{
            text: '确定',
            scope: this,
            handler: function (button, e) {
              var form = Ext.getCmp('coach_dismiss_form').getForm();
              if (!form.isValid()) {
                return;
              }
              var url = '/tutor/ajax/set_coach_retraining';
              form.submit({
                scope: this,
                waitMsg: '操作处理中...',
                url: url,
                params: {'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken")},
                success: function (form, action) {
                  Ext.toast({
                    html: '操作成功',
                    closable: false,
                    align: 't',
                    slideInDuration: 400,
                    minWidth: 400
                  });
                  this.close();
                  coachStore.reload();
                },
                failure: function (form, action) {
                  var checkResult = action.result && action.result.message;
                  var msg;
                  if (checkResult.length > 0) {
                    msg = '该教练正在给编号为：【' + checkResult.join('】,【 ') + '】的班级上课，请更换这些班级教练后再进行再培';
                  }
                  Ext.MessageBox.show({
                    msg: msg || '操作失败，请您重试',
                    icon: Ext.MessageBox.ERROR
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

    Ext.define('CoachInformation.Form', {
        extend: 'Ext.window.Window',
        title: '教练资料',
        width: 660,
        height: 600,
        minWidth: 660,
        minHeight: 600,
        layout: 'fit',
        modal: true,
        closeAction: 'hide',
        base_info: {},
        initComponent: function () {
          var userName = this.base_info['userName'];
          this.useablePeriod = getUsablePeriod(userName);//获取可用时段
          this.firedHistory = getFiredHistory(userName);
          if (!seasonStore.isLoaded()) {
            seasonStore.load();
          }
          if (!periodStore.isLoaded()) {
            periodStore.load();
          }
          this.enlist_store = getEnlistList(userName);
          Ext.apply(this, {
            items: [{
              border: false,
              bodyPadding: 10,
              layout: {
                type: 'vbox',
                align: 'stretch'
              },
              scrollable: true,
              items: [
                {
                  title: '基本资料',
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
                        width: 250,
                        html: '用户名:' + this.base_info['userName'] + '<br><br>' +
                        '手机:' + this.base_info['phone'] + '<br><br>' +
                        '省/市/（区）县：' + this.base_info['areaDisplay']
                      }, {
                        width: 200,
                        html: '姓名:' + this.base_info['realName'] + '<br><br>' +
                        'QQ号:' + this.base_info['qq'] + '<br><br>' +
                        '学校:' + this.base_info['schoolName']

                      }, {
                        width: 150,
                        html: '状态:' + getCoachJobStatusText(this.base_info['jobStatus']) + '<br><br>' +
                        '科目:' + getSubjectName(this.base_info['subjectId']) + '<br><br>' +
                        '年级:' + getGradeTypeName(this.base_info['gradeType'])
                      }
                    ]
                  }
                  ]

                },
                {
                  // flex: 2,
                  xtype: 'grid',
                  title: '可用时段',
                  store: this.useablePeriod,
                  layout: 'fit',
                  referenceHolder: true,
                  _searchWin: null,
                  columns: [
                    {
                      text: '学季',
                      flex: 1,
                      sortable: false,
                      dataIndex: 'seasonId',
                      renderer: renderSeason
                    }, {
                      text: '最早上课日期',
                      flex: 1,
                      sortable: false,
                      dataIndex: 'startDay'
                    }, {
                      text: '结束日期',
                      flex: 1,
                      sortable: false,
                      dataIndex: 'endDay',
                      //renderer:
                    },
                    {
                      text: '循环日',
                      flex: 1,
                      sortable: false,
                      dataIndex: 'cycleDay',
                      renderer:getCycleDayName
                      //renderer:
                    },
                    {
                      text: '上课时段',
                      flex: 1,
                      sortable: false,
                      dataIndex: 'periodId',
                      renderer: renderPeriod
                    }
                  ]
                },
                {
                  xtype: 'grid',
                  title: '开班记录（本功能当前版本不开放）',
                  store: this.enlist_store,
                  layout: 'fit',
                  referenceHolder: true,
                  _searchWin: null,
                  columns: [
                    {
                      text: '开班日期',
                      flex: 1,
                      sortable: false,
                      dataIndex: 'subjectId',
                      renderer: getSubjectName
                    }, {
                      text: '班级ID',
                      flex: 1,
                      sortable: false,
                      dataIndex: 'classId'
                    }, {
                      text: '上课次数',
                      flex: 1,
                      sortable: false,
                      dataIndex: 'cycleDay',
                      renderer: getCycleDayName
                    }, {
                      text: '最近上课日期',
                      flex: 1,
                      sortable: false,
                      dataIndex: 'period_id',
                      renderer: renderPeriod
                    }
                  ]
                }
                , {
                  // flex: 2,
                  xtype: 'grid',
                  title: '聘任记录',
                  store: this.firedHistory,
                  layout: 'fit',
                  referenceHolder: true,
                  _searchWin: null,
                  columns: [
                    {
                      text: '操作日期',
                      flex: 1,
                      sortable: false,
                      dataIndex: 'firedDate',
                    }, {
                      text: '操作类型',
                      flex: 1,
                      sortable: false,
                      dataIndex: 'operateType',
                      renderer: renderOperateType
                    }, {
                      text: '操作理由',
                      flex: 1,
                      sortable: false,
                      dataIndex: 'firedReason',
                    },{
                      text: '操作人',
                      flex: 1,
                      sortable: false,
                      dataIndex: 'operator',
                    }
                  ]
                },
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
      });

    Ext.define('CoachRank.Form', {
      extend: 'Ext.window.Window',
      xtype: 'coach-rank-form',
      title: '设定教练等级',
      width: 500,
      height: 300,
      layout: {
        type: 'fit',
        // align: 'center',
        align : 'middle',
        pack: 'center',
        },
      modal: true,
      coachName: '',
      rank: '',
      bodyPadding: "10 10 10 10",
      referenceHolder: true,
      initComponent: function () {
        // RankStore.load();
        Ext.apply(this, {
          items: [{
            xtype: 'form',
            layout: {
              type: 'table',
              tableAttrs : {
                    style : {
                        width : '100%',
                        height : '100%'
                    }
                },
                tdAttrs : {
                    // align : 'center',
                    valign : 'middle',
                },
              columns: 2
            },
            bodyPadding: "10 10 10 10",
            border: false,
            reference: 'coach_rank',
            items: [{
                xtype: 'displayfield',
                value: this.coachName,
                fieldLabel: '教练账号',
                colspan: 2,
              }, {
                xtype: 'combobox',
                name: 'coachRank',
                allowBlank: false,
                fieldLabel: '教练等级',
                store: RankStore,
                value: this.rank,
                queryMode: 'remote',
                displayField: 'rank',
                valueField: 'id',
                editable: false,
                colspan: 2,
                listeners: {
                  scope: this,
                  change: function  (newValue , oldValue , eOpts ) {
                    var ref = this.getReferences();
                    var rank = RankStore.findRecord('id', newValue.value).data;

                    setComboClassNum(ref, rank);
                  },
                  beforerender: function (){
                    var ref = this.getReferences();
                    var rank = RankStore.findRecord('id', this.rank).data;
                    setComboClassNum(ref, rank);
                  }
                }
              }, {
                xtype: 'displayfield',
                // value: 1,
                reference: 'spring_base_num',
                fieldLabel: '春秋基本带班数',
              }, {
                xtype: 'displayfield',
                // value: 1,
                reference: 'spring_max_num',
                fieldLabel: '春秋最大带班数',
              }, {
                xtype: 'displayfield',
                // value: 1,
                reference: 'winter_base_num',
                fieldLabel: '寒暑基本带班数',
              }, {
                xtype: 'displayfield',
                // value: 1,
                reference: 'winter_max_num',
                fieldLabel: '寒暑最大带班数',
              }]
          }],
          buttons: [{
            text: '确定',
            scope: this,
            handler: function (button, e) {
              // var form = Ext.getCmp('coach_rank').getForm();
              // console.log(this.lookupReference('spring_base_num'));
              var form = this.getReferences().coach_rank;
              if (!form.isValid()){
                return;
              }
              url = '/tutor/ajax/set_coach_class_num';
              form.submit({
                scope: this,
                waitMsg: '操作处理中...',
                url: url,
                params: {'coachName': this.coachName},
                success: function (form, action) {
                  Ext.toast({
                    html: '操作成功',
                    closable: false,
                    align: 't',
                    slideInDuration: 400,
                    minWidth: 400
                  });
                  this.close();
                  coachStore.reload();
                },
                failure: function (form, action) {
                  Ext.MessageBox.show({
                    msg: '操作失败，请您重试',
                    icon: Ext.MessageBox.ERROR
                  });
                }
              });
            }
          }, {
            text: '取消',
            scope: this,
            handler: function(button, e){
              this.close();
            }
          }]
        });
        this.callParent();
      }
    });

    Ext.define('ClassNum.Form', {
      extend: 'Ext.window.Window',
      xtype: 'class-num-form',
      title: '设定带班数',
      layout: 'fit',
      width: 650,
      height: 250,
      modal: true,
      referenceHolder: true,
      // bodyPadding: "10 10 10 10",
      initComponent: function () {
        // RankStore.load();
        Ext.apply(this, {
          items: [{
            id: 'class_num_grid',
            xtype: 'grid',
            layout: {
              type: 'fit',
              align: 'center'
            },
            store: RankStore,
            border: false,
            rowLines: false,
            columnLines: false,
            scrollable: false,
            reference: 'class_num',
            columns: [{
                text: '等级',
                dataIndex: 'rank',
                width: 50,
                align: 'center'
              }, {
                text: '春秋基本带班数',
                dataIndex: 'spring_base_num',
                width: 150,
                editor: {
                  xtype: 'numberfield',
                  minValue: 1,
                  allowDecimals: false,
                },
                align: 'center',
              }, {
                text: '春秋最大带班数',
                dataIndex: 'spring_max_num',
                width: 150,
                editor: {
                  xtype: 'numberfield',
                  minValue: 1,
                  allowDecimals: false,
                },
                align: 'center',
              }, {
                text: '寒暑基本带班数',
                dataIndex: 'winter_base_num',
                width: 150,
                editor: {
                  xtype: 'numberfield',
                  minValue: 1,
                  allowDecimals: false,
                },
                align: 'center',
              }, {
                text: '寒暑基本带班数',
                dataIndex: 'winter_max_num',
                width: 150,
                editor: {
                  xtype: 'numberfield',
                  minValue: 1,
                  allowDecimals: false,
                },
                align: 'center',
                minValue: 1,
            }],
            selType: 'cellmodel',
            plugins: {
              ptype: 'cellediting',
              clicksToEdit: 1,
              listeners: {
                scope: this,
                edit : function (editor , context , eOpts) {
                  // console.log(context)
                  // console.log(context.record.data)
                  // var rank = context.record.data;
                  // var ref = this.getReferences()
                  // var submit_button = ref.submit;
                  // var class_num = ref.class_num;
                  // if(context.field.indexOf('spring') != -1) {
                  //   if (rank.spring_max_num < rank.spring_base_num){
                  //     console.log('spring');
                  //     submit_button.setDisabled(true);
                  //     return;
                  //   }
                  // }else if (context.field.indexOf('winter') != -1){
                  //   if (rank.winter_max_num < rank.winter_base_num){
                  //     console.log('winter');
                  //     submit_button.setDisabled(true);
                  //     return;
                  //   }
                  // }else{
                  //   console.log('there is no winter or spring in field')
                  // }
                }
              }
            },
          }],
          buttons: [{
              text: '确定',
              reference: 'submit',
              scope: this,
              handler: function (button, e) {
                // var ranks = RankStore.getUpdatedRecords();
                var ranks = RankStore.getRange();
                var message = '';
                for (rank in ranks){
                  var data = ranks[rank].data;
                  if (data.spring_max_num < data.spring_base_num) {
                    message += data.rank + '等级春秋基本带班数大于最大带班数;' + '<br><br>';
                  }
                  if (data.winter_max_num < data.winter_base_num) {
                    message += data.rank + '等级寒暑基本带班数大于最大带班数;' + '<br><br>';
                  }
                }
                if (message){
                  message += '请修改后提交！'
                  Ext.toast({
                    html: message,
                    closable: false,
                    align: 't',
                    slideInDuration: 400,
                    minWidth: 400
                  });
                  // this.getReferences().submit.setDisabled(true);
                  return;
                }
                RankStore.sync({
                  success: function(batch, options){
                    Ext.toast({
                      html: '更新成功！',
                      closable: false,
                      align: 't',
                      slideInDuration: 400,
                      minWidth: 400
                    });
                  },
                  failure: function(batch, options){
                    var message = batch.proxy.reader.rawData.message;
                    Ext.toast({
                      html: message,
                      closable: false,
                      align: 't',
                      slideInDuration: 400,
                      minWidth: 400
                    });
                  }
                });
                this.close();

                // RankStore.commitChanges(); // client-side-only
                // console.log(RankStore.getRange());
              }
            }, {
              text: '取消',
              scope: this,
              handler: function(button, e){
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
        title: '教练列表',
        store: coachStore,
        layout: 'fit',
        referenceHolder: true,
        _searchWin: null,
        columns: [
          {
            text: '用户名',
            dataIndex: 'userName',
            width: 150,
            align: 'left'
          }, {
            text: '姓名',
            dataIndex: 'realName',
            width: 100,
            align: 'left',
            flex: 1
          }, {
            text: '省/市/区',
            dataIndex: 'areaDisplay',
            width: 100,
            align: 'left',
            flex: 1
          }, {
            text: '学校',
            dataIndex: 'schoolName',
            width: 200,
            align: 'left',
            flex: 1
          }, {
            text: '年级',
            dataIndex: 'gradeType',
            renderer: getGradeTypeName,
            width: 100,
            flex: 1,
            align: 'center'
          }, {
            text: '科目',
            dataIndex: 'subjectId',
            renderer: getSubjectName,
            width: 100,
            flex: 1,
            align: 'center'
          }, {
            text: '手机',
            dataIndex: 'phone',
            flex: 1,
            align: 'center'
          }, {
            text: 'QQ号',
            dataIndex: 'qq',
            flex: 1,
            align: 'center'
          }, {
            text: '状态',
            dataIndex: 'jobStatus',
            renderer: getCoachJobStatusText,
            flex: 1,
            align: 'center'
          }, {
            text: '等级',
            dataIndex: 'rank',
            renderer: getRankText,
            flex: 1,
            align: 'center'
          }],
        dockedItems: [{
          dock: 'top',
          xtype: 'toolbar',
          items: [{
            text: '批量导入',
            iconCls: 'icon-add',
            handler: function () {
              var win = Ext.create('CoachImport.Form', {});
              win.show();
            }
          }, {
            reference: 'dismissButton',
            text: '解聘',
            iconCls: 'icon-delete',
            disabled: true,
            handler: function () {
              var selection = grid.getSelection();
              if (!selection.length) {
                return;
              }
              var win = Ext.create('CoachDismiss.Form', {coachName: selection[0].data.userName});
              win.show();
            }
          }, '-', {
            reference: 'trainingButton',
            text: '再培',
            iconCls: 'icon-edit',
            disabled: true,
            handler: function () {
              var selection = grid.getSelection();
              if (!selection.length) {
                return;
              }
              var win = Ext.create('CoachRetrain.Form', {coachName: selection[0].data.userName});
              win.show();
            }
          }, {
            reference: 'cancelTrainingButton',
            text: '恢复',
            iconCls: 'icon-edit',
            disabled: true,
            handler: function () {
              var selection = grid.getSelection();
              if (!selection.length) {
                return;
              }
              Ext.MessageBox.confirm('确认', '请确认是否对教练：' + selection[0].data.userName + '进行恢复？', function (btn) {
                if (btn === 'yes') {
                  Ext.Ajax.request({
                    url: '/tutor/ajax/cancel_coach_retraining',
                    params: {
                      'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken"),
                      'coachName': selection[0].data.userName
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
                      coachStore.reload();
                      }
                      else{
                        Ext.toast({
                        html: '操作失败',
                        closable: false,
                        align: 't',
                        slideInDuration: 400,
                        minWidth: 400
                      });
                      coachStore.reload();
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
              });
            }
          }, '-', {
            text: '筛选',
            iconCls: 'icon-search',
            handler: function () {
              this._searchWin = this._searchWin || Ext.create('CoachSearch.Form', {});
              this._searchWin.show();
              var ref = grid.getReferences();
              ref.clearSearchButton.setDisabled(false);
            }
          }, {
            reference: 'clearSearchButton',
            text: '取消筛选',
            iconCls: 'icon-reset',
            disabled: true,
            handler: function () {
              coachStore.getProxy().extraParams = [];
              coachStore.currentPage = 1;
              coachStore.load();
              var ref = grid.getReferences();
              ref.clearSearchButton.setDisabled(true);
            }
          }, {
            reference: 'setRank',
            text: '设定等级',
            iconCls: 'icon-edit',
            disabled: true,
            handler: function () {
              var selection = grid.getSelection();
              if (!selection.length) {
                return;
              }
              var coach = selection[0].data;
              var win = Ext.create('CoachRank.Form', {coachName: coach.userName, rank: coach.rank});
              win.show();
            }
          }, {
            reference: 'setClassNum',
            text: '设定带班数',
            iconCls: 'icon-edit',
            handler: function () {
              var win = Ext.create('ClassNum.Form', {});
              win.show();
            }
          }]
        }, {
          xtype: 'pagingtoolbar',
          store: coachStore, // same store GridPanel is using
          dock: 'bottom',
          displayInfo: true
        }],
        listeners: {
          select: {
            scope: grid,
            fn: function (component, record, index, eOpts) {
              var jobStatus = record.data.jobStatus;
              var ref = this.getReferences();
              ref.setRank.setDisabled(false);
              if (jobStatus < 0) {
                ref.dismissButton.setDisabled(true);
                ref.trainingButton.setDisabled(true);
                ref.cancelTrainingButton.setDisabled(true);
              } else if (jobStatus < 1) {
                ref.trainingButton.setDisabled(true);
                ref.cancelTrainingButton.setDisabled(false);
              } else {
                ref.dismissButton.setDisabled(false);
                ref.trainingButton.setDisabled(false);
                ref.cancelTrainingButton.setDisabled(true);
              }
            }
          }
          ,
          'rowdblclick': function (view, record, item, index, e) {
            var base_info = record.data;
            this._coach_info_window = Ext.create('CoachInformation.Form', {base_info: base_info});
            this._coach_info_window.show();
            var ref = grid.getReferences();
            //ref.clearSearchButton.setDisabled(false);
          }
        }
      });
      periodStore.load();
      RankStore.load();
      Ext.on('resize', function () {
        if (grid) {
          if (grid.getView()) {
            grid.getView().refresh();
          }
        }
      });
      coachStore.load(function () {
        grid.getView().refresh();
      });
    });
  })();
</script>
{% endblock %}
