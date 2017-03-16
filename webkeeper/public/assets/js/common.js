/**
 * Created by wangyizhi on 2015/7/1.
 */
function showProgress(title) {
    var messageBox = Ext.MessageBox.show({
        title : '请稍等',
        msg : title,
        progressText : '',
        width : 200,
        progress : true,
        closable : false,
        animEl : 'loading'
    });
    // 控制进度速度
    var f = function(v) {
        return function() {
            var i = v / 11;
            Ext.MessageBox.updateProgress(i, '');
        };
    };

    for (var i = 1; i < 12; i++) {
        setTimeout(f(i), i * 150);
    }
    return messageBox;
}

//提示消息并跳转
function showConfirmMessage(message, mUrl, mTime)
{
	if(message)
	{
        //var isClose = true;
        if(mUrl!=null){
            if(mUrl.length > 0) {
                message += '，请等待跳转...';
            }
        }

        //var messageBox = Ext.MessageBox.show({
        //    title : '提示',
        //    msg : title,
        //    progressText : '',
        //    width : 200,
        //    progress : true,
        //    closable : false,
        //    animEl : 'loading',
        //    fn: function()
        //    {
        //        window.location =  mUrl;
        //    }
        //});

        var messageBox = Ext.Msg.alert('提示',message, function(){
            if(mUrl!=null)
            {
                if(mUrl.length > 0)
                {
                    showProgress('正在跳转，请稍后...');
                    window.location =  mUrl;
                }
            }
        });
		if(mTime==null || mTime=='')
		{
			mTime = 2000;
		}
		else if(mTime < 0)
		{
			mTime = 0;
		}
		if(mTime>0)
		{
			setTimeout(function()
			{
                if(mUrl != null) {
                    if (mUrl.length > 0) {
                        window.location =  mUrl;
                        return;
                    }
                }
				messageBox.close();
			},mTime);
		}
	}
}

//提示消息并跳转
function showMessage(message, mUrl, mTime)
{
	if(message)
	{
        var messageBox = Ext.MessageBox.show({
            title : '提示',
            msg : message,
            progressText : '',
            width : 200,
            progress : true,
            closable : false,
            animEl : 'loading'
        });
		if(mTime==null || mTime=='')
		{
			mTime = 2000;
		}
		else if(mTime < 0)
		{
			mTime = 0;
		}
		if(mTime>0)
		{
			setTimeout(function()
			{
                if(mUrl != null) {
                    if (mUrl.length > 0) {
                        window.location =  mUrl;
                        return;
                    }
                }
				messageBox.close();
			},mTime);
		}
	}
}

//加载进度条并跳转
function showProgressToUrl(title, url) {
    if(url)
    {
        window.location = url;
    }
    showProgress(title);
}

function getPar(par){
    //获取当前URL
    var local_url = document.location.href;
    //获取要取得的get参数位置
    var get = local_url.indexOf(par +"=");
    if(get == -1){
        return false;
    }
    //截取字符串
    var get_par = local_url.slice(par.length + get + 1);
    //判断截取后的字符串是否还有其他get参数
    var nextPar = get_par.indexOf("&");
    if(nextPar != -1){
        get_par = get_par.slice(0, nextPar);
    }
    return get_par;
}

//+---------------------------------------------------
//| 字符串转成日期类型
//| 格式 MM/dd/YYYY MM-dd-YYYY YYYY/MM/dd YYYY-MM-dd
//+---------------------------------------------------
function stringToDateTime(dateStr)
{
    var converted = Date.parse(dateStr);
    var myDate = new Date(converted);
    if (isNaN(myDate))
    {
        dateStr = dateStr.replace(/-/g,"/");
        myDate = new Date(dateStr);
    }
    return myDate;
}