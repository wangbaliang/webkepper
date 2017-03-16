/**
 * Created by wangyizhi on 2015/7/6.
 */
function getPaging(store)
{
    var paging =
    {
        xtype: 'pagingtoolbar',
        store: store, // same store GridPanel is using
        dock: 'bottom',
        displayInfo: true,
        items:['到第',{
            xtype: 'numberfield',
            itemId: 'pageItem',
            name: 'pageItem',
            width: 70,
            cls: Ext.baseCSSPrefix + ' tbar-page-number',
            allowDecimals: false,
            minValue: 1,
             allowBlank: false
        },'页',{
            text: '确定',
            handler: function () {
                var number = this.findParentByType("pagingtoolbar").child("#pageItem");
                if(number){
                    number.validate();
                    var errors = number.getErrors();
                    if(errors.length<1)
                    {
                        var num = parseInt(number.getValue());
                        var maxPage = this.findParentByType("pagingtoolbar").getPageData().pageCount;
                        if(num > maxPage)
                        {
                            num = maxPage;
                        }
                        store.loadPage(num);
                    }
                }
            }
        }]
    }
    return paging;
}