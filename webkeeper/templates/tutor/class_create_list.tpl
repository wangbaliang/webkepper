{% extends 'common/base_layout.tpl' %}
{% block title %}班型列表{% endblock %}
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

      function renderPeriod(value, p, record) {
        return record.data.startTime + ' ~ ' + record.data.endTime;
      }

      function rowStyle(record, rowIndex, rowParams, store) {
        if (record.get('isNear')) {
          return 'x-grid-record-near';
        }
      }

      function renderInviteStatus(value, p, record) {
        switch (value) {
          case 0: return '未回应';
          case 1: return '已接受';
          case 2: return '已完成测试';
          case -1: return '已拒绝';
          case -2: return '已过期';
          case -3: return '已取消';
        }
        return '';
      }

      function getInviteGrid(taskId) {
        var grid = Ext.create('Ext.grid.Panel', {
          store: classCreateTaskInviteStore,
          layout: 'fit',
          referenceHolder: true,
          height: 420,
          scrollable: true,
          columns: [
            {
              text: '编号',
              dataIndex: 'id',
              width: 50,
              align: 'center'
            }, {
              text: '邀请时间',
              dataIndex: 'inviteTime',
              width: 100,
              flex: 1
            }, {
              text: '教练',
              dataIndex: 'coach',
              width: 100,
              align: 'left',
              flex: 1
            }, {
              text: '电话',
              dataIndex: 'coachPhone',
              width: 200,
              align: 'left',
              flex: 1
            }, {
              text: '邀请状态',
              dataIndex: 'inviteStatus',
              renderer: renderInviteStatus,
              flex: 1,
              align: 'center'
            }],
          dockedItems: [{
            dock: 'top',
            xtype: 'toolbar',
            items: [{
              reference: 'cancelButton',
              text: '取消邀请',
              iconCls: 'icon-delete',
              disabled: true,
              handler: function () {
                var selection = grid.getSelection();
                if (!selection.length) {
                  return;
                }
                var data = selection[0].data;
                Ext.MessageBox.confirm('确认取消邀请', '请确认是否取消对教练：' + data.coach + '的邀请？', function (btn) {
                  if (btn === 'yes') {
                    Ext.Ajax.request({
                      url: '/tutor/ajax/cancel_invite_coach',
                      params: {
                        'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken"),
                        taskId: data.taskId,
                        coachName: data.coach
                      },
                      success: function(response){
                        Ext.toast({
                          html: '操作成功',
                          closable: false,
                          align: 't',
                          slideInDuration: 400,
                          minWidth: 400
                        });
                        classCreateTaskInviteStore.reload();
                        grid.getReferences().cancelButton.setDisabled(true);
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
            }]
          }],
          listeners: {
            select: {
              scope: grid,
              fn: function (component, record, index, eOpts) {
                var ref = this.getReferences();
                if (record.data.inviteStatus >= 0) {
                  ref.cancelButton.setDisabled(false);
                } else {
                  ref.cancelButton.setDisabled(true);
                }
              }
            }
          }
        });
        classCreateTaskInviteStore.load({
          scope: this,
          params: {'taskId': taskId},
          callback: function () {
          }
        });
        return grid;
      }

      function getSuccessInviteGrid(taskId) {
        var grid = Ext.create('Ext.grid.Panel', {
          store: succcessClassCreateTaskInviteStore,
          layout: 'fit',
          referenceHolder: true,
          height: 420,
          scrollable: true,
          columns: [
            {
              text: '教师账号',
              dataIndex: 'coach',
              width: 200,
              align: 'left'
            }, {
              text: '姓名',
              dataIndex: 'coachRealName',
              width: 100,
              flex: 1
            }]
        });
        succcessClassCreateTaskInviteStore.load({
          scope: this,
          params: {'taskId': taskId},
          callback: function () {
          }
        });
        return grid;
      }

      function getStudentGrid(taskId) {
        var grid = Ext.create('Ext.grid.Panel', {
          store: taskStudentStore,
          layout: 'fit',
          referenceHolder: true,
          height: 420,
          scrollable: true,
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
              align: 'left'
            }, {
              text: '所在地区',
              dataIndex: 'areaDisplay',
              width: 200,
              align: 'left',
              flex: 1
            }, {
              text: '学校',
              dataIndex: 'schoolName',
              width: 200,
              align: 'left',
              flex: 1
            }]
        });
        taskStudentStore.load({
          scope: this,
          params: {'taskId': taskId},
          callback: function () {
          }
        });
        return grid;
      }

      Ext.define('ViewClassCreateAdmin.Form', {
        extend: 'Ext.window.Window',
        xtype: 'classcreateadmin-view-form',

        title: '详情',
        width: 800,
        height: 600,
        minWidth: 600,
        minHeight: 500,
        modal: true,

        initComponent: function () {
          var taskData = this.taskData;

          Ext.apply(this, {
            items: [{
              id: 'class_create_task_detail_form',
              height: 50,
              xtype: 'form',
              border: false,
              bodyPadding: 10,
              layout: {
                type: 'vbox',
                align: 'begin'
              },
              items: [{
                xtype: 'container',
                defaultType: 'displayfield',
                layout: 'hbox',
                items: [{
                  fieldLabel: '年级',
                  name: 'grade',
                  value: getGradeName(taskData.grade),
                  align: 'left',
                  labelAlign: 'right',
                  labelWidth: 30
                }, {
                  fieldLabel: '科目',
                  name: 'subject',
                  value: getSubjectName(taskData.subjectId),
                  labelAlign: 'right',
                  labelWidth: 60
                }, {
                  fieldLabel: '开班日期',
                  name: 'day',
                  value: taskData.classDay,
                  labelAlign: 'right',
                  labelWidth: 80
                }, {
                  fieldLabel: '时段',
                  name: 'period',
                  value: taskData.startTime + '-' + taskData.endTime,
                  labelAlign: 'right',
                  labelWidth: 60
                }, {
                  fieldLabel: '需组班数量',
                  name: 'period',
                  value: taskData.newClassNum,
                  labelAlign: 'right',
                  labelWidth: 90
                }, {
                  fieldLabel: '已通过测试教师',
                  name: 'period',
                  value: taskData.testSuccessCoachNum,
                  labelAlign: 'right',
                  labelWidth: 120
                }]
              }]
            }, {
              xtype: 'tabpanel',
              layout: 'fit',
              height: 470,
              defaults: {
                bodyPadding: 10
              },
              items: [{
                title: '邀请记录',
                items: [
                  this.inviteGrid
                ]
              }, {
                title: '已确认',
                items: [
                  this.teacherGrid
                ]
              }, {
                title: '报名学员',
                items: [
                  this.studentGrid
                ]
              }]
            }],

            buttons: []
          });
          this.callParent();
        }
      });

      Ext.define('InviteCoach.Form', {
        extend: 'Ext.window.Window',
        xtype: 'invite-coach-form',

        title: '详情',
        width: 500,
        height: 300,
        minWidth: 500,
        minHeight: 300,
        modal: true,

        initComponent: function () {
          var taskData = this.taskData;

          Ext.apply(this, {
            items: [{
              id: 'invite_coach_form',
              xtype: 'form',
              border: false,
              bodyPadding: 10,
              layout: {
                type: 'vbox',
                align: 'stretch'
              },
              items: [{
                xtype: 'hiddenfield',
                name: 'taskId',
                value: taskData.id
              }, {
                xtype: 'displayfield',
                fieldLabel: '任务编号',
                value: taskData.id
              }, {
                xtype: 'displayfield',
                fieldLabel: '班型',
                value: getGradeName(taskData.grade) + '/' + getSubjectName(taskData.subjectId) + '/' + taskData.startTime + '-' + taskData.endTime
              }, {
                xtype: 'displayfield',
                fieldLabel: '开课日期',
                value: taskData.classDay
              }, {
                xtype: 'textfield',
                name: 'coachName',
                fieldLabel: '邀请教练',
                allowBlank: false
              }]
            }],

            buttons: [{
              text: '确定',
              scope: this,
              handler: function (button, e) {
                var form = Ext.getCmp('invite_coach_form').getForm();
                if (!form.isValid()) {
                  return;
                }
                Ext.MessageBox.confirm('确认', '请确认是邀请教练？', function (btn) {
                  if (btn === 'yes') {
                    form.submit({
                      scope: this,
                      waitMsg: '操作处理中...',
                      url: '/tutor/ajax/invite_coach',
                      params: { 'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken") },
                      success: function (form, action) {
                        Ext.toast({
                          html: '操作成功',
                          closable: false,
                          align: 't',
                          slideInDuration: 400,
                          minWidth: 400
                        });
                        this.close();
                      },
                      failure: function (form, action) {
                        Ext.MessageBox.show({
                          msg: action.result ? action.result.message : '服务器出错，请检查后重试',
                          icon: Ext.MessageBox.ERROR
                        });
                      }
                    });
                  }
                });
              }
            }]
          });
          this.callParent();
        }
      });

      Ext.onReady(function () {
        var grid = Ext.create('Ext.grid.Panel', {
          renderTo: Ext.getBody(),
          title: '待组班列表',
          store: classCreateTaskStore,
          layout: 'fit',
          referenceHolder: true,
          _searchWin: null,
          viewConfig:{ getRowClass: rowStyle },
          columns: [
            {
              text: '编号',
              dataIndex: 'id',
              width: 100,
              align: 'center'
            }, {
              text: '年级',
              dataIndex: 'grade',
              renderer: getGradeName,
              width: 100,
              flex: 1,
              align: 'center'
            }, {
              text: '科目',
              dataIndex: 'subjectId',
              width: 100,
              align: 'center',
              flex: 1,
              renderer: getSubjectName
            }, {
              text: '开班日期',
              dataIndex: 'classDay',
              width: 200,
              align: 'left',
              flex: 1
            }, {
              text: '时段',
              dataIndex: 'startTime',
              renderer: renderPeriod,
              flex: 1,
              align: 'center'
            }, {
              text: '空余名额',
              dataIndex: 'remainNum',
              flex: 1,
              align: 'center'
            }, {
              text: '报名人数',
              dataIndex: 'studentNum',
              flex: 1,
              align: 'center'
            }, {
              text: '需组班数量',
              dataIndex: 'newClassNum',
              flex: 1,
              align: 'center'
            }, {
              text: '已确认教练',
              dataIndex: 'acceptCoachNum',
              flex: 1,
              align: 'center'
            }, {
              text: '完成测试教练',
              dataIndex: 'testSuccessCoachNum',
              flex: 1,
              align: 'center'
            }],
          dockedItems: [{
            dock: 'top',
            xtype: 'toolbar',
            items: [{
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
                var win = Ext.create('InviteCoach.Form', {taskData: record.data});
                win.show();
              }
            }, {
              text: '导出Excel',
              iconCls: 'icon-search',
              handler: function () {
                window.open("excel/export_class_create_tasks");
              }
            }]
          },
            {
            xtype: 'pagingtoolbar',
            store: classCreateTaskStore, // same store GridPanel is using
            dock: 'bottom',
            displayInfo: true
          }],
          listeners: {
            select: {
              scope: grid,
              fn: function (component, record, index, eOpts) {
                var ref = this.getReferences();
                if (record.data.isNear) {
                  ref.inviteButton.setDisabled(false);
                } else {
                  ref.inviteButton.setDisabled(true);
                }
              }
            },
            itemdblclick: {
              scope: grid,
              fn: function (view, record, item, index, e, eOpts) {
                var taskId = record.get('id');
                var inviteGrid = getInviteGrid(taskId);
                var teacherGrid = getSuccessInviteGrid(taskId);
                var studentGrid = getStudentGrid(taskId);
                var win = Ext.create('ViewClassCreateAdmin.Form', {
                  inviteGrid: inviteGrid, teacherGrid: teacherGrid, studentGrid: studentGrid, taskData: record.data});
                win.show();
              }
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
        classCreateTaskStore.load(function () {
           grid.getView().refresh();
        });
      });
    })();
  </script>
{% endblock %}
