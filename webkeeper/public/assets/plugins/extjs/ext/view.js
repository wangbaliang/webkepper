/**
 * Created by wangyizhi on 2015/7/3.
 * coding: utf-8
 */

function createViewPannel(titles, url, title, fn)
{
    var items = createItems(titles);

    var myPanel = Ext.create('Ext.Panel', {
        layout: 'anchor',
        title: title,
        items: items
    });

    myPanel.on("afterrender", function(){
        if(url){
            var myMask = new Ext.LoadMask({
                msg    : '加载数据中...',
                target : myPanel
            });
            myMask.show();
            getDataByUrl(url, myPanel, myMask, fn);
        }
    });

    //myView.panel = myPanel;
    return myPanel;
}

function getDataByUrl(url, myPanel, myMask, fn) {
    Ext.Ajax.request({
        method: "get",
        url: url,
        //提交参数组
        params: {
            'csrfmiddlewaretoken': Ext.util.Cookies.get("csrftoken")
        },
        //成功时回调
        success: function (response, options) {
            var responseArray = Ext.util.JSON.decode(response.responseText);
            if(responseArray['message'])
            {
                 Ext.Msg.alert('提示', responseArray['message']);
            }
            if(responseArray['data'])
            {
                myPanel.data = responseArray['data'];
                //绑定数据
                readValues(myPanel, responseArray['data']);
                if(fn)
                {
                    if (typeof (fn) == 'function') {
                        fn();
                    }
                }
            }
            myMask.hide();
        },
        failure: function(response, options) {
            Ext.Msg.alert('提示', '加载失败，请刷新重试',function(){
                getDataByUrl(url, myPanel, myMask);
            });
        }
    });
}

function readValues(panel, data) {
    var rowCount = 0;
    if(panel) {
        var index;
        for (index in data) {
            //console.log(panel);
            var child = panel.child("#container_" + index);
            if (child) {
                var labelHtml = child.child("#" + index);
                if (labelHtml) {

                    labelHtml.body.dom.innerHTML = data[index];
                    if(labelHtml.body.dom.scrollHeight>30)
                    {
                        labelHtml.setHeight(labelHtml.body.dom.scrollHeight);
                    }
                    //console.log(html.body.scrollHeight);
                    //lable.body.update(data[index]);
                    //lable.setText(data[index]);
                    rowCount++;
                }
            }
        }
    }
    panel.doLayout();
    //panel.setHeight(panel.getSize().height);
    return rowCount;
}


function createItems(titles) {
    var items = [];
    var dataIndex,i= 0;
    for(dataIndex in titles) {
        var container ={
            itemId: "container_"+dataIndex,
            xtype: "container",
            layout: {
                type: 'hbox',
                align: 'stretch'
            },
            cls: 'label_container',
            items: [
            {
                xtype: 'label',
                text: titles[dataIndex]+'：',
                cls: 'label_title'
            },{
                itemId: dataIndex,
                html: "",
                border: false,
                cls: 'label_html',
                flex: 1
            }]
        };
        items[i]=container;
        i++;
    }
    return items;
}

function changeContainerLabel(view, dataIndex, child){
    return;
    //var panel = view.pannel;
    //var container = panel.child("#container_"+dataIndex);
    //if(container)
    //{
    //    //console.log(container);
    //    container.items[1] = child;
    //}
    //panel.doLayout();
}

function addContainer(pannel, dataIndex, dataTitle, child)
{
    //var container ={
    //    itemId: "container_"+dataIndex,
    //    xtype: "container",
    //    layout: {
    //        type: 'hbox',
    //        align: 'stretch'
    //    },
    //    cls: 'label_container',
    //    items: [
    //    {
    //        xtype: 'label',
    //        text: dataTitle+'：',
    //        cls: 'label_title'
    //    },child]
    //};
    //var itemsLength = pannel.items.length;
    //pannel.items(itemsLength,container);
    //pannel.doLayout();
}
