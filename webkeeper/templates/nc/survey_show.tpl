{% extends 'common/base_layout.tpl' %}
{% block title %}课后调研----查看调研结果{% endblock %}
{% block page_style %}
    <link rel="stylesheet" type="text/css" href="{{ static('assets/plugins/extjs/writer.css') }}" rel="stylesheet" type="text/css"/>
    <script src="{{ static('assets/plugins/extjs/ext/grid.js') }}" type="text/javascript"></script>
{% endblock %}
{% block bottom_js %}
<script type="text/javascript">
    var pageLimit = 10, grid, store, msgWait;

    //grid列数据
    function buildColumn(extColumns){

        var baseColumns= [
            {text: "客户id", width: 100, dataIndex: 'userName', sortable: true},
            {text: "姓名", width: 100, dataIndex: 'realName', sortable: true},
            {text: "联系方式", width: 100, dataIndex: 'tel', sortable: true},
            {text: "提交时间", width: 150, dataIndex: 'postTime', sortable: true},
            {text: "所在课程", width: 100, dataIndex: 'course', sortable: true},
            {text: "所在课程讲次", width: 125, dataIndex: 'lesson', sortable: true},
            {text: "授课老师", width: 125, dataIndex: 'teacher', sortable: true}
        ];
        if(!extColumns)
        {
            //baseColumns[1]["flex"] = 1;
        }
        if(extColumns)
        {
            var i,index = baseColumns.length,column;
            for(i=0 ;i< extColumns.length; i++)
            {
                for(column in extColumns[i])
                {
                    var item2 = {};
                    item2.dataIndex = column;
                    item2.text = extColumns[i][column];
                    item2.sortable = true;
                    if(i < extColumns.length-1)
                    {
                        item2.width = "80";
                    }
                    else
                    {
                        item2.width = "120";
                    }
                    baseColumns[index + i] = (item2);
                    break;
                }
            }
        }
        return  baseColumns;
    }

    Ext.onReady(function () {

        store = Ext.create('Ext.data.Store', {
            id:'survey_store',
            autoLoad: false,
            fields: [ {name: '_id'},{name:'sid'},{name:'userName' } ,{name:'realName' } ,{name:'tel' },{name:'postTime' },{name:'course' },{name:'lession' },{name:'teacher' },{name:'answers' }],
            pageSize: pageLimit,
            proxy: {
                type: 'ajax',
                url: WebRoot + '/nc/ajax/results_list/{{survey_id}}',
                reader: {
                    rootProperty: 'rows',
                    totalProperty: 'total'
                }
            }
        });
        Ext.override(store,{
            onProxyLoad:function(operation){
                var me = this,
                result  = me.getProxy().getReader().rawData;
                if(result['questions'])
                {
                     //me.loadData(result['rows']);
                     grid.reconfigure(me, buildColumn(result['questions']) );
                     grid.doLayout();
                }
                var resultSet = operation.getResultSet(),
                records = operation.getRecords(),
                successful = operation.wasSuccessful();

                if (me.isDestroyed) {
                    return;
                }

                if (resultSet) {
                    me.totalCount = resultSet.getTotal();
                }

                if (successful) {
                    records = me.processAssociation(records);
                    me.loadRecords(records, operation.getAddRecords() ? {
                        addRecords: true
                    } : undefined);
                } else {
                    me.loading = false;
                }

                if (me.hasListeners.load) {
                    me.fireEvent('load', me, records, successful, operation);
                }
                me.callObservers('AfterLoad', [records, successful, operation]);
            }
        });
        var columns = buildColumn();
        // create the grid
        grid = Ext.create('Ext.grid.Panel', {
            store: store,
            id:'test',
            columns:columns,
            layout:'fit',
            split: true,
            dockedItems: [{
                xtype: 'toolbar',
                dock: 'top',
                items: ['->',
                {
                    iconCls: 'icon-save',
                    itemId: 'save',
                    text: '导出',
                    disabled: false,
                    scope: this,
                    handler: function()
                    {
                        onExport();
                    }
                }]
            },getPaging(store)]
        });
        Ext.create('Ext.Panel', {
            renderTo: Ext.getBody(),
            border:false,
            title: '查看调研结果',
            minHeight:450,
            layout: 'fit',
            items: [grid ]
        });
        store.load();
        Ext.on('resize',function(){
            if(grid){
                if(grid.getView())
                {
                    grid.getView().refresh();
                }
            }
        });
    });

    /**
     * 导出点击事件
     */
    function onExport(){
        window.open(WebRoot + '/nc/results_export/{{survey_id}}');
        //window.location = WebRoot + '/nc/results_export/{{survey_id}}';
    }
</script>
{% endblock %}
{% block body %}
{% endblock %}