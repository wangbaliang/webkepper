{% extends 'common/base_layout.tpl' %}
{% block title %}时段列表{% endblock %}
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

      Ext.define('PeriodAdd.Form', {
        extend: 'Ext.window.Window',
        xtype: 'period-add-form',
        title: '时段',
        width: 550,
        height: 400,
        minWidth: 450,
        minHeight: 400,
        layout: 'fit',
        modal: true,

        initComponent: function () {
          this.seasonStore = getSeasonSelectStore();

          Ext.apply(this, {
            items: [{
              id: 'period_add_form',
              xtype: 'form',
              border: false,
              bodyPadding: 10,
              layout: {
                type: 'vbox',
                align: 'stretch'
              },
              items: [{
                xtype: 'hiddenfield',
                name: 'id',
                value: 0
              }, {
                xtype: 'combobox',
                fieldLabel: '学季',
                margin: '10 50 10 0',
                name: 'seasonId',
                store: this.seasonStore,
                valueField: 'id',
                queryMode: 'local',
                editable: false,
                allowBlank: false
              }, {
                xtype: 'fieldcontainer',
                fieldLabel: '年级',
                layout: 'hbox',
                defaultType: 'radiofield',
                defaults: {
                  hideLabel: 'true',
                  allowBlank: false
                },
                items:[{
                  name: 'gradeType',
                  inputValue: 1,
                  boxLabel: '初中（初一、初二、初三）',
                  value: true
                }, {
                  xtype: 'displayfield',
                  margin: '0 5 0 5',
                  value: ''
                }, {
                  name: 'gradeType',
                  inputValue: 2,
                  boxLabel: '高中（高一、高二、高三）'
                }, {
                  xtype: 'displayfield',
                  margin: '2 5 0 5',
                  value: '必填'
                }]
              },
                {
                xtype: 'fieldcontainer',
                fieldLabel: '开放时段',
                layout: 'hbox',
                defaultType: 'timefield',
                defaults: {
                  hideLabel: 'true',
                  format: 'H:i',
                  increment: 30,
                  editable: false,
                  allowBlank: false
                },
                items:[{
                  id: 'start_time1',
                  name: 'startTime1',
                  vtype: 'timerange',
                  endTimeField: 'end_time1'
                }, {
                  xtype: 'displayfield',
                  margin: '2 5 0 5',
                  value: '至'
                }, {
                  id: 'end_time1',
                  name: 'endTime1',
                  vtype: 'timerange',
                  startTimeField: 'start_time1'
                }, {
                  xtype: 'displayfield',
                  margin: '2 5 0 5',
                  value: '必填'
                }]
              },
                {
                xtype: 'fieldcontainer',
                fieldLabel: '        ',
                layout: 'hbox',
                defaultType: 'timefield',
                defaults: {
                  hideLabel: 'true',
                  format: 'H:i',
                  increment: 30,
                  editable: false,
                  allowBlank: true
                },
                items:[{
                  id: 'start_time2',
                  name: 'startTime2',
                  vtype: 'timerange',
                  endTimeField: 'end_time2'
                }, {
                  xtype: 'displayfield',
                  margin: '2 5 0 5',
                  value: '至'
                }, {
                  id: 'end_time2',
                  name: 'endTime2',
                  vtype: 'timerange',
                  startTimeField: 'start_time2'
                }]
              },
                {
                xtype: 'fieldcontainer',
                fieldLabel: '        ',
                layout: 'hbox',
                defaultType: 'timefield',
                defaults: {
                  hideLabel: 'true',
                  format: 'H:i',
                  increment: 30,
                  editable: false,
                  allowBlank: true
                },
                items:[{
                  id: 'start_time3',
                  name: 'startTime3',
                  vtype: 'timerange',
                  endTimeField: 'end_time3'
                }, {
                  xtype: 'displayfield',
                  margin: '2 5 0 5',
                  value: '至'
                }, {
                  id: 'end_time3',
                  name: 'endTime3',
                  vtype: 'timerange',
                  startTimeField: 'start_time3'
                }]
              },
                {
                xtype: 'fieldcontainer',
                fieldLabel: '        ',
                layout: 'hbox',
                defaultType: 'timefield',
                defaults: {
                  hideLabel: 'true',
                  format: 'H:i',
                  increment: 30,
                  editable: false,
                  allowBlank: true
                },
                items:[{
                  id: 'start_time4',
                  name: 'startTime4',
                  vtype: 'timerange',
                  endTimeField: 'end_time4'
                }, {
                  xtype: 'displayfield',
                  margin: '2 5 0 5',
                  value: '至'
                }, {
                  id: 'end_time4',
                  name: 'endTime4',
                  vtype: 'timerange',
                  startTimeField: 'start_time4'
                }]
              },
                {
                xtype: 'fieldcontainer',
                fieldLabel: '        ',
                layout: 'hbox',
                defaultType: 'timefield',
                defaults: {
                  hideLabel: 'true',
                  format: 'H:i',
                  increment: 30,
                  editable: false,
                  allowBlank: true
                },
                items:[{
                  id: 'start_time5',
                  name: 'startTime5',
                  vtype: 'timerange',
                  endTimeField: 'end_time5'
                }, {
                  xtype: 'displayfield',
                  margin: '2 5 0 5',
                  value: '至'
                }, {
                  id: 'end_time5',
                  name: 'endTime5',
                  vtype: 'timerange',
                  startTimeField: 'start_time5'
                }]
              },
                {
                xtype: 'fieldcontainer',
                fieldLabel: '        ',
                layout: 'hbox',
                defaultType: 'timefield',
                defaults: {
                  hideLabel: 'true',
                  format: 'H:i',
                  increment: 30,
                  editable: false,
                  allowBlank: true
                },
                items:[{
                  id: 'start_time6',
                  name: 'startTime6',
                  vtype: 'timerange',
                  endTimeField: 'end_time6'
                }, {
                  xtype: 'displayfield',
                  margin: '2 5 0 5',
                  value: '至'
                }, {
                  id: 'end_time6',
                  name: 'endTime6',
                  vtype: 'timerange',
                  startTimeField: 'start_time6'
                }]
              }
              ]
            }],

            buttons: [{
              text: '确定',
              scope: this,
              handler: function (button, e) {
                var form = Ext.getCmp('period_add_form').getForm();
                if (!form.isValid()) {
                  return;
                }
                var url = '/tutor/ajax/add_period';
                form.submit({
                    scope: this,
                    waitMsg: '操作处理中...',
                    url: url,
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
                      periodStore.reload();
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
              handler: function (button, e) {
                this.close();
              }
            }]
          });
          this.callParent();
        },
      });
      Ext.define('PeriodEdit.Form', {
        extend: 'Ext.window.Window',
        xtype: 'period-edit-form',

        title: '时段',
        width: 500,
        height: 300,
        minWidth: 300,
        minHeight: 220,
        layout: 'fit',
        modal: true,

        initComponent: function () {
          this.seasonStore = getSeasonSelectStore();

          Ext.apply(this, {
            items: [{
              id: 'period_edit_form',
              xtype: 'form',
              border: false,
              bodyPadding: 10,
              layout: {
                type: 'vbox',
                align: 'stretch'
              },
              items: [{
                xtype: 'hiddenfield',
                name: 'id',
                value: 0
              }, {
                xtype: 'combobox',
                fieldLabel: '学季',
                name: 'seasonId',
                store: this.seasonStore,
                valueField: 'id',
                queryMode: 'local',
                editable: false,
                allowBlank: false
              }, {
                xtype: 'fieldcontainer',
                fieldLabel: '年级',
                layout: 'hbox',
                defaultType: 'radiofield',
                defaults: {
                  hideLabel: 'true',
                  allowBlank: false
                },
                items:[{
                  name: 'gradeType',
                  inputValue: 1,
                  boxLabel: '初中（初一、初二、初三）',
                  value: true
                }, {
                  xtype: 'displayfield',
                  margin: '0 5 0 5',
                  value: ''
                }, {
                  name: 'gradeType',
                  inputValue: 2,
                  boxLabel: '高中（高一、高二、高三）'
                }]
              }, {
                xtype: 'fieldcontainer',
                fieldLabel: '开放时段',
                layout: 'hbox',
                defaultType: 'timefield',
                defaults: {
                  hideLabel: 'true',
                  format: 'H:i',
                  increment: 30,
                  editable: false,
                  allowBlank: false
                },
                items:[{
                  id: 'start_time',
                  name: 'startTime',
                  vtype: 'timerange',
                  endTimeField: 'end_time'
                }, {
                  xtype: 'displayfield',
                  margin: '2 5 0 5',
                  value: '至'
                }, {
                  id: 'end_time',
                  name: 'endTime',
                  vtype: 'timerange',
                  startTimeField: 'start_time'
                }]
              }]
            }],

            buttons: [{
              text: '确定',
              scope: this,
              handler: function (button, e) {
                var form = Ext.getCmp('period_edit_form').getForm();
                if (!form.isValid()) {
                  return;
                }
                var url = '/tutor/ajax/edit_period';
                form.submit({
                    scope: this,
                    waitMsg: '操作处理中...',
                    url: url,
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
                      periodStore.reload();
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
              handler: function (button, e) {
                this.close();
              }
            }]
          });
          this.callParent();
        },

        initFormData: function (record) {
          var form = Ext.getCmp('period_edit_form').getForm();
          form.loadRecord(record);
        }

      });


      Ext.onReady(function () {
        var grid = Ext.create('Ext.grid.Panel', {
          renderTo: Ext.getBody(),
          title: '时段列表',
          store: periodStore,
          layout: 'fit',
          referenceHolder: true,
          columns: [
            {
              text: '编号',
              dataIndex: 'id',
              width: 100,
              align: 'center'
            }, {
              text: '学季',
              dataIndex: 'seasonId',
              width: 200,
              align: 'left',
              flex: 1,
              sortable: false,
              renderer: renderSeason
            }, {
              text: '年级',
              dataIndex: 'gradeType',
              renderer: getGradeTypeName,
              width: 150,
              flex: 1,
              align: 'center'
            }, {
              text: '时段',
              dataIndex: 'startTime',
              renderer: renderPeriod,
              flex: 1,
              align: 'center'
            }],
          dockedItems: [{
            dock: 'top',
            xtype: 'toolbar',
            items: [{
              text: '添加时段',
              iconCls: 'icon-add',
              handler: function () {
                var win = Ext.create('PeriodAdd.Form');
                win.show();
              }
            }, {
              reference: 'editButton',
              text: '编辑时段',
              iconCls: 'icon-edit',
              disabled: true,
              handler: function () {
                var selection = grid.getSelection();
                if (!selection.length) {
                  return;
                }
                var win = Ext.create('PeriodEdit.Form');
                win.initFormData(selection[0]);
                win.show();
              }
            }, '-', {
              reference: 'deleteButton',
              text: '删除时段',
              iconCls: 'icon-delete',
              disabled: true,
              handler: function () {
                var selection = grid.getSelection();
                if (!selection.length) {
                  return;
                }
                Ext.MessageBox.confirm('确认删除', '请确认是否删除该数据。', function (btn) {
                  if (btn === 'yes') {
                    Ext.Ajax.request({
                      url: '/tutor/ajax/delete_period',
                      params: {
                        'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken"),
                        id: selection[0].data.id
                      },
                      success: function(response){
                        var result = JSON.parse(response.responseText);
                        if (result.success) {
                          Ext.toast({
                            html: '操作成功',
                            closable: false,
                            align: 't',
                            slideInDuration: 400,
                            minWidth: 400
                          });
                          periodStore.reload();
                        } else {
                          Ext.MessageBox.show({
                            msg: '时段已关联班型，不允许删除',
                            icon: Ext.MessageBox.ERROR
                          });
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
            }]
          }, {
            xtype: 'pagingtoolbar',
            store: periodStore, // same store GridPanel is using
            dock: 'bottom',
            displayInfo: true
          }],
          listeners: {
            select: {
              scope: grid,
              fn: function (component, record, index, eOpts) {
                var ref = this.getReferences();
                ref.editButton.setDisabled(false);
                ref.deleteButton.setDisabled(false);
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
        seasonStore.load(function () {
          periodStore.load(function () {
            grid.getView().refresh();
          });
        });
      });
    })();
  </script>
{% endblock %}
