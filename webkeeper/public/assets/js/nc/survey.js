/**
 * Created by wangyizhi on 2015/7/6.
 */
 function createQuestionGrid(rows, action)
{
    var render, store11 = createQuestionStore(rows);
    if(action=='read')
    {
        render = renderViewRead;
    }
    else
    {
        render = renderView;
    }

    var questionsGrid1 = Ext.create('Ext.grid.Panel', {
        style : "margin-top: 10px",
        store: store11,
        hideHeaders: true,
        border: false,
        columns: {
            items: [{
                dataIndex: 'question', renderer: renderView, flex: 1
            }]
        }
    });
    var length = rows?rows.length:0;
    if(length>0)
    {
        questionsGrid1.show();
    }
    else
    {
        questionsGrid1.hide();
    }
    return questionsGrid1;
}

function createQuestionStore(rows)
{
    var store = Ext.create('Ext.data.Store', {
        storeId:'questionStore',
        fields:['_id', 'question', 'questionType', 'option'],
        data: {'rows': rows},
        proxy: {
            type: 'memory',
            reader: {
                type: 'json',
                rootProperty: 'rows'
            }
        }
    });
    return store;
}
function renderViewRead(value, p, record, rowIndex) {
    renderSurvey(value, p, record, rowIndex, 'read');
}
function renderView(value, p, record, rowIndex) {
    return renderSurvey(value, p, record, rowIndex);
}
function renderSurvey(value, p, record, rowIndex, action) {
    var i,optionsStr = '';
    var optionSc = ["A", "B", "C", "D", "E"];
    if(record.data.option){
        for(i = 0; i < record.data.option.length; i++)
        {
            optionsStr += (optionSc[i] + '&nbsp;' + record.data.option[i] + '&nbsp;&nbsp;&nbsp;&nbsp;');
        }
    }
    var string;
    if(action=='read'){
         string = Ext.String.format("<div class='grid_item'><p>{0}、{1}</p><p class='p_option'>{2}</p></div>",
            rowIndex+1, value, optionsStr);
    }
    else{
         string = Ext.String.format("<div class='grid_item'><p>{0}、{1}<a class='a_action a_first' onclick='editOption({2})'>编辑</a>" +
            "<a class='a_action' onclick='delOption({2})'>删除</a></p><p class='p_option'>{3}</p></div>",
            rowIndex+1,value,rowIndex,optionsStr);
    }
    //console.log(string);
    return string;
}
