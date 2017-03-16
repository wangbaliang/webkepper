/**
 * Created by wangyizhi on 2015/7/16.
 */
Ext.define('Ext.ux.form.SearchField', {
    extend: 'Ext.form.field.Text',

    alias: 'widget.searchfield',

    triggers: {
        search: {
            weight: 1,
            cls: Ext.baseCSSPrefix + 'form-search-trigger',
            handler: 'onSearchClick',
            scope: 'this'
        },
        clear: {
            weight: 0,
            cls: Ext.baseCSSPrefix + 'form-clear-trigger',
            hidden: true,
            handler: 'onClearClick',
            scope: 'this'
        }
    },

    hasSearch : false,
    paramName : 'name',

    initComponent: function() {
        var me = this;

        me.callParent(arguments);
        me.on('specialkey', function(f, e){
            if (e.getKey() == e.ENTER) {
                me.onSearchClick();
            }
        });
        me.on('change', function(){
            me.onSearchClick();
        });
        me.on('keydown', function(){
            me.onSearchClick();
        });
    },

    onClearClick : function(){
        var me = this;
        me.setValue('');
        me.getTrigger('clear').hide();
    },

    onSearchClick : function(){
        var me = this,
            value = me.getValue();
        var store = me.up('form').down("itemselector").fromField.store;
        store.clearFilter();
        if (value.length > 0) {

            me.getTrigger('clear').show();

            //console.log(me.up('form').down("itemselector"));
            store.filterBy(function(record) {
                var param = record.get(me.paramName);
                var index = param.indexOf(value);
                return index>=0;
            });
        }
    }
});

function createDockedItems(fieldId, surveyFormId) {
    return [
    {
        xtype: 'toolbar',
        dock: 'bottom',
        ui: 'footer',
        defaults: {
            minWidth: 75
        },
        items: ['->',{
            text: '确定',
            handler: function(){
                var store = Ext.getCmp(fieldId).up('form').down("itemselector").toField.store;
                if(store)
                {
                    var records = store.data.items;
                    if(records.length<1){
                        Ext.Msg.alert('提示', '请选择适用班级');
                    }else{
                        var courseArray = Ext.pluck(records, 'data');
                        //赋值
                        var coursesStr = Ext.encode(Ext.pluck(courseArray, 'id'));//Ext.encode(courses);
                        var surveyCourses = Ext.pluck(courseArray, 'name');
                        var surveyForm = Ext.getCmp(surveyFormId);
                        //console.log(surveyForm);
                        var active = surveyForm.activeRecord;
                        active.surveyCourses = surveyCourses;
                        active["survey_course"] = coursesStr;
                        surveyForm.setActiveRecord(active);
                        Ext.getCmp(fieldId).up('window').close();
                    }
                }
            }
        },{
            text: '取消',
            handler: function() {
                Ext.getCmp(fieldId).up('window').close();
            }
        }]
    }];
}

function createCourseGrid(url, surveyFormId)
{
    var storeCourses = Ext.create('Ext.data.Store', {
        autoLoad: true,
        fields:['_id','name', 'courseId'],
        proxy: {
            type: 'ajax',
            url: url,//'{{ url("nc.course_apply_list") }}',
            reader: {
                rootProperty: 'rows',
                totalProperty: 'total'
            }
        }
    });
    var filed1 = Ext.create('Ext.ux.form.SearchField', { store: storeCourses, width:168,border:true});
    //new Ext.form.Field({width:100,border:true});

    var tbar = Ext.create("Ext.Toolbar", {
        border: false,
        items: ["可选择班级","-","关键字：", filed1, { xtype: 'tbspacer', width: 15 },, '已选择班级'
        ]
    });
    /*
     * Ext.ux.form.ItemSelector Example Code
     */
    var itemSelectorId = 'itemselector-field';
    var isForm = Ext.widget('form', {
        tbar: tbar,
        width: 700,
        bodyPadding: 10,
        height: 400,
        layout: 'fit',
        border: false,
        bodyBorder: false,
        bodyStyle: "padding-top:0px;",
        items:[{
            xtype: 'itemselector',
            name: 'itemselector',
            id: itemSelectorId,
            anchor: '100%',
            imagePath: '../../../plugins/extjs/ux/images/',
            store: storeCourses,
            buttons: ['add', 'remove'],
            buttonsText: ['选择', '取消选择'],
            valueField: 'id',
            displayField: 'name',
            delimiter: ",",
            value: [],
            allowBlank: false,
            blankText: '不能为空',
            msgTarget: 'side'
            //msgTarget: 'under'
            //fromTitle: '可选择班级',
            //toTitle: '已选择班级'
        }],
        dockedItems: createDockedItems(itemSelectorId,surveyFormId)
    });
    storeCourses.load({
        callback: function(records, operation, success) {
            // do something after the load finishes
            var surveyForm = Ext.getCmp(surveyFormId);
            var active = surveyForm.activeRecord;
            if(active){
                if(active["survey_course"]){
                    var surveyCourseArray = Ext.decode(active["survey_course"]);
                    Ext.getCmp(itemSelectorId).setValue(surveyCourseArray);
                }
            }
        }
    });
    return isForm;
}