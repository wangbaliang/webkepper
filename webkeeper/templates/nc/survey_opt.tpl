{% extends 'common/base_layout.tpl' %}
{% block title %}调研问卷信息维护{% endblock %}
{% block page_style %}
    <link rel="stylesheet" type="text/css" href="{{ static('assets/plugins/extjs/writer.css') }}" rel="stylesheet" type="text/css"/>
    <script src="{{ static('assets/js/nc/survey.js') }}" type="text/javascript"></script>
    <script src="{{ static('assets/js/nc/survey-course-sel.js') }}" type="text/javascript"></script>
    <link rel="stylesheet" type="text/css" href="{{ static('assets/plugins/extjs/ux/css/ItemSelector.css') }}" rel="stylesheet" type="text/css"/>
{% endblock %}
{% block bottom_js %}
<script type="text/javascript">
    var main,surveyForm,courseGrid,myView,surveyId="{{survey_id}}",surveyType="{{survey_type}}";
    var loading = '';

    var questionsGrid = createQuestionGrid([]);
    var classContainer;// = surveyType=="1"?null:createClassCont();
    Ext.Loader.setConfig({enabled: true});
    Ext.Loader.setPath('Ext.ux', '{{ static('assets/plugins/extjs/ux') }}');
    Ext.require([
        'Ext.form.Panel',
        'Ext.ux.form.MultiSelect',
        'Ext.ux.form.ItemSelector',
        'Ext.tip.QuickTipManager',
        'Ext.ux.ajax.JsonSimlet',
        'Ext.ux.ajax.SimManager'
    ]);

    Ext.define('Writer.Form', {
        extend: 'Ext.form.Panel',
        alias: 'widget.writerform',
        requires: ['Ext.form.field.Text'],
        initComponent: function(){
            classContainer = surveyType=="1"?null:createClassCont();
            Ext.apply(this, {
                activeRecord: Object,
                frame: false,
                title: (surveyType=='1'?'课后':'课中')+'调研问卷',
                defaultType: 'textfield',
                bodyPadding: 0,
                fieldDefaults: {
                    labelAlign: 'right'
                },
                items: [{
                    itemId: 'form_container',
                    xtype: "container",
                    layout: "hbox",
                    style : "margin-top: 5px",
                    items: [{
                        itemId: '_id',
                        xtype: 'hiddenfield',
                        name: '_id'
                    },
                    {
                        itemId: 'title',
                        xtype: 'hiddenfield',
                        fieldLabel: '调研标题',
                        name: 'title',
                        labelCls: 'bold x-form-item-label',
                        allowBlank: false,
                        hidden: false
                    },{
                        itemId: 'lab_title',
                        xtype: 'label',
                        cls: 'x-form-item-label-default'
                    },{
                        xtype: 'button',
                        text: '编辑',
                        handler: this.onEditTile
                    }]
                },{
                    itemId: 'form_questions',
                    xtype: "container",
                    layout: "hbox",
                    style : "margin-top: 10px;margin-bottom: 10px",
                    items: [{
                        xtype: 'hiddenfield',
                        fieldLabel: '添加题目',
                        itemId: 'questionsStr',
                        name: 'questionsStr',
                        labelCls: 'bold x-form-item-label',
                        allowBlank: false,
                        hidden: false
                    },{
                        itemId: 'lab_title',
                        xtype: 'label',
                        cls: 'x-form-item-label-default'
                    },{
                        xtype: 'button',
                        text: '添加选择题',
                        style: "margin-right: 20px",
                        handler: function()
                        {
                            this.findParentByType("writerform").onEditObjective(questionsGrid.store.getCount());
                            myView.setY(200);
                        }
                    },{
                        xtype: 'button',
                        text: '添加填空题',
                        handler: function()
                        {
                            this.findParentByType("writerform").onEditSubjective(questionsGrid.store.getCount());
                            myView.setY(200);
                        }
                    }]
                }, questionsGrid,classContainer],
                dockedItems: [{
                    xtype: 'toolbar',
                    dock: 'bottom',
                    ui: 'footer',
                    items: ['->',
                    {
                        formBind : true,
                        type : 'submit',
                        iconCls: 'icon-save',
                        itemId: 'save',
                        text: '确定',
                        disabled: true,
                        scope: this,
                        handler: this.onSave
                    },'->']
                }]
            });
            this.callParent();
        },

        setActiveRecord: function(record){
            //console.log(record);
            this.activeRecord = record;
            if (record) {
                //this.down('#save').enable();
                var surveyFormValues = this.getValues();
                record.count = surveyFormValues.count;

                this.getForm().setValues(record);
                if(record.title)
                {
                    this.child("#form_container").child("#lab_title").setText(record.title);
                }

                //适用班级,课中调研
                if(surveyType=="0")
                {
                    if(record.surveyCourses)
                    {
                        classContainer.child("#form_class").child("#lab_course").setText(record.surveyCourses);
                    }
                }
                if(record.questions)
                {
                    //console.log("loadData:");
                    questionsGrid.store.loadData(record.questions);
                    if(!questionsGrid.isVisible())
                    {
                        questionsGrid.show();
                    }
                }
                else
                {
                    questionsGrid.hide();
                }
                main.setWidth(document.documentElement.clientWidth);
            } else {
                this.down('#save').disable();
                this.getForm().reset();
            }
        },

        onEditTile: function(){
            //console.log(surveyForm.activeRecord);
            var active = surveyForm.activeRecord;
            var title = '';
            if(active)
            {
                title = active.title?active.title:(active.data?active.data.title : '');
            }
            else
            {
                active = new Object();
                active.title = '';
            }
            var childItem = Ext.create('Ext.form.Panel',{
                items: [{
                    itemId: 'title',
                    fieldLabel: '调研标题',
                    xtype: 'textfield',
                    labelAlign: 'right',
                    name: 'title',
                    width: '85%',
                    minLength: 1,
                    maxLength: 30,
                    style: 'margin-top:5px;',
                    allowBlank: false,
                    value: title
                }],
                dockedItems: [{
                    xtype: 'toolbar',
                    dock: 'bottom',
                    ui: 'footer',
                    items: ['->', {
                        iconCls: 'icon-reset',
                        text: '取消',
                        scope: this,
                        handler: function()
                        {
                            myView.close();
                        }
                    },{
                        formBind : true,
                        iconCls: 'icon-save',
                        itemId: 'save',
                        text: '保存',
                        disabled: true,
                        scope: this,
                        handler: function()
                        {
                            var active = surveyForm.activeRecord;
                            active.title = childItem.child("#title").getValue();
                            surveyForm.setActiveRecord(active);
                            myView.close();
                        }
                    }]
                }]
            });
            createEditView('编辑调研标题',childItem);
            myView.setY(100);
            //childItem.child("#title").focus('end');
        },

        /**
         * 客观题信息维护
         **/
        onEditObjective: function(rowIndex){
            var active = this.getActiveQuestion(rowIndex);

            var states = Ext.create('Ext.data.Store', {
                fields: ['name', 'value'],
                data : [
                    {"name":"二选项", "value":"2"},
                    {"name":"三选项", "value":"3"},
                    {"name":"四选项", "value":"4"},
                    {"name":"五选项", "value":"5"}
                ]
            });

            // Create the combo box, attached to the states data store
            var select = Ext.create('Ext.form.ComboBox', {
                itemId: 'sel_option',
                xtype: 'combobox',
                store: states,
                queryMode: 'local',
                displayField: 'name',
                name: 'sel_option',
                flex: 3,
                valueField: 'value',
                editable: false,
                value: '2',
                listeners:{
                    'select': function(combobox)
                    {
                        var i,myForm = combobox.findParentByType("form"),options = [];
                        var value = parseInt(combobox.getValue());
                        for(i=0;i<value;i++){
                            options[i] = '';
                        }
                        //console.log(rowIndex);
                        changeOptionsButtons(myForm.child("#form"), options, this);
                    }
                }
            });
{#            select.setText("2");#}
            var childItem = Ext.create('Ext.form.Panel',{
                width: 360,
                bodyPadding: '10 30 10 10',
                frame: false,
                border: false,
                layout: "column",
                items: [
                {
                    xtype: 'component',
                    html: (rowIndex+1)+"、",
                    style: 'margin-top:13px;',
                    columnWidth: 0.08
                },
                {
                    itemId: 'form',
                    border: false,
                    layout: 'anchor',
                    columnWidth: 0.92,
                    //layout: "form",
                    items: [
                    {
                        itemId: "container",
                        xtype: "container",
                        layout: "hbox",
                        style: "margin-top:10px;",
                        fieldDefaults: {
                            anchor: '100%',
                            labelAlign: 'right'
                        },
                        items: [
                        {
                            itemId: 'title',
                            xtype: 'textfield',
                            blankText : '题目描述不能为空',
                            emptyText: "题目描述……",
                            name: 'title',
                            minLength: 1,
                            maxLength: 30,
                            allowBlank: false,
                            flex: 6,
                            value: active.question
                        },{
                            xtype: 'component',
                            flex: 2,
                            html: '&nbsp;&nbsp;&nbsp;&nbsp;'
                        },select
                        ]
                    }]
                }],
                dockedItems: [{
                    xtype: 'toolbar',
                    dock: 'bottom',
                    ui: 'footer',
                    items: ['->', {
                        iconCls: 'icon-reset',
                        text: '取消',
                        scope: this,
                        handler: function()
                        {
                            myView.close();
                        }
                    }, {
                        //formBind : true,
                        iconCls: 'icon-save',
                        itemId: 'save',
                        text: '确定',
                        //disabled: true,
                        scope: this,
                        handler: function()
                        {
                            var isValidate, i, formValues = childItem.getValues();
                            //验证
                            //childItem.getForm().isValid();
                            //验证标题
                            isValidate = childItem.child("#form").child("#container").child("#title").validate();
                            var sel_option = parseInt(formValues.sel_option);
                            var errors,option;
                            for (i = 0; i < sel_option; i++) {
                                //console.log
                                option = childItem.child("#form").child("#option" + i);
                                if (option) {
                                    option.validate();
                                    errors = option.getErrors();
                                    ////验证选项
                                    if (errors[0]) {
                                        isValidate = false;
                                    }
                                }
                            }
                            if (isValidate) {
                                //更新activeRecord的问题和选项
                                surveyForm.saveQuestions(rowIndex, childItem, 1);
                            }
                        }
                    }]
                }]
            });

            changeOptionsButtons(childItem.child("#form"), active.option, select);
            createEditView('',childItem);
        },

        //主观题
        onEditSubjective: function(rowIndex){
            var active = this.getActiveQuestion(rowIndex);
            // Create the combo box, attached to the states data store
            var childItem = Ext.create('Ext.form.Panel',{
                width: 360,
                bodyPadding: '10 30 10 10',
                frame: false,
                border: false,
                layout: "column",
                items: [
                {
                    xtype: 'component',
                    html: (rowIndex+1)+"、",
                    style: 'margin-top:13px;',
                    columnWidth: 0.08
                },
                {
                    itemId: 'form',
                    border: false,
                    layout: 'anchor',
                    columnWidth: 0.92,
                    items: [
                    {
                        itemId: "container",
                        xtype: "container",
                        layout: "hbox",
                        style: "margin-top:10px;",
                        fieldDefaults: {
                            anchor: '100%',
                            labelAlign: 'right'
                        },
                        items: [
                        {
                            itemId: 'title',
                            xtype: 'textfield',
                            blankText : '题目描述不能为空',
                            emptyText: "题目描述……",
                            name: 'title',
                            minLength: 1,
                            maxLength: 30,
                            allowBlank: false,
                            flex: 6,
                            value: active.question
                        }
                        ]
                    }]
                }],
                dockedItems: [{
                    xtype: 'toolbar',
                    dock: 'bottom',
                    ui: 'footer',
                    items: ['->', {
                        iconCls: 'icon-reset',
                        text: '取消',
                        scope: this,
                        handler: function()
                        {
                            myView.close();
                        }
                    }, {
                        formBind : true,
                        iconCls: 'icon-save',
                        itemId: 'save',
                        text: '确定',
                        handler: function()
                        {
                            //验证
                            if (childItem.getForm().isValid()) {
                                //更新activeRecord的问题和选项
                                surveyForm.saveQuestions(rowIndex, childItem, 0);
                            }
                        }
                    }]
                }]
            });
            createEditView('编辑题目',childItem);
        },

        saveQuestions:function(rowIndex, childItem, questionType)
        {
            var active = surveyForm.activeRecord;
            var i,question = new Object(),formValues = childItem.getValues(),options = formValues["option[]"];
            if(questionType==1)
            {
                var sel_option = parseInt(formValues.sel_option);
                question.questionType = 1;
                question.option = [];
                //获取选项
                for (i = 0; i < sel_option; i++) {
                    question["option"][i] = options[i];
                }
            }
            question.questionType = questionType;
            question.question = formValues.title;
            question.id =  "question_" + (rowIndex+1);
            var questions = Ext.pluck(questionsGrid.store.data.items, 'data');
            questions[rowIndex] = question;
            var key;
            for(key in questions)
            {
                questions[key].id = "question_" + (parseInt(key)+1);
            }
            active.questions = questions;

            //console.log(surveyForm.getValues());
            surveyForm.setActiveRecord(active);
            myView.close();
        },

        getActiveQuestion: function(rowIndex)
        {
            var active = questionsGrid.getStore().getAt(rowIndex);
            if(!active)
            {
                active = new Object();
                active.question = "";
                active.option = ["",""];
            }
            else
            {
                active = active.data;
            }
            return active;
        },

        onSave: function(btn){
            var surveyType = '{{survey_type}}';
            //console.log(surveyType);
            var message='',active = this.activeRecord,
                form = this.getForm();
            var values = form.getValues();
            if (!active) {
                //标题是否为空
                if(!values["title"]){
                    message = "调研标题不能为空";
                }
            }
            else{
                if(questionsGrid.store.data.items.length<1){
                    message = "题目不能为空";
                }
                else
                {
                    if(surveyType=='0') {
                        var classes = values["survey_course"];
                        if (!classes) {
                            message = "请选择适用班级";
                        }
                    }
                }
            }
            if(message!='')
            {
                Ext.Msg.alert('提示', message);
                return;
            }
            var questionsStr = Ext.encode(Ext.pluck(questionsGrid.store.data.items, 'data'));
            this.child("#form_questions").child("#questionsStr").setValue(questionsStr);

            //console.log(questionStr);
            if (form.isValid()) {

                // 提交到服务器操作
                form.doAction('submit', {
                    waitTitle: '请稍等...',
                    waitMsg: '正在保存信息...',
                    url : '{{ url('nc.survey_save') }}',// url路径
                    method : 'post',// 提交方法post或get
                    params : {'csrfmiddlewaretoken':Ext.util.Cookies.get("csrftoken"),'surveyType':surveyType},
                    // 提交成功的回调函数
                    success : function(form, action) {
                        if(action.result.message) {
                            btn.setDisabled(true);
                            showMessage(action.result.message, WebRoot + '/nc/survey_list/' + surveyType);
                        }
                            //showMessage(action.result.message, WebRoot + '/nc/survey_list/' + surveyType);
{#                            Ext.Msg.alert('提示',action.result.message, function(){#}
{#                                //window.location =  WebRoot + '/nc/survey_list/' + surveyType;#}
{#                            });#}
                    },
                    // 提交失败的回调函数
                    failure: function(form, action) {
                        if(action.result.message) {
                            showMessage(action.result.message);
                        }
                    }
                });
            }
        },

        onReset: function(){
            this.setActiveRecord(null);
            this.getForm().reset();
        }
    });

    function createInput(value,index) {
        if(!index)
        {
            index = '0';
        }
        var input = Ext.create('Ext.form.Text', {
            style: "margin-top:10px;",
            name: 'option[]',
            itemId: 'option'+index,
            anchor: '100%',
            minLength: 1,
            maxLength: 30,
            allowBlank: false,
            value: value,
            blankText:"不能为空"
        });
        return input;
    }

    function changeOptionsButtons(myForm, options, select)
    {
        var itemsLength = myForm.items.length;//5
        var optionsLength = options.length;//3
        var i;
        if(optionsLength!=itemsLength-1)
        {
            if(optionsLength>itemsLength-1)
            {
                //需添加input
                //console.log("添加input");
                for(i=0; i<optionsLength-itemsLength+1;i++)
                {
                    var input = createInput(options[itemsLength+i-1],itemsLength+i-1);
                    myForm.items.add(itemsLength+i, input);
                }
            }
            else if(optionsLength<itemsLength-1)
            {
                //需删除input
                for(i=0; i<itemsLength-optionsLength-1;i++)
                {
                    var input11 = myForm.items.get(optionsLength+i+1);//items[optionsLength+i+1];
                    //input11.des
                    //console.log(input11.getId());
                    input11.hide();
                }
            }
        }

        for(i=0; i<options.length;i++)
        {
            var input22 = myForm.items.get(i+1);
            if(input22)
            {
                input22.show();
            }
        }
        if(myForm.items.length<6)
        {
            var i,length = myForm.items.length;
            for(i=length-1;i<5;i++)
            {
                var input = createInput('',i);
                input.hide();
                myForm.items.add(i+1, input);
            }
        }
        myForm.doLayout();
        //console.log(myForm.items.length);
        //改变下拉框值
        if(select) {
            if (select.getValue != options.length) {
                select.setValue(options.length);
            }
        }
    }

    Ext.define('Survey.Setting', {
        extend: 'Ext.data.Model',
        fields: ['_id', 'title', 'questions','surveyType'],
        validators: {
            title: {
                type: 'length',
                min: 1
            },
            questions: {
                type: 'length',
                min: 1
            }
        }
    });

    function createClassCont() {
        var ClassCont = Ext.create('Ext.Panel', {
            layout: "anchor",
            items: [
            {
                xtype: "container",
                layout: "hbox",
                items: [{
                    xtype: 'label',
                    text: '选择适用班级和次数：',
                    cls: 'form_label bold'
                }]
            },{
                xtype: 'numberfield',
                fieldLabel: '调研次数',
                itemId: 'count',
                name: 'count',
                minValue: 1,
                allowBlank: false
            },{
                itemId: "form_class",
                xtype: "container",
                layout: "hbox",
                style: "padding-bottom:5px;",
                items: [{
                    itemId: 'hf_course',
                    xtype: 'hiddenfield',
                    fieldLabel: '适用班级',
                    name: 'survey_course',
                    allowBlank: false,
                    hidden: false,
                    width:104
                },{
                    itemId: 'lab_course',
                    xtype: 'label',
                    cls: 'x-form-item-label-default lab_item',
                    flex: 1
                }]
            },{
                style: "margin-left:110px;margin-bottom:10px;",
                xtype: 'button',
                text: '选择',
                handler: function(){
                    //加载所有适用班级
                    courseGrid = createCourseGrid('{{ url("nc.course_apply_list") }}', surveyForm.id);
                    createEditView('选择适用班级', courseGrid, 500);
                    courseGrid.setBodyStyle("padding-top","0px");
                },
                width: 70
            }]
        });
        return ClassCont;
    }


{#        var courseGrid1 = Ext.create('Ext.grid.Panel', {#}
{#            store: store11,#}
{#            flex: 1,#}
{#            selModel: {#}
{#                injectCheckbox: 0,#}
{#                mode: "SIMPLE",     //"SINGLE"/"SIMPLE"/"MULTI"#}
{#                checkOnly: true     //只能通过checkbox选择#}
{#            },#}
{#            selType: "checkboxmodel",#}
{#            border: false,#}
{#            columns: {#}
{#                items: [{#}
{#                    dataIndex: 'name', flex: 1, text: '名称'#}
{#                },{#}
{#                    dataIndex: 'teachers', flex: 1, text: '教师'#}
{#                }]#}
{#            },#}
{#            dockedItems: [{#}
{#                xtype: 'toolbar',#}
{#                dock: 'bottom',#}
{#                items: ['->',{#}
{#                    iconCls: 'icon-add',#}
{#                    text: '确定',#}
{#                    scope: this,#}
{#                    handler: function()#}
{#                    {#}
{#                        //获取选中行，给适用班级赋值#}
{#                        var records = courseGrid.getSelectionModel().getSelection();#}
{#                        if(records.length<1)#}
{#                        {#}
{#                            Ext.Msg.alert('提示', '请选择适用班级');#}
{#                        }#}
{#                        else#}
{#                        {#}
{#                            var courseArray = Ext.pluck(records, 'data');#}
{##}
{#                            //赋值#}
{#                            var coursesStr = Ext.encode(Ext.pluck(courseArray, 'id'));//Ext.encode(courses);#}
{#                            var surveyCourses = Ext.pluck(courseArray, 'name');#}
{#                            var active = surveyForm.activeRecord;#}
{#                            active.surveyCourses = surveyCourses;#}
{#                            active["survey_course"] = coursesStr;#}
{#                            surveyForm.setActiveRecord(active);#}
{#                            myView.close();#}
{#                            //classContainer.child("#form_class").child("#hf_course").setText(coursesStr);#}
{#                            //classContainer.child("#form_class").child("#lab_course").setText(surveyCourses);#}
{#                        }#}
{#                    }#}
{#                }]#}
{#            }]#}
{#        });#}


    function editOption(rowIndex)
    {
        var active = surveyForm.getActiveQuestion(rowIndex);
        if(active)
        {

            //问题类型，主观题0，客观题1
            if(active.questionType=="1"){
                surveyForm.onEditObjective(rowIndex);
            }
            else
            {
                surveyForm.onEditSubjective(rowIndex);
            }
        }
    }

    function delOption(rowIndex)
    {
        var questions = Ext.pluck(questionsGrid.store.data.items, 'data');
        questions.splice(rowIndex,1);
        questionsGrid.store.loadData(questions);
    }

    /**
     * 弹出编辑窗口
     * @param recode
     */
    function createEditView(title, childItem, height)
    {
        var width0 = 370;
        myView = Ext.create('Ext.window.Window', {
            constrainTo:main,
            modal:true,
            title: title,
            // 该面板布局类型
            layout: 'column',
            width: width0,
            //maxWidth: 500,
            minHeight: 115,
            x:200,
            // 不容许任意伸缩大小
            resizable: false,
            // 面板是否可以关闭及打开
            collapsible: false,
            // 关闭功能是否可以关闭及打开
            closable: true,
            // 窗体拖拽 默认是TRUE
            draggable: true,
            shadow: true,
            items: [childItem]
        });

        var width = childItem.width;
        if(width>width0)
        {
            myView.setWidth(width+10);
        }
        if(height)
        {
            myView.setHeight(height);
        }
        myView.show();
    }

    //function
    Ext.onReady(function () {
        Ext.tip.QuickTipManager.init();
        Ext.form.Field.prototype.msgTarget = 'under';
        surveyForm = Ext.create('Writer.Form', {
            columnWidth: 1,
            itemId: 'form',
            manageHeight: false,
            margin: '0 0 10 0'
        });
        main = Ext.create('Ext.container.Container', {
            id: "main_container",
            padding: '0 0 0 0',
            renderTo: document.body,
            layout:'fit',
            items: [ surveyForm ]
        });

        if(surveyId)
        {
            //var labTitle = main.child('#form').child("#form_container").child("#lab_title");
            surveyForm.getForm().load({
                method: 'GET',
                waitMsg : '加载数据中...',
                url: WebRoot + "/nc/ajax/survey_get/" + surveyType + "/" + '{{survey_id}}',
                success : function(form, action) {
                    if(action.result.data){
                        if(action.result.data["publishTime"])
                        {
                            showMessage("此调研已经发布", WebRoot + '/nc/survey_list/' + '{{survey_type}}');
                        }else{
                            surveyForm.setActiveRecord(action.result.data);
                        }
                    }
                },
                failure : function(form, action) {
                    //console.log("load_failure:");
                    if(action.result.message)
                    {
                        Ext.Msg.alert('提示',action.result.message, function(){
                            window.location = WebRoot + '/nc/survey_list/' + '{{survey_type}}';
                        });
                    }
                }
            });
        }
        Ext.on('resize',function(){
            if(main)
            {
                main.setWidth(document.documentElement.clientWidth);
            }
        });

    });

</script>
{% endblock %}
{% block body %}
{% endblock %}