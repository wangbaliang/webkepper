{% extends 'common/base_layout.tpl' %}
{% block title %}教练招培{% endblock %}
{% block page_style %}
<link rel="stylesheet" type="text/css"
      href="{{ static('assets/plugins/extjs/writer.css') }}"/>
{% endblock %}
{% block bottom_js %}
<script type="text/javascript" src="{{ static('assets/js/tutor/common.js') }}"></script>
<script type="text/javascript" src="{{ static('assets/js/tutor/stores.js') }}"></script>
<script type="text/javascript">
  (function () {
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
              var url = '/tutor/ajax/import_hiring_coaches';
              form.submit({
                scope: this,
                waitMsg: '操作处理中...',
                url: url,
                params: {'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken"), 'type':1},
                success: function (form, action) {
                  Ext.toast({
                    html: '操作成功',
                    closable: false,
                    align: 't',
                    slideInDuration: 400,
                    minWidth: 400
                  });
                  this.close();
                  coachHiringStore.reload();
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
              coachHiringStore.currentPage = 1;//将当前页翻回第一页，才能正确刷新
              coachHiringStore.getProxy().extraParams = form.getFieldValues();
              coachHiringStore.load({
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

    Ext.onReady(function () {
      var grid = Ext.create('Ext.grid.Panel', {
        renderTo: Ext.getBody(),
        title: '教练招培',
        store: coachHiringStore,
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
            reference: 'reserveButton',
            text: '转储备',
            iconCls: 'icon-edit',
            disabled: true,
            handler: function () {
              var selection = grid.getSelection();
              if (!selection.length) {
                return;
              }
              Ext.Ajax.request({
                    url: '/tutor/ajax/set_coach_reserve',
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
                      coachHiringStore.reload();
                      }
                      else{
                        Ext.toast({
                        html: '操作失败',
                        closable: false,
                        align: 't',
                        slideInDuration: 400,
                        minWidth: 400
                      });
                      coachHiringStore.reload();
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
          }, {
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
              coachHiringStore.getProxy().extraParams = [];
              coachHiringStore.currentPage = 1;
              coachHiringStore.load();
              var ref = grid.getReferences();
              ref.clearSearchButton.setDisabled(true);
            }
          }]
        }, {
          xtype: 'pagingtoolbar',
          store: coachHiringStore, // same store GridPanel is using
          dock: 'bottom',
          displayInfo: true
        }],
        listeners: {
          select: {
            scope: grid,
            fn: function (component, record, index, eOpts) {
              var ref = this.getReferences();
              ref.reserveButton.setDisabled(false);

            }
          },
          'rowdblclick': function (view, record, item, index, e) {
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
      coachHiringStore.load(function () {
        grid.getView().refresh();
      });
    });
  })();
</script>
{% endblock %}
