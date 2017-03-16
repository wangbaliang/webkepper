{% extends 'common/base_layout.tpl' %}
{% block title %}讲次列表{% endblock %}
{% block page_style %}
    <link rel="stylesheet" type="text/css" href="{{ static('assets/plugins/extjs/writer.css') }}" rel="stylesheet" type="text/css"/>
{% endblock %}
{% block bottom_js %}
    <script src="{{ static('assets/plugins/extjs/ux/Actioncolumn.js') }}" type="text/javascript"></script>
<script type="text/javascript">
var store,writeFormView,main,courseId='{{course_id}}',minDateStr, now, minTime,minStartTime,minStartTimeStr;
var minHour = 6;
var maxHour = 22;

function getMinDateStr() {
    now = minTime = getNow();
    minStartTimeStr = (minHour<9?"0"+minHour:minHour)+':00'
    if(now) {
        if(now.getHours()+1 >= maxHour) {
            minTime = Ext.Date.add(now, Ext.Date.DAY, 1);
        }else if(now.getHours() == maxHour-2 && now.getMinutes()>=50) {
            minTime = Ext.Date.add(now, Ext.Date.DAY, 1);
        }
        //console.log(now);
        //alert(now);
        minStartTimeStr = getMinStartTime(now);
        minDateStr = Ext.Date.format(minTime,'Y-m-d');
    }
    return minDateStr;
}

function getNow() {
    var value = stringToDateTime("{{now}}");
    var btn =  Ext.getCmp('hf_now_time');

    if(btn) {
        var time = parseInt(btn.getValue());
        value = new Date(time);
    }else{
        var hfNowTime = Ext.create('Ext.form.field.Hidden', {
            name: 'hidden_field_1',
            value: value.getTime(),
            id: 'hf_now_time',
            renderTo: Ext.getBody()
        });
        var updateClock = function () {
            var time = parseInt(hfNowTime.getValue());
            hfNowTime.setValue(time + 1000);
        };
        setInterval(updateClock, 1000);
    }
    return value;
}

function getMinStartTime(now, startDate) {
    var minStr = (minHour<9?"0"+minHour:minHour)+':00';
    //console.log(now);
    if(now && startDate) {
        var date1 = Ext.Date.format(now,'Y-m-d');
        var date2 = Ext.Date.format(startDate,'Y-m-d');
        var date3 = new Date(date2).getTime() - new Date(date1).getTime();  //时间差的毫秒数
        if(date3!=0) {
            //不是同一天
            minStr = (minHour<9?"0"+minHour:minHour)+':00'
        }else if(date3 == 0) {
            if(now.getHours() >= minHour && now.getHours() < maxHour-1) {
                minStartTime = Ext.Date.add(now, Ext.Date.HOUR, 1);
                var re = 10-(now.getMinutes()%10);
                //console.log(re);
                minStartTime = Ext.Date.add(minStartTime, Ext.Date.MINUTE, re);
                minStr = Ext.Date.format(minStartTime,'H:i');
            }
        }
    }

    return minStr;
}

Ext.require([
    'Ext.data.*',
    'Ext.tip.QuickTipManager',
    'Ext.window.MessageBox'
]);

//讲次,主讲内容 name,状态 readyStatus,开课日期 starTime,开课时间 realTime,操作
Ext.define('Writer.Lesson', {
    extend: 'Ext.data.Model',
    fields: ['id', '_id', 'name', 'readyStatus', 'startDate', 'startTime', 'endTime', 'time'],
    validators: {
        name: {
            type: 'length',
            min: 1
        }
    }
});
function check(date){
    if(date instanceof Date){
        return true;
    }
    else{
        return false;
    }
}
Ext.define('Writer.timefield', {
    extend: 'Ext.form.field.Time',
    alias: 'widget.writertime',
    requires: ['Ext.form.field.Date', 'Ext.picker.Time', 'Ext.view.BoundListKeyNav', 'Ext.Date'],
    initComponent: function() {
         Ext.apply(this, {
             minText: '时间值应大于或等于{0}'
         });
        this.callParent();
    },
    /**
     * @private
     */
    isEqual: function (v1, v2) {
        if(!check(v1) && check(v2)){
            return false;
        }
        else if(check(v1) && !check(v2)){
            return false;
        }
        var fromArray = Ext.Array.from,
            isEqual = Ext.Date.isEqual,
            i, len;

        v1 = fromArray(v1);
        v2 = fromArray(v2);
        len = v1.length;

        if (len !== v2.length) {
            return false;
        }

        for (i = 0; i < len; i++) {
            if (!isEqual(v2[i], v1[i])) {
                return false;
            }
        }
        return true;
    }
});
Ext.define('Writer.Form', {
    extend: 'Ext.form.Panel',
    alias: 'widget.writerform',
    requires: ['Ext.form.field.Text'],
    initComponent: function(){
        var myMinDateStr = getMinDateStr();
        //alert(myMinDateStr);

        Ext.apply(this, {
            activeRecord: null,
            frame: false,
            border : false,
            defaultType: 'textfield',
            bodyPadding: 10,
            fieldDefaults: {
                anchor: '100%',
                labelAlign: 'right'
            },
            items: [{
                xtype: 'hiddenfield',
                name: '_id'
            },{
                xtype: 'hiddenfield',
                name: 'id',
                value: '0'
            },{
                fieldLabel: 'lesson名称',
                name: 'name',
                allowBlank: false
            }, {
                itemId: "startDate",
                xtype: 'datefield',
                anchor: '100%',
                fieldLabel: '开课日期',
                name: 'startDate',
                minValue: myMinDateStr,
                allowBlank: false,
                format: 'Y-m-d',
                editable: false,
                listeners: {
                    change: function (datefield, newValue, oldValue, eOpts) {
                        now = getNow();
                        if(newValue && now){
                            var minTimeStr = getMinStartTime(now, newValue);

                            writeFormView.child('#form').child('#form_container').child('#btn_startTime').setMinValue(minTimeStr);
                            //writeFormView.child('#form').child('#form_container').child('#btn_startTime').setMinValue(minTimeStr);
                            //writeFormView.child('#form').child('#form_container').child('#btn_startTime').setActiveError('最小值为'+minTimeStr);
                        }
                    }
                }
            },{
                itemId: 'form_container',
                xtype: "container",
                layout: "hbox",
                items: [
                {
                    itemId:'btn_startTime',
                    flex: 50,
                    xtype: 'writertime',
                    name: 'startTime',
                    fieldLabel: '开课时间',
                    minValue: '06:00',
                    maxValue: '21:50',
                    increment: 10,
                    anchor: '20%',
                    allowBlank: false,
                    format: 'H:i',
                    editable: false,
                    listeners: {
                        change: function (timefield, newValue, oldValue, eOpts) {
                            var minTimeStr = '06:10';
                            if(newValue){
                                //设置结束时间的最小时间为开始时间+最小间隔分钟
                                var minTime = Ext.Date.add(newValue, Ext.Date.MINUTE, timefield.increment);
                                minTimeStr = Ext.Date.format(minTime,'H:i');
                            }
                            writeFormView.child('#form').child('#form_container').child('#btn_endTime').setMinValue(minTimeStr);
                        }
                    }
                },{
                    xtype: 'component',
                    flex: 1,
                    html: '-'
                },{
                    itemId:'btn_endTime',
                    flex: 25,
                    xtype: 'writertime',
                    name: 'endTime',
                    minValue: '06:10',
                    maxValue: '22:00',
                    increment: 10,
                    anchor: '20%',
                    allowBlank: false,
                    format: 'H:i',
                    editable: false
                }]
            } ],
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                ui: 'footer',
                items: ['->', {
                    formBind : false,
                    type : 'submit',
                    iconCls: 'icon-save',
                    itemId: 'save',
                    text: '保存',
                    disabled: true,
                    scope: this,
                    handler: this.onSave
                }, {
                    iconCls: 'icon-reset',
                    text: '取消',
                    scope: this,
                    handler: this.onReset
                }]
            }]
        });
        this.callParent();
    },

    setActiveRecord: function(record){
        //console.log(this.getForm());
        this.activeRecord = record;
        if (record) {
            this.down('#save').enable();
            this.getForm().loadRecord(record);
        } else {
            this.down('#save').disable();
            this.getForm().reset();
        }
    },
    onSave: function(){
        var active = this.activeRecord,
            form = this.getForm();
        if (!active) {
            return;
        }

        if (form.isValid()) {
            //form.updateRecord(active);
            //showProgress('正在保存...');
            // 提交到服务器操作
            form.doAction('submit', {
                waitMsg: '正在保存...',
                url : '{{ url("nc.lesson_save") }}',// url路径
                method : 'post',// 提交方法post或get
                params : {'csrfmiddlewaretoken':Ext.util.Cookies.get("csrftoken"),'courseId':courseId},
                // 提交成功的回调函数
                success : function(form, action) {
                    if(action.result.message)
                    {
                        Ext.Msg.alert('提示',action.result.message);
                    }
                    if(action.result.error===0)
                    {
                        //form.updateRecord(active);
                        store.reload();
                        hiddenWin();
                    }
                },
                // 提交失败的回调函数
                failure: function(form, action) {
                    //alert(action.message)
                    //log(action.response);
                    var message = "保存失败";
                    if(action.result){
                        if(action.result.message)
                        {
                            message = action.result.message
                        }
                    }
                    //var responseArray = Ext.util.JSON.decode(action.response.responseText);
                    Ext.Msg.alert('提示',message);
                }
            });
        }
    },
    onReset: function(){
        //this.setActiveRecord(null);
        //this.getForm().reset();
        hiddenWin();
    }
});

function renderTime(value, p, record) {
    //console.log('12312');
    return '06:10';
}

function hiddenWin() {
    writeFormView.hide();
}

function renderView(value, p, record) {
    return Ext.String.format(
        '<a target="_self" href="' + WebRoot + '/nc/lesson_list/{0}" target="_blank">查看</a>',
        record.data.id
    );
}

/**
 * 删除所选lesson
 * @param recode
 */
function deleteRecode(recode) {
    Ext.MessageBox.confirm('提示', '确认删除此讲次吗', function(re){
        if(re=="yes")
        {
            showProgress('正在删除...');
            var _id = recode.data._id;
            var courseId = recode.data.courseId;

            Ext.Ajax.request({
                url: '{{ url('nc.lesson_destroy') }}',    //请求地址
                //提交参数组
                params: {
                    'csrfmiddlewaretoken':Ext.util.Cookies.get("csrftoken"),
                    '_id':_id,
                    'course_id':courseId
                },
                //成功时回调
                success: function(response, options) {
                    //获取响应的json字符串
                    var responseArray = Ext.util.JSON.decode(response.responseText);
                    //console.log(responseArray);
                    store.reload();
                    if(responseArray.message)
                    {
                        Ext.Msg.alert('提示', responseArray.message);
                    }
                },
                failure: function(response, options) {
                    var message = '删除失败';
                    if(response.responseText){
                        var responseArray = Ext.util.JSON.decode(response.responseText);
                        if(responseArray)
                        {
                            message = responseArray;
                        }
                        else
                        {
                            message = response.responseText;
                        }
                    }
                    Ext.Msg.alert('提示',message);
                }
            });
        }
    }, null);

}

Ext.define('Writer.Grid', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.writergrid',
    requires: [
        'Ext.grid.plugin.CellEditing',
        'Ext.form.field.Text',
        'Ext.toolbar.TextItem',
        'Ext.grid.column.Date',
        'Ext.grid.column.Action'
    ],

    initComponent: function(){
        this.editing = Ext.create('Ext.grid.plugin.CellEditing');
        Ext.apply(this, {
            iconCls: 'icon-grid',
            frame: false,
            dockedItems: [{
                xtype: 'toolbar',
                items: [{
                    iconCls: 'icon-add',
                    text: '添加',
                    scope: this,
                    handler: this.onAddClick
                }]
            }],
            columns: [{
                    xtype: "rownumberer", width:50, align: 'center',header: '讲次', align: "center"
                },{
                header: '主讲内容',
                flex: 1,
                sortable: true,
                dataIndex: 'name',
                field: {
                    type: 'textfield'
                }
            }, {
                header: '状态',
                width: 60,
                sortable: true,
                resizable: false,
                draggable: false,
                hideable: false,
                menuDisabled: true,
                dataIndex: 'readyStatus'
            }, {
                header: '开课日期',
                width: 100,
                sortable: true,
                dataIndex: 'startDate',
                field: {
                    type: 'datefield'
                }
            }, {
                header: '开课时间',
                width: 100,
                sortable: true,
                dataIndex: 'time',
                field: {
                    type: 'textfield'
                }
            },{
                xtype: "actiontextcolumn",
                text: "操作",
                width: 100,
                align: "center",
                cls: "my_action",
                dataIndex: 'isEdit',
                items:[{
                    text:"编辑",
                    altText:"编辑",
                    tooltip:"编辑",
                    handler:function(grid, rowIndex, colIndex, item, e)
                    {
                        var recode = grid.getStore().getAt(rowIndex);
                        createEditView(recode);
                    }
                },{
                    altText:"删除",
                    text:"删除",
                    tooltip:"删除",
                    itemId: 'delete',
                    handler:function(grid, rowIndex, colIndex, item, e)
                    {
                        var recode = grid.getStore().getAt(rowIndex);
                        deleteRecode(recode);
                    }
                }]
            }]
        });
        this.callParent();
        this.getSelectionModel().on('selectionchange', this.onSelectChange, this);
    },

    onSelectChange: function(selModel, selections){
        //console.log(selections[0].data);
        //var isEdit = selections[0].data.isEdit;
        //this.down('#delete').setDisabled(!isEdit);
    },

    onSync: function(){
        //this.store.sync();
    },

    onDeleteClick: function(){
        var selection = this.getView().getSelectionModel().getSelection()[0];
        deleteRecode(selection);
    },

    onAddClick: function(){
        //'id', 'name', 'readyStatus', 'startDate', 'starTime'
        var rec = new Writer.Lesson({
            id: '0',
            name: '',
            startDate: '',
            startTime: '',
            endTime: ''
        });
        //var edit = this.editing;
        createEditView(rec);
        //edit.cancelEdit(rec);
{#        this.store.insert(0, rec);#}
{#        edit.startEditByPosition({#}
{#            row: 0,#}
{#            column: 1#}
{#        });#}
    }
});

Ext.onReady(function(){

    Ext.tip.QuickTipManager.init();
    store = Ext.create('Ext.data.Store', {
        model: 'Writer.Lesson',
        autoLoad: true,
        proxy: {
            type: 'ajax',
            api: {
                read: WebRoot + '/nc/ajax/lesson/list/'+courseId
            },
            reader: {
                type: 'json',
                successProperty: 'success',
                rootProperty: 'rows',
                messageProperty: 'message'
            }
        }
    });

    main = Ext.create('Ext.container.Container', {
        id: "main_container",
        padding: '0 0 0 0',
        autoHeight: true,
        renderTo: document.body,
        layout:'fit',
        items: [ {
            itemId: 'grid',
            xtype: 'writergrid',
            title: '课程讲次列表',
            layout:'fit',
            store: store,
            listeners: {
                //selectionchange: function(selModel, selected) {
{#                    createEditView(selected[0] || null);#}
                    //main.child('#form').setActiveRecord(selected[0] || null);
{#                    console.log(selected[0]);#}
                //}
            }
        }]
    });
    Ext.on('resize',function(){
        if(main)
        {
            main.setWidth(document.documentElement.clientWidth);
        }
    });
});

/**
 * 弹出编辑窗口
 * @param recode
 */
function createEditView(recode)
{
    var title;
    if(!recode)
    {
        title='添加lesson';
    }
    else
    {
        title = '编辑lesson信息';
    }
    writeFormView = Ext.create('Ext.window.Window', {
        constrainTo:main,
        modal:true,
        title: title,
        // 该面板布局类型
        layout: 'column',
        width: 360,
        x:200,
        y:200,
        // 不容许任意伸缩大小
        resizable: false,
        // 高度
        autoHeight: 377,
        // 面板是否可以关闭及打开
        collapsible: false,
        // 关闭功能是否可以关闭及打开
        closable: true,
        // 窗体拖拽 默认是TRUE
        draggable: true,
        shadow: true,

        items: {
            columnWidth: 1,
            // 把表单面板容器增加入其中,使之成为窗口面板容器的子容器
            itemId: 'form',
            xtype: 'writerform',
            manageHeight: false,
            margin: '0 0 10 0'
        }
    });
    writeFormView.show();
    writeFormView.child('#form').setActiveRecord(recode || null);
}

</script>
{% endblock %}