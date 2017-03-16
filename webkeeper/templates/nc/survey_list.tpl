{% extends 'common/base_layout.tpl' %}
{% block title %}调研列表{% endblock %}
{% block page_style %}
    <link rel="stylesheet" type="text/css" href="{{ static('assets/plugins/extjs/writer.css') }}" rel="stylesheet" type="text/css"/>
    <script src="{{ static('assets/plugins/extjs/ext/grid.js') }}" type="text/javascript"></script>
{% endblock %}
{% block bottom_js %}
<script type="text/javascript">
    var pageLimit = 10;
    function getSurveyType()
    {
        var surveyType = '{{survey_type}}';
        var id = window.name;
        if(id)
        {
            if(parent.window.document.getElementById(id).data)
            {
                surveyType = parent.window.document.getElementById(id).data;
            }
        }
        return surveyType;
    }

    function setSurveyType(surveyType)
    {
        var id = window.name;
        if(id)
        {
            parent.window.document.getElementById(id).data = surveyType;
        }
        //console.log(parent.window.document.getElementById(id).data);
    }

    function createGrid(surveyType, isLoad)
    {
        var store = Ext.create('Ext.data.Store', {
            id:'survey_store'+surveyType,
            autoLoad: false,
            fields: ['_id', 'title', 'userName', 'publishTime', 'endTime', 'surveyType'],
            pageSize: pageLimit, // items per page
            proxy: {
                type: 'ajax',
                url: WebRoot + '/nc/ajax/survey_list/' + surveyType,
                reader: {
                    rootProperty: 'rows',
                    totalProperty: 'total'
                }
            }
        });
        if(isLoad)
        {
            storeLoad(store);
        }
        store.on({
            endupdate:{
                fn:function(){
                    if(grid11.getView())
                    {
                        //console.log('viewready');
                        grid11.getView().refresh();
                    }
                }
            }
        });
        var title = '课中';
        if(surveyType == '1')
        {
            title = '课后';
        }
        var grid11 = Ext.create('Ext.grid.Panel', {
            id:'survey_grid'+surveyType,
            store: store,
            layout: 'fit',
            border: true,
            columns: [
                {
                    xtype: "rownumberer", text: "", width:40, align: 'center'
                },{
                text: "调研名称",
                dataIndex: 'title',
                width: 150,
                flex: 1,
                sortable: true,
                align: 'center',
                renderer: function(value, p, record)
                {
                    //return value;
                    return Ext.String.format(
                        '<a target="_self" href="' + WebRoot + '/nc/survey_detail/{0}/{1}" target="_blank">{2}</a>',
                            record.data.surveyType, record.data._id, value
                    );
                }
            }, {
                text: "发布人",
                dataIndex: 'userName',
                width: 100,
                sortable: true,
                align: 'center'
            }, {
                text: "发布时间",
                dataIndex: 'publishTime',
                width: 140,
                sortable: true,
                align: 'center'
            },{
                text: "结束时间",
                dataIndex: 'endTime',
                width: 140,
                sortable: true,
                align: 'center'
            }, {
                width: 100,
                text: "查看统计结果",
                sortable: false,
                dataIndex: '_id',
                renderer: renderView,
                align: 'center'
            },
                {
                width: 50,
                text: "编辑",
                sortable: false,
                dataIndex: '_id',
                renderer: renderEdit,
                align: 'center'
            }, {
                width: 80,
                sortable: false,
                text: "操作",
                dataIndex: 'surveyType',
                renderer: renderAction,
                align: 'center'
            }],
            dockedItems: [{
                xtype: 'toolbar',
                items: ["->",{
                    iconCls: 'icon-add',
                    text: '添加',
                    scope: this,
                    handler: function()
                    {
                        window.location = WebRoot +  '/nc/survey_opt/'+ surveyType;
                    }
                }]
            },getPaging(store)]
        });
        return grid11;
    }
    function storeLoad(store) {
        store.isLoad = true;
        store.load({
            params: {
                start: 0,
                limit: pageLimit
            }
        });
    }
    function renderView(value, p, record) {
        return Ext.String.format(
            '<a target="_self" href="' + WebRoot + '/nc/survey_show/{0}/{1}" target="_blank">查看</a>',
                    record.data.surveyType, value
        );
    }
    function renderEdit(value, p, record) {
        if (record.data.state == '未发布') {
            return Ext.String.format(
                '<a target="_self" href="' + WebRoot + '/nc/survey_opt/{0}/{1}" target="_blank">编辑</a>',
                    record.data.surveyType, value
            );
        }
        else {
            return '<a class="gray">编辑</a>';
        }
    }
    function renderAction(value, p, record) {
        if(record.data.state == '未发布'){
            return Ext.String.format(
                '<a onclick="lesson_action('+"'{0}',{1},"+"'survey_issue'"+')">发布调研</a>',
                    record.data._id, value
            );
        }
        else if(record.data.state == '已发布'){
            return Ext.String.format(
                '<a onclick="lesson_action('+"'{0}',{1},"+"'survey_end'"+')">结束调研</a>',
                    record.data._id, value
            );
        }
        else
        {
            return '<a class="gray">已结束</a>';
        }
    }

    //发布或者结束调研
    function lesson_action(id, surveyType, action) {
        var message = (action=='survey_end'?"结束调研":"发布调研");
        Ext.Msg.show({
            title:'提示',
            message: '确认'+message+'?',
            buttons: Ext.Msg.YESNO,
            icon: Ext.Msg.QUESTION,
            fn: function(btn) {
                if (btn === 'yes') {
                    var grid = Ext.getCmp("survey_grid"+surveyType);
                    Ext.Ajax.request({
                         url: WebRoot + '/nc/ajax/' + action,    //请求地址
                         //提交参数组
                         params: {
                             'csrfmiddlewaretoken':Ext.util.Cookies.get("csrftoken"),
                             _id:id,
                             survey_type: surveyType
                         },
                         //成功时回调
                         success: function(response, options) {
                             //获取响应的json字符串
                             var responseArray = Ext.util.JSON.decode(response.responseText);
                             if(responseArray['message'])
                             {
                                 var msg = Ext.Msg.alert('提示',responseArray['message']);
                             }
                             if(responseArray.success === true)
                             {
                                grid.store.reload();
                             }
                        },
                        failure : function(response, options) {
                            Ext.Msg.alert('提示', '内部错误');
                            return;
                        }
                    });
                }
            }
        });
    }

    Ext.onReady(function () {
        var surveyType = getSurveyType();
        var activeTab = parseInt(surveyType);
        var grid1,grid2;
        if(surveyType=='1')
        {
            grid1 = createGrid(0, false);
            grid2 = createGrid(1, true);
        }
        else
        {
            grid1 = createGrid(0, true);
            grid2 = createGrid(1, false);
        }

        var tabs1 = Ext.createWidget('tabpanel', {
            renderTo: Ext.getBody(),
            activeTab: activeTab,                       //指定默认的活动tab
            plain: true,                        //True表示tab候选栏上没有背景图片（默认为false）
            enableTabScroll: false,              //选项卡过多时，允许滚动
            defaults: {autoScroll: false},
            items: [{
                id: "tab_mid",
                title: '课中调研',
                html: "",
                items: [grid1],
                closable: false,                  //这个tab不可以被关闭
                listeners:{
                    activate: function (tab, eOpts) {
                        var isLoad = grid1.store.isLoad;
                        if(!isLoad)
                        {
                            storeLoad(grid1.store);
                        }
                        setSurveyType(0);
                        //console.log(parent.window.document.getElementById(id).data);
                        if(grid1.getView())
                        {
                            grid1.getView().refresh();
                        }
                    }
                }
            }, {
                id: "tab_after",
                title: '课后调研',
                html: "",
                items: [grid2],
                closable: false,                  //这个tab不可以被关闭
                listeners:{
                    activate: function (tab, eOpts) {
                        var isLoad = grid2.store.isLoad;
                        if(!isLoad)
                        {
                            storeLoad(grid2.store);
                        }
                        setSurveyType(1);
                        if(grid2.getView())
                        {
                            grid2.getView().refresh();
                        }
                    }
                }
            }]
        });
        //tabs1.on("iconchange", function(tab, eOpts){ console.log(tab);});
        Ext.on('resize',function(){
            if(grid1)
            {
                if(grid1.getView())
                {
                    grid1.getView().refresh();
                }
            }
            if(grid2)
            {
                if(grid2.getView())
                {
                    grid2.getView().refresh();
                }
            }
        });
    });
</script>
{% endblock %}
{% block body %}
{% endblock %}