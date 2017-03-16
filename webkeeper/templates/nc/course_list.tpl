{% extends 'common/base_layout.tpl' %}
{% block title %}课程列表{% endblock %}
{% block page_style %}
    <script src="{{ static('assets/plugins/extjs/ext/grid.js') }}" type="text/javascript"></script>
{% endblock %}
{% block bottom_js %}
<script type="text/javascript">
    Ext.onReady(function () {

        var store = Ext.create('Ext.data.Store', {
            autoLoad: false,
            fields: ['name', 'subject', 'teachers'],
            pageSize: 10, // items per page
            proxy: {
                type: 'ajax',
                url: WebRoot + '/nc/ajax/course_list',
                reader: {
                    rootProperty: 'rows',
                    totalProperty: 'total'
                }
            }
        });
        store.load();
        function renderView(value, p, record) {
            return Ext.String.format(
                '<a target="_self" href="' + WebRoot + '/nc/lesson_list/{0}" target="_blank">查看</a>',
                record.data.id
            );
        }
        var grid1 = Ext.create('Ext.grid.Panel', {
            renderTo: Ext.getBody(),
            title: '课程列表',
            store: store,
            layout:'fit',
            columns: [
                {
                    xtype: "rownumberer", text: "", width:40, align: 'center'
                },{
                id: 'name',
                text: "课程名称",
                dataIndex: 'name',
                width: 250,
                sortable: true,
                align: 'center'
            }, {
                text: "学科",
                dataIndex: 'subject',
                width: 150,
                sortable: true,
                align: 'center'
            }, {
                text: "老师",
                dataIndex: 'teachers',
                flex: 1,
                sortable: true,
                align: 'center'
            }, {
                tdCls: 'x-grid-cell-topic',
                text: "操作",
                dataIndex: 'id',
                sortable: false,
                renderer: renderView,
                align: 'center'
            }],
            dockedItems: [getPaging(store)]
        });
        Ext.on('resize',function(){
            if(grid1)
            {
                if(grid1.getView())
                {
                    grid1.getView().refresh();
                }
            }
        });
    });

</script>
{% endblock %}
