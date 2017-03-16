{% extends 'common/base_layout.tpl' %}
{% block title %}教练更换{% endblock %}
{% block page_style %}
<link rel="stylesheet" type="text/css"
      href="{{ static('assets/plugins/extjs/writer.css') }}"/>
  <style>
  tr.x-grid-record-near .x-grid-td {
    background: #ffd4d4;
  }
  </style>
{% endblock %}
{% block bottom_js %}
<script type="text/javascript" src="{{ static('assets/js/tutor/common.js') }}"></script>
<script type="text/javascript" src="{{ static('assets/js/tutor/stores.js') }}"></script>
<script type="text/javascript">
    (function () {

    var renderStatus = function (status){
        if (status === -1 || status === -2){
            return '失败';
        }
        var allStaus = {0: '', 1: '待确认', 2: '待测试', 3:'已完成', 4:'失败'};
        return allStaus[status];
    }

    function rowStyle(record, rowIndex, rowParams, store) {
        var status=record.get('status')
        if (status === -1 || status === 4) {
          return 'x-grid-record-near';
        }
    }

    Ext.define('CoachInvite.Form', {
      extend: 'Ext.window.Window',
      xtype: 'coach-exchange-form',
      title: '邀请教练',
      width: 450,
      height: 150,
      minWidth: 450,
      minHeight: 150,
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
      // oldCoachInfo: {},
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
              id: 'coach_invite_form',
              xtype: 'form',
              // title: '邀请教练',
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
                  allowBlank: false,
                  labelWidth: 50,
                  anchor: '-10',
                  name: 'new_coach_user_name'
                }
              ]
            }
          ],
          buttons: [
            {
              text: '确定',
              scope: this,
              handler: function (button, e) {
                var form = Ext.getCmp('coach_invite_form').getForm();
                if (!form.isValid()) {
                  return;
                }
                var url = '/tutor/ajax/change_coach_list_invite_coach';
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
                      changeCoachTaskStore.reload();
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

    Ext.onReady(function () {
      var grid = Ext.create('Ext.grid.Panel', {
        renderTo: Ext.getBody(),
        title: '教练更换状态',
        store: changeCoachTaskStore,
        layout: 'fit',
        referenceHolder: true,
        _searchWin: null,
        viewConfig:{ getRowClass: rowStyle },
        columns: [
          {
            text: '班级ID',
            dataIndex: 'classID',
            width: 60,
            align: 'center'
          }, {
            text: '原教练',
            dataIndex: 'originCoach',
            flex: 1,
            align: 'center'
          }, {
            text: '学季',
            dataIndex: 'seasonId',
            width: 100,
            align: 'center',
            flex: 1,
            renderer: renderSeason
          }, {
            text: '年级',
            dataIndex: 'grade',
            width: 100,
            flex: 1,
            align: 'center',
            renderer: getGradeName,
          }, {
            text: '科目',
            dataIndex: 'subjectId',
            width: 100,
            align: 'center',
            flex: 1,
            renderer: getSubjectName
          }, {
            text: '循环日',
            dataIndex: 'circleDay',
            flex: 1,
            align: 'center',
            renderer: getCycleDayName
          }, {
            text: '时段',
            dataIndex: 'periodId',
            flex: 1,
            align: 'center',
            renderer: renderPeriod
          }, {
            text: '新教练',
            dataIndex: 'newCoach',
            flex: 1,
            align: 'center',
          }, {
            text: '生效日期',
            dataIndex: 'beginDate',
            flex: 1,
            align: 'center'
          }, {
            text: '状态',
            dataIndex: 'status',
            flex: 1,
            align: 'center',
            renderer: renderStatus
          }
        ],
        //下面的是一些功能按钮的创建
        dockedItems: [{
          dock: 'top',
          xtype: 'toolbar',
          items: [
            {
              reference: 'inviteButton',
              text: '邀请教师',
              iconCls: 'icon-add',
              disabled: true,
              handler: function () {
                var selection = grid.getSelection();
                if (!selection.length) {
                  return;
                }
                var record = selection[0];
                var win = Ext.create('CoachInvite.Form', {classId: record.data.classID});
                win.show();
              }
            }]
          }, {
            xtype: 'pagingtoolbar',
            store: changeCoachTaskStore, // same store GridPanel is using
            dock: 'bottom',
            displayInfo: true
          }],
          listeners: {
            select: {
              scope: grid,
              fn: function (component, record, index, eOpts) {
                var status = record.data.status;
                var ref = this.getReferences();
                if (status === -1 || status === 4) {
                  ref.inviteButton.setDisabled(false);
                } else {
                  ref.inviteButton.setDisabled(true);
                }
              }
            },
            'rowdblclick': function (view, record, item, index, e) {
              // var base_info = record.data;
              // this._student_info_window = Ext.create('ClassInformation.Form', {
              //   base_info: base_info,
              //   record: record
              // });
              // this._student_info_window.show();
              // var ref = grid.getReferences();
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
          changeCoachTaskStore.load(function () {
            grid.getView().refresh();
          });
        });
      });

    });
    })();
</script>
{% endblock %}
