{% extends 'common/base_layout.tpl' %}
{% block title %}学员列表{% endblock %}
{% block page_style %}
<link rel="stylesheet" type="text/css"
      href="{{ static('assets/plugins/extjs/writer.css') }}"/>
{% endblock %}
{% block bottom_js %}
<script type="text/javascript" src="{{ static('assets/js/tutor/common.js') }}"></script>
<script type="text/javascript" src="{{ static('assets/js/tutor/stores.js') }}"></script>
<script type="text/javascript">
    (function () {
        Ext.define('StudentSearch.Form', {
            extend: 'Ext.window.Window',
            xtype: 'student-search-form',

            title: '查询',
            width: 500,
            height: 300,
            minWidth: 300,
            minHeight: 220,
            layout: 'fit',
            modal: true,
            closeAction: 'hide',

            initComponent: function () {
                this.gradeStore = gradeSelectStore;
                if (!areaStore.isLoaded()) {
                    areaStore.load();
                }
                this.areaStore = areaStore;

                Ext.apply(this, {
                    items: [{
                        id: 'student_search_form',
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
                            xtype: 'combobox',
                            fieldLabel: '地区',
                            name: 'areaCode',
                            store: this.areaStore,
                            valueField: 'areaCode',
                            queryMode: 'local',
                            editable: true,
                            allowBlank: true,
                            grow: true,
                            forceSelection: false
                        }, {
                            xtype: 'combobox',
                            fieldLabel: '年级',
                            name: 'grade',
                            store: this.gradeStore,
                            valueField: 'grade',
                            queryMode: 'local',
                            editable: false,
                            allowBlank: true
                        }]
                    }],

                    buttons: [{
                        text: '确定',
                        scope: this,
                        handler: function (button, e) {
                            var form = Ext.getCmp('student_search_form').getForm();
                            if (!form.isValid()) {
                                return;
                            }
                            studentStore.currentPage = 1;//将当前页翻回第一页，才能正确刷新
                            studentStore.getProxy().extraParams = form.getFieldValues(); //将之前的筛选条件插入到store的默认状态下
                            studentStore.load({
                                scope: this,
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
                var i = 0;
                this.callParent();
            }
        });


        Ext.define('StudentInformation.Form',
            {
                extend: 'Ext.window.Window',
                title: '学员资料',
                width: 600,
                height: 600,
                minWidth: 600,
                minHeight: 600,
                layout: 'fit',
                modal: true,
                closeAction: 'hide',
                student_info: {},
                initComponent: function () {
                    this.gradeStore = gradeSelectStore;
                    this.renderForClassId = function renderForClassId(classId){
                      if( 0 == classId){
                        return "未分班"
                      }else{
                        return classId;
                      }

                    };
                    if (!periodStore.isLoaded()) {
                        periodStore.load();
                    }
                    if (!areaStore.isLoaded()) {
                        areaStore.load();
                    }
                    this.areaStore = areaStore;
                    var userName = this.student_info['userName'];
                    this.enlist_store = getEnlistList(userName);
                    Ext.apply(this, {
                        items: [{
                            border: false,
                            bodyPadding: 10,
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    title: '基本资料',
                                    flex: 3,
                                    layout: {
                                        type: 'vbox',
                                        align: 'stretch'
                                    },
                                    defaults: {border: false, bodyPadding: "5 0 15 15", align: 'center'},
                                    items: [{
                                        // 基本资料的第一层信息
                                        flex: 35,
                                        layout: {
                                            type: 'hbox',
                                            align: 'stretch'
                                        },
                                        defaults: {width: 190, border: false, align: 'center'},
                                        items: [
                                            {
                                                html: '用户名:' + this.student_info['userName'] + '<br><br>' +
                                                '赠送次数:' + this.student_info['giftServiceTotal']+ '<br><br>'
                                            }, {
                                                html: '姓名:' + this.student_info['realName'] + '<br><br>' +
                                                '购买次数:' + this.student_info['buyServiceTotal']+ '<br><br>'
                                            }, {
                                                html: '年级:' + transGradeType2Grade(this.student_info['grade']) + '<br><br>' +
                                                '使用次数:' + this.student_info['usedServiceTotal']+ '<br><br>'
                                            }
                                        ]
                                    }, {
                                        flex: 22, html: '省/市/（区）县：' + this.student_info['areaDisplay']
                                    }
                                    ]

                                },

                                {
                                    flex: 7,
                                    xtype: 'grid',
                                    title: '报名情况',
                                    store: this.enlist_store,
                                    layout: 'fit',
                                    referenceHolder: true,
                                    _searchWin: null,
                                    columns: [
                                        {
                                            text: '报名科目',
                                            flex: 1,
                                            sortable: false,
                                            dataIndex: 'subjectId',
                                            renderer: getSubjectName
                                        }, {
                                            text: '班级ID',
                                            flex: 1,
                                            sortable: false,
                                            dataIndex: 'classId',
                                            renderer:this.renderForClassId
                                        }, {
                                            text: '循环日',
                                            flex: 1,
                                            sortable: false,
                                            dataIndex: 'cycleDay',
                                            renderer: getCycleDayName
                                        }, {
                                            text: '时段',
                                            flex: 1,
                                            sortable: false,
                                            dataIndex: 'period_id',
                                            renderer: renderPeriod
                                        }
                                    ]
                                }]
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
        Ext.define('StudentChangeClass.Form',
            {
                extend: 'Ext.window.Window',
                title: '调班',
                width: 1000,
                height: 600,
                minWidth: 1000,
                minHeight: 600,
                layout: 'fit',
                modal: true,
                closeAction: 'hide',
                student_info: {},
                initComponent: function () {
                    this.gradeStore = gradeSelectStore;
                    if (!periodStore.isLoaded()) {
                        periodStore.load();
                    }
                    if (!areaStore.isLoaded()) {
                        areaStore.load();
                    }
                    this.areaStore = areaStore;
                    var userName = this.student_info['userName'];
                    this.class_list_of_student = getClassListOfStudent(userName);
                    Ext.apply(this, {
                        items: [{
                            border: false,
                            bodyPadding: 10,
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            items: [
                                {
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
                                                html: '用户名:' + this.student_info['userName'] + '<br>' +
                                                '省/市/（区）县:' + this.student_info['areaDisplay']
                                            }, {
                                                flex: 1,
                                                html: '姓名:' + this.student_info['realName'] + '<br>'
                                            }, {
                                                flex: 1,
                                                html: '年级:' + getGradeName(this.student_info['grade'])
                                            }
                                        ]
                                    }
                                    ]

                                },
                                {
                                    plugins: [
                                        Ext.create('Ext.grid.plugin.CellEditing', {
                                            clicksToEdit: 1 //设置单击单元格编辑
                                        })
                                    ],
                                    xtype: 'grid',
                                    title: '调整班级',
                                    store: this.class_list_of_student,
                                    layout: 'fit',
                                    referenceHolder: true,
                                    stripeRows: true, //斑马线效果
                                    selType: 'cellmodel',
                                    columns: [
                                        {
                                            header: '班级ID',
                                            flex: 1,
                                            sortable: false,
                                            dataIndex: 'classId'
                                        },
                                        {
                                            header: '循环日',
                                            flex: 1,
                                            sortable: false,
                                            dataIndex: 'cycleDay',
                                            renderer: getCycleDayName
                                        },
                                        {
                                            header: '时段',
                                            flex: 1,
                                            sortable: false,
                                            dataIndex: 'period_id',
                                            renderer: renderPeriod
                                        },
                                        {
                                            header: '学科',
                                            flex: 1,
                                            sortable: false,
                                            dataIndex: 'subjectId',
                                            renderer: getSubjectName,
                                        },
                                        {
                                            header: '调整到班级',
                                            flex: 1,
                                            dataIndex: 'toNewClass',
                                            editor: {
                                                allowblank: true
                                            }
                                        }
                                    ]
                                }]
                        }],

                        buttons: [{
                            text: '确定',
                            scope: this,
                            handler: function (button, e) {
                                var m = this.enlist_store.getModifiedRecords();
                                var jsonArray = [];
                                Ext.each(m, function (item) {
                                    jsonArray.push({
                                        oldClassID: item.data.classId,
                                        newClassID: item.data.toNewClass - 0
                                    });
                                });
                                var userName = this.student_info['userName'];
                                var jsonstring = JSON.stringify(jsonArray)
                                Ext.Ajax.request({
                                    // TODO Ajax完成修改学员班级
                                    scope: this,
                                    waitMsg: '操作处理中...',
                                    url: '/tutor/ajax/modify_class_for_student',
                                    params: {
                                        'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken"),
                                        student_id: userName,
                                        change_list: jsonstring
                                    },
                                    method: 'POST',
                                    success: function (response, options) {
                                        Ext.MessageBox.alert('成功', '从服务端获取结果: ' + response.responseText);
                                    },
                                    failure: function (response, options) {
                                        Ext.MessageBox.alert('失败', '请求超时或网络故障,错误编号：' + response.status);
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
                title: '学员列表',
                store: studentStore,
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
                        text: '手机',
                        dataIndex: 'phone',
                        flex: 1,
                        align: 'center'
                    }, {
                        text: '姓名',
                        dataIndex: 'realName',
                        width: 100,
                        align: 'left',
                        flex: 1
                    }, {
                        text: '年级',
                        dataIndex: 'grade',
                        renderer: getGradeName,
                        width: 100,
                        flex: 1,
                        align: 'center'
                    }, {
                        text: '省/市/区',
                        dataIndex: 'areaDisplay',
                        width: 100,
                        align: 'left',
                        flex: 1
                    }, {
                        text: '赠送次数',
                        dataIndex: 'giftServiceTotal',
                        flex: 1,
                        align: 'center'
                    }, {
                        text: '购买次数',
                        dataIndex: 'buyServiceTotal',
                        flex: 1,
                        align: 'center'
                    }, {
                        text: '使用次数',
                        dataIndex: 'usedServiceTotal',
                        flex: 1,
                        align: 'center'
                    }],
                dockedItems: [{
                    dock: 'top',
                    xtype: 'toolbar',
                    items: [{
                        text: '调班',
                        reference: 'classChangeButton',
                        disabled: true,
                        iconCls: 'icon-add',
                        handler: function () {
                            var selection = grid.getSelection();
                            if (!selection.length) {
                                return;
                            }
                            var win = Ext.create('StudentChangeClass.Form', {student_info: selection[0].data});
                            win.show();
                        }
                    }, '-', {
                        text: '筛选',
                        iconCls: 'icon-search',
                        handler: function () {
                            this._searchWin = this._searchWin || Ext.create('StudentSearch.Form', {});
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
                            studentStore.getProxy().extraParams = [];
                            studentStore.currentPage = 1;
                            studentStore.load();
                            var ref = grid.getReferences();
                            ref.clearSearchButton.setDisabled(true);
                        }
                    }]
                }, {
                    xtype: 'pagingtoolbar',
                    store: studentStore, // same store GridPanel is using
                    dock: 'bottom',
                    displayInfo: true
                }],
                listeners: {
                    select: {
                        scope: grid,
                        fn: function (component, record, index, eOpts) {
                            var ref = grid.getReferences();
                            ref.classChangeButton.setDisabled(false);
                        }
                    },
                    rowdblclick: function (view, record, item, index, e) {
                        var student_info = record.data;
                        this._student_info_window = Ext.create('StudentInformation.Form', {student_info: student_info});
                        this._student_info_window.show();
                        var ref = grid.getReferences();
                        ref.clearSearchButton.setDisabled(false);
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
            studentStore.load(function () {
                grid.getView().refresh();
            });
        });
    })();
</script>
{% endblock %}
