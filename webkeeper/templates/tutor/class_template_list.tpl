{% extends 'common/base_layout.tpl' %}
{% block title %}班型列表{% endblock %}
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

      Ext.define('ClassTemplate.Form', {
        extend: 'Ext.window.Window',
        xtype: 'classtemplate-form',

        title: '班型',
        width: 500,
        height: 300,
        minWidth: 300,
        minHeight: 220,
        layout: 'fit',
        modal: true,
        isEditMode: false,
        initComponent: function () {
          this.seasonStore = getSeasonSelectStore();
          this.gradeStore = gradeSelectStore;
          this.subjectStore = subjectSelectStore;
          this.cycleStore = getCycleDaySelectStore();
          this.periodStore = getPeriodSelectStore();

          this.seasonId = undefined;
          this.grade = undefined;

          Ext.apply(this, {
            items: [{
              id: 'class_template_form',
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
                allowBlank: false,
                listeners: {
                  change: {
                    scope: this,
                    fn: function (component, newValue, oldValue, eOpts) {
                      this.seasonId = newValue;
                      this.refreshCycleStore();
                      this.refreshPeriodStores();
                    }
                  }
                }
              }, {
                xtype: 'combobox',
                fieldLabel: '年级',
                name: 'grade',
                store: this.gradeStore,
                valueField: 'grade',
                queryMode: 'local',
                editable: false,
                allowBlank: false,
                listeners: {
                  change: {
                    scope: this,
                    fn: function (component, newValue, oldValue, eOpts) {
                      this.grade = newValue;
                      this.refreshPeriodStores();
                    }
                  }
                }
              }, {
                xtype: 'combobox',
                fieldLabel: '科目',
                name: 'subjectId',
                store: this.subjectStore,
                valueField: 'subject',
                queryMode: 'local',
                editable: false,
                allowBlank: false
              }, {
                id: 'cycle_day',
                xtype: 'combobox',
                fieldLabel: '循环日',
                name: 'cycleDay',
                store: this.cycleStore,
                valueField: 'cycle',
                queryMode: 'local',
                editable: false,
                allowBlank: false
              }, {
                id: 'period_setting',
                xtype: 'combobox',
                fieldLabel: '时段',
                name: 'periodId',
                store: this.periodStore,
                valueField: 'id',
                queryMode: 'local',
                editable: false,
                allowBlank: false
              }, {
                xtype: 'numberfield',
                fieldLabel: '最大可开班数',
                name: 'maxClassNum',
                minValue: 0,
                allowBlank: false
              }, {
                xtype: 'numberfield',
                fieldLabel: '每班最大人数',
                name: 'maxStudentNum',
                minValue: 1,
                allowBlank: false
              }]
            }],

            buttons: [{
              id: 'batch_add_button',
              text: '批量模式添加',
              scope: this,
              hidden: this.isEditMode,
              handler: function (button, e) {
                var form = Ext.getCmp('class_template_form').getForm();
                if (!form.isValid()) {
                  return;
                }
                var url = '/tutor/ajax/add_class_template';
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
              text: '确定',
              scope: this,
              handler: function (button, e) {
                var form = Ext.getCmp('class_template_form').getForm();
                if (!form.isValid()) {
                  return;
                }
                var url = this.isEditMode ? '/tutor/ajax/edit_class_template' : '/tutor/ajax/add_class_template';
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

        initFormData: function (record) {
          var form = Ext.getCmp('class_template_form').getForm();
          form.loadRecord(record);
          var gradeType = getGradeType(this.grade);
          loadPeriodSelectStoreData(this.periodStore, this.seasonId, gradeType, function () {
            Ext.getCmp('period_setting').setValue(record.data.periodId);
          });
        },

        refreshCycleStore: function () {
          var seasonItem = getSeasonItem(this.seasonId);
          getCycleDaySelectStoreData(this.cycleStore, seasonItem.data.seasonType);
          Ext.getCmp('cycle_day').setValue('');
        },

        refreshPeriodStores: function () {
          var gradeType = getGradeType(this.grade);
          loadPeriodSelectStoreData(this.periodStore, this.seasonId, gradeType);
          Ext.getCmp('period_setting').setValue('');
        }

      });

      Ext.define('ClassTemplateSearch.Form', {
        extend: 'Ext.window.Window',
        xtype: 'classtemplate-search-form',

        title: '班型筛选',
        width: 500,
        height: 300,
        minWidth: 300,
        minHeight: 220,
        layout: 'fit',
        modal: true,
        closeAction: 'hide',

        initComponent: function () {
          this.seasonStore = getSeasonSelectStore();
          this.gradeStore = gradeSelectStore;
          this.subjectStore = subjectSelectStore;
          this.periodStore = getPeriodSelectStore();

          this.seasonId = undefined;
          this.grade = undefined;

          Ext.apply(this, {
            items: [{
              id: 'class_template_search_form',
              xtype: 'form',
              border: false,
              bodyPadding: 10,
              layout: {
                type: 'vbox',
                align: 'stretch'
              },
              items: [{
                xtype: 'combobox',
                fieldLabel: '学季',
                name: 'seasonId',
                store: this.seasonStore,
                valueField: 'id',
                queryMode: 'local',
                editable: false,
                allowBlank: true,
                listeners: {
                  change: {
                    scope: this,
                    fn: function (component, newValue, oldValue, eOpts) {
                      this.seasonId = newValue;
                      this.refreshPeriodStores();
                    }
                  }
                }
              }, {
                xtype: 'combobox',
                fieldLabel: '年级',
                name: 'grade',
                store: this.gradeStore,
                valueField: 'grade',
                queryMode: 'local',
                editable: false,
                allowBlank: true,
                listeners: {
                  change: {
                    scope: this,
                    fn: function (component, newValue, oldValue, eOpts) {
                      this.grade = newValue;
                      this.refreshPeriodStores();
                    }
                  }
                }
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
                id: 'period_search_setting',
                xtype: 'combobox',
                fieldLabel: '时段',
                name: 'periodId',
                store: this.periodStore,
                valueField: 'id',
                queryMode: 'local',
                editable: false,
                allowBlank: true
              }]
            }],

            buttons: [{
              text: '确定',
              scope: this,
              handler: function (button, e) {
                var form = Ext.getCmp('class_template_search_form').getForm();
                if (!form.isValid()) {
                  return;
                }
                classTemplateStore.currentPage = 1;
                classTemplateStore.getProxy().extraParams = form.getFieldValues();
                classTemplateStore.load({
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
        },

        refreshPeriodStores: function () {
          var gradeType = getGradeType(this.grade);
          loadPeriodSelectStoreData(this.periodStore, this.seasonId, gradeType);
          Ext.getCmp('period_search_setting').setValue('');
        }

      });

      Ext.onReady(function () {
        var grid = Ext.create('Ext.grid.Panel', {
          renderTo: Ext.getBody(),
          title: '班型列表',
          store: classTemplateStore,
          layout: 'fit',
          referenceHolder: true,
          _searchWin: null,
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
              renderer: renderSeason
            }, {
              text: '科目',
              dataIndex: 'subjectId',
              width: 100,
              align: 'center',
              flex: 1,
              renderer: getSubjectName
            }, {
              text: '年级',
              dataIndex: 'grade',
              renderer: getGradeName,
              width: 100,
              flex: 1,
              align: 'center'
            }, {
              text: '循环日',
              dataIndex: 'cycleDay',
              renderer: getCycleDayName,
              width: 150,
              flex: 1,
              align: 'center'
            }, {
              text: '时段',
              dataIndex: 'startTime',
              renderer: renderPeriod,
              flex: 1,
              align: 'center'
            }, {
              text: '最大可开班数',
              dataIndex: 'maxClassNum',
              flex: 1,
              align: 'center'
            }, {
              text: '每班最大人数',
              dataIndex: 'maxStudentNum',
              flex: 1,
              align: 'center'
            }],
          dockedItems: [{
            dock: 'top',
            xtype: 'toolbar',
            items: [{
              text: '添加班型',
              iconCls: 'icon-add',
              handler: function () {
                var win = Ext.create('ClassTemplate.Form', {});
                win.show();
              }
            }, {
              reference: 'editButton',
              text: '编辑班型',
              iconCls: 'icon-edit',
              disabled: true,
              handler: function () {
                var selection = grid.getSelection();
                if (!selection.length) {
                  return;
                }
                var win = Ext.create('ClassTemplate.Form', { isEditMode: true });
                win.initFormData(selection[0]);
                win.show();
              }
            }, '-', {
              reference: 'deleteButton',
              text: '删除班型',
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
                      url: '/tutor/ajax/delete_class_template',
                      params: {
                        'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken"),
                        id: selection[0].data.id
                      },
                      success: function(response){
                        Ext.toast({
                          html: '操作成功',
                          closable: false,
                          align: 't',
                          slideInDuration: 400,
                          minWidth: 400
                        });
                        seasonStore.reload();
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
                this._searchWin = this._searchWin || Ext.create('ClassTemplateSearch.Form', { });
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
                classTemplateStore.getProxy().extraParams = [];
                classTemplateStore.currentPage = 1;
                classTemplateStore.load();
                var ref = grid.getReferences();
                ref.clearSearchButton.setDisabled(true);
              }
            }]
          }, {
            xtype: 'pagingtoolbar',
            store: classTemplateStore, // same store GridPanel is using
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
            classTemplateStore.load(function () {
               grid.getView().refresh();
            });
          });
        });
      });
    })();
  </script>
{% endblock %}
