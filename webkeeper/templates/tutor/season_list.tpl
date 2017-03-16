{% extends 'common/base_layout.tpl' %}
{% block title %}学季列表{% endblock %}
{% block page_style %}
  <link rel="stylesheet" type="text/css"
        href="{{ static('assets/plugins/extjs/writer.css') }}"/>
{% endblock %}
{% block bottom_js %}
  <script type="text/javascript" src="{{ static('assets/js/tutor/common.js') }}"></script>
  <script type="text/javascript" src="{{ static('assets/js/tutor/stores.js') }}"></script>
  <script type="text/javascript">
    (function () {
      function getYearName(year) {
        return getSeasonYearName(year);
      }

      function renderName(value, p, record) {
        return getSeasonName(record.data.year, record.data.seasonType);
      }

      function renderDays(value, p, record) {
        var data = record.data;
        return data.startDay + '至' + data.endDay;
      }

      function renderExceptDays(value, p, record) {
        return value.join(',');
      }

      function getExceptDays(start, end) {
        var data = [];
        for (var day = start; day <= end; day = Ext.Date.add(day, Ext.Date.DAY, 1)) {
          data.push([Ext.Date.format(day, 'Y-m-d'), Ext.Date.format(day, 'Y-m-d D')]);
        }
        return data;
      }

      function getCurrentStudyYear() {
        var now = new Date();
        var year = now.getFullYear();
        var month = now.getMonth() + 1; // 注意：getMonth()函数返回的月份是从0开始计数的。
        return month < 9 ? year - 1 : year; // 9月前还属于上一个学年。
      }

      function getStudyYears() {
        var currentYear = getCurrentStudyYear();
        var range = 3;
        var result = [];
        for (var i = 0; i < range; ++i) {
          var year = currentYear + i;
          result.push([year, year + '-' + (year + 1)]);
        }
        return result;
      }

      Ext.define('Season.Form', {
        extend: 'Ext.window.Window',
        xtype: 'season-form',

        title: '学季',
        width: 600,
        height: 500,
        minWidth: 300,
        minHeight: 220,
        layout: 'fit',
        modal: true,

        isEditMode: false,

        initComponent: function () {
          this.exceptDaysStore = Ext.create('Ext.data.ArrayStore', {
            storeId: 'except_days_store',
            fields: [
              {name: 'day', type: 'string'},
              {name: 'text', type: 'string'}
            ],
            data: []
          });
          this.startDay = null;
          this.endDay = null;

          this.studyYearsStore = Ext.create('Ext.data.ArrayStore', {
            storeId: 'study_years_store',
            fields: [
              {name: 'year', type: 'number'},
              {name: 'text', type: 'string'}
            ],
            data: getStudyYears()
          });

          this.seasonTypeStore = Ext.create('Ext.data.ArrayStore', {
            storeId: 'season_type_store',
            fields: [
              {name: 'season_type', type: 'number'},
              {name: 'text', type: 'string'}
            ],
            data: [
              [1, '秋季'],
              [2, '寒假'],
              [3, '春季'],
              [4, '暑假']
            ]
          });

          Ext.apply(this, {
            items: [{
              id: 'season_form',
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
                fieldLabel: '学年',
                name: 'year',
                store: this.studyYearsStore,
                valueField: 'year',
                queryMode: 'local',
                editable: false,
                allowBlank: false
              }, {
                xtype: 'combobox',
                fieldLabel: '学季类型',
                name: 'seasonType',
                store: this.seasonTypeStore,
                valueField: 'season_type',
                queryMode: 'local',
                editable: false,
                allowBlank: false
              }, {
                xtype: 'fieldcontainer',
                fieldLabel: '开放日期',
                layout: 'hbox',
                defaultType: 'datefield',
                defaults: {
                  hideLabel: 'true'
                },
                items: [{
                  id: 'start_day',
                  name: 'startDay',
                  allowBlank: false,
                  editable: false,
                  format: 'Y-m-d',
                  vtype: 'daterange',
                  endDateField: 'end_day',
                  listeners: {
                    change: {
                      scope: this,
                      fn: function (component, newValue, oldValue, eOpts) {
                        this.startDay = newValue;
                        this.freshExceptDaysStore();
                      }
                    }
                  }
                }, {
                  xtype: 'displayfield',
                  margin: '2 5 0 5',
                  value: '至'
                }, {
                  id: 'end_day',
                  name: 'endDay',
                  allowBlank: false,
                  editable: false,
                  format: 'Y-m-d',
                  vtype: 'daterange',
                  startDateField: 'start_day',
                  listeners: {
                    change: {
                      scope: this,
                      fn: function (component, newValue, oldValue, eOpts) {
                        this.endDay = newValue;
                        this.freshExceptDaysStore();
                      }
                    }
                  }
                }]
              }, {
                xtype: 'fieldcontainer',
                fieldLabel: '排除日期',
                layout: {
                  type: 'hbox',
                  align: 'stretch'
                },
                items: [{
                  id: 'except_days',
                  xtype: 'tagfield',
                  name: 'exceptDays',
                  valueField: 'day',
                  filterPickList: true,
                  multiSelect: true,
                  queryMode: 'local',
                  flex: 1,
                  store: this.exceptDaysStore
                }]
              }]
            }],

            buttons: [{
              text: '确定',
              scope: this,
              handler: function (button, e) {
                var form = Ext.getCmp('season_form').getForm();
                if (!form.isValid()) {
                  return;
                }
                var url = this.isEditMode ? '/tutor/ajax/edit_season' : '/tutor/ajax/add_season';
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
                      seasonStore.reload();
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

        freshExceptDaysStore: function () {
          if (!this.startDay || !this.endDay) {
            return;
          }
          if (this.startDay > this.endDay) {
            return;
          }
          var data = getExceptDays(this.startDay, this.endDay);
          this.exceptDaysStore.loadData(data);
        },

        initFormData: function (record) {
          var form = Ext.getCmp('season_form').getForm();
          form.loadRecord(record);
          Ext.getCmp('except_days').setValue(record.data.exceptDays);
        }

      });

      Ext.onReady(function () {

        seasonStore.load();

        var grid = Ext.create('Ext.grid.Panel', {
          renderTo: Ext.getBody(),
          title: '学季列表',
          store: seasonStore,
          layout: 'fit',
          referenceHolder: true,
          columns: [
            {
              text: "编号",
              dataIndex: 'id',
              width: 100,
              align: 'center'
            }, {
              text: '学季',
              width: 200,
              align: 'left',
              flex: 1,
              sortable: false,
              renderer: renderName
            }, {
              text: '学年',
              dataIndex: 'year',
              renderer: getYearName,
              width: 150,
              flex: 1,
              align: 'center'
            }, {
              text: '学季类型',
              dataIndex: 'seasonType',
              renderer: getSeasonTypeName,
              flex: 1,
              align: 'center'
            }, {
              text: '开放日期',
              dataIndex: 'startDay',
              renderer: renderDays,
              flex: 1,
              align: 'center'
            }, {
              text: '排除日期',
              dataIndex: 'exceptDays',
              renderer: renderExceptDays,
              flex: 1,
              align: 'left'
            }],
          dockedItems: [{
            dock: 'top',
            xtype: 'toolbar',
            items: [{
              text: '添加学季',
              iconCls: 'icon-add',
              handler: function () {
                var win = Ext.create('Season.Form', {});
                win.show();
              }
            }, {
              reference: 'editSeasonButton',
              text: '编辑学季',
              iconCls: 'icon-edit',
              disabled: true,
              handler: function () {
                var selection = grid.getSelection();
                if (!selection.length) {
                  return;
                }
                var win = Ext.create('Season.Form', { isEditMode: true });
                win.initFormData(selection[0]);
                win.show();
              }
            }, '-', {
              reference: 'deleteSeasonButton',
              text: '删除学季',
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
                      url: '/tutor/ajax/delete_season',
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
                          seasonStore.reload();
                        } else {
                          Ext.MessageBox.show({
                            msg: '已关联班型，不允许删除',
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
            store: seasonStore, // same store GridPanel is using
            dock: 'bottom',
            displayInfo: true
          }],
          listeners: {
            select: {
              scope: grid,
              fn: function (component, record, index, eOpts) {
                var ref = this.getReferences();
                ref.editSeasonButton.setDisabled(false);
                ref.deleteSeasonButton.setDisabled(false);
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
      });
    })();
  </script>
{% endblock %}
