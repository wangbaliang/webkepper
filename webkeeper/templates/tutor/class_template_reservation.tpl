{% extends 'common/base_layout.tpl' %}
{% block title %}学生报名情况{% endblock %}
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
//      Ext.define('ExportReservationData.Form', {
//        extend: 'Ext.window.Window',
//        xtype: 'export-reservation-data-form',
//        title: '导出设置',
//        width: 400,
//        heigth: 300,
//        layout: 'fit',
//        modal: true,
//        initComponent: function () {
//
//          Ext.apply(this, {
//
//            items: [{
//              id: 'export_reservation_data_form',
//              xtype: 'form',
//              border: false,
//              bodyPadding: 10,
//              layout: {
//                type: 'vbox',
//                align: 'stretch'
//              },
//              items:[
//                {
//                id: 'select_export_type',
//                xtype: 'radiogroup',
//                cls: 'x-check-group-alt',
//                defaults: {labelWidth: 50},
//                items: [
//                  {boxLabel: '昨日', name: 'dayType', inputValue: 1, checked: true},
//                  {boxLabel: '所有', name: 'dayType', inputValue: 2},
//                  {boxLabel: '自定义', name: 'dayType', inputValue:3}
//                ],
//                listeners: {
//                  change: {
//                    scope: this,
//                    fn: function (component, newValue, oldValue, eOpts) {
//                      var need = Ext.getCmp('editDataVlaue');
//                      if (newValue['dayType'] === 3) {
//                        need.setHidden(false);
//                        Ext.getCmp('start_day').allowBlank = true;
//                        Ext.getCmp('end_day').allowBlank = true;
//                      } else {
//                        need.setHidden(true);
//                        Ext.getCmp('start_day').allowBlank = false;
//                        Ext.getCmp('end_day').allowBlank = false;
//                      }
//
//                    }
//                  }
//                }
//              },
//                {
//                id : 'editDataVlaue',
//                reference: 'editData',
//                xtype: 'fieldcontainer',
//                hidden: true,
//                layout: 'hbox',
//                defaultType: 'datefield',
//                defaults: {
//                  hideLabel: 'true'
//                },
//                items: [{
//                  id: 'start_day',
//                  name: 'startDay',
//                  allowBlank: false,
//                  editable: false,
//                  format: 'Y-m-d',
//                  vtype: 'daterange'
////                        endDateField: 'end_day'
//                }, {
//                  xtype: 'displayfield',
//                  margin: '2 5 0 5',
//                  value: '至'
//                }, {
//                  id: 'end_day',
//                  name: 'endDay',
//                  allowBlank: false,
//                  editable: false,
//                  format: 'Y-m-d',
//                  vtype: 'daterange'
////                        startDateField: 'start_day'
//                  }]
//              }
//              ]
//            }],
//            buttons: [{
//            text: '确定',
//            scope: this,
//            handler: function (button, e) {
//              var form = Ext.getCmp('export_reservation_data_form').getForm();
//              console.log(111, form.isValid());
//              if (!form.isValid()) {
//                return;
//              }
//              console.log(222, form.isValid());
//              var url = '/tutor/ajax/export_reservation_data';
//              form.submit({
//                scope: this,
//                waitMsg: '操作处理中...',
//                url: url,
//                params: {'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken")},
//                success: function (form, action) {
//                  Ext.toast({
//                    html: '操作成功',
//                    closable: false,
//                    align: 't',
//                    slideInDuration: 400,
//                    minWidth: 400
//                  });
//                  this.close();
//                },
//                failure: function (form, action) {
//                  Ext.MessageBox.show({
//                    msg: '操作失败，请您重试',
//                    icon: Ext.MessageBox.ERROR
//                  });
//                }
//              });
//            }
//          }, {
//            text: '取消',
//            scope: this,
//            handler: function (button, e) {
//              this.close();
//            }
//          }
//            ]
//          });
//          this.callParent();
//        }
//      });

      Ext.onReady(function () {
        reservationStoreInTemplate.load();
        var grid = Ext.create('Ext.grid.Panel', {
          renderTo: Ext.getBody(),
          title: '学生报名情况',
          store: reservationStoreInTemplate,
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
            },{
              text: '班型总人数',
              dataIndex: 'maxStudentInClass',
              flex: 1,
              align: 'center'
            },{
              text: '最小教练需求数',
              dataIndex: 'minNeededCoachNumber',
              flex: 1,
              align: 'center'
            },{
              text: '可用教练数',
              dataIndex: 'usableCoachNumber',
              flex: 1,
              align: 'center'
            },{
              text: '已分班的人数',
              dataIndex: 'allotStudentNumber',
              flex: 1,
              align: 'center'
            },{
              text: '已报名还未分班的人数',
              dataIndex: 'unallotStudentNumber',
              flex: 1,
              align: 'center'
            },{
              text: '累计报名人数',
              dataIndex: 'allStudentNumber',
              flex: 1,
              align: 'center'
            }],
          dockedItems: [
            {
              dock: 'top',
              xtype: 'toolbar',
              items: [{
                text: '导出Excel',
                iconCls: 'icon-search',
                handler: function () {
                  console.log(1111);
                  window.open("excel/export_reservation_data");
                  console.log(2222);
//                  var win = Ext.create('ExportReservationData.Form', {});
//                  win.show();
                }
              }]
            },
            {
            xtype: 'pagingtoolbar',
            store: reservationStoreInTemplate, // same store GridPanel is using
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
            reservationStoreInTemplate.load(function () {
               grid.getView().refresh();
            });
          });
        });
      });
    })();
  </script>
{% endblock %}
