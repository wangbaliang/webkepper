/**
 * Created by Mars on 2016/1/23.
 */
'use strict';

var seasonStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['id', 'year', 'seasonType', 'startDay', 'endDay', 'exceptDays'],
    // pageSize: 20, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/season_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    }
});


var getSeasonItem = function getSeasonItem(seasonId) {
    return seasonStore.findRecord('id', seasonId);
};

var renderSeason = function renderSeason(seasonId) {
    var seasonRecord = getSeasonItem(seasonId);
    return getSeasonName(seasonRecord.data.year, seasonRecord.data.seasonType);
};

var getSeasonDisplayData = function getSeasonDisplayData() {
    var seasonData = seasonStore.getData().items;
    var result = [];
    for (var i = 0; i < seasonData.length; ++i) {
        var season = seasonData[i].data;
        result.push(
            [
                season.id,
                getSeasonName(season.year, season.seasonType),
            ]);
    }
    return result;
};

var transGradeType2Grade = function(GradeType) {
    var data = { 7: '初一', 8: '初二', 9: '初三', 10: '高一', 11: '高二', 12: '高三' };
    return data[GradeType];
}

var getYearDisplayData = function() {
    var seasonData = seasonStore.getData().items;
    var result = [];
    var reader = {};
    for (var i = 0; i < seasonData.length; i++) {
        var season = seasonData[i].data;
        if (!reader[season.year]) {
            result.push([
                season.year,
                getSeasonYearName(season.year)
            ]);
            reader[season.year] = true;
        }
    }
    return result;
}

var getYearSelectStore = function() {
    return Ext.create('Ext.data.ArrayStore', {
        storeId: 'year_select_store',
        fields: [
            { name: 'year_get', type: 'number' },
            { name: 'year_out', type: 'string' }
        ],
        data: getYearDisplayData()
    });
};

var getSeasonSelectStore = function() {
    return Ext.create('Ext.data.ArrayStore', {
        storeId: 'season_select_store',
        fields: [
            { name: 'id', type: 'number' },
            { name: 'text', type: 'string' },
        ],
        data: getSeasonDisplayData()
    });
};

var periodStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['id', 'seasonId', 'gradeType', 'startTime', 'endTime'],
    pageSize: 25, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/period_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    }
});
var allPeriodStore = Ext.create('Ext.data.Store', {
    autoLoad: true,
    fields: ['id', 'seasonId', 'gradeType', 'startTime', 'endTime'],
    pageSize: 10000, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/period_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        },
    },
    sorters: [{
        property: 'gradeType', // 指定要排序的列索引
        direction: 'ASC' // 降序，  ASC：赠序
    }, {
        property: 'startTime',
        direction: 'ASC'
    }]
});


var getPeriodDisplayData = function getSeasonDisplayData(store) {
    if (!store) {
        store = periodStore;
    }
    var periodData = store.getData().items;
    var result = [];
    for (var i = 0; i < periodData.length; ++i) {
        var period = periodData[i].data;
        result.push([period.id, rendPeriod(period)]);
    }
    return result;
};

var loadPeriodSelectStoreData = function loadPeriodSelectStoreData(targetStore, seasonId, gradeType, callback) {
    if (typeof(seasonId) === 'undefined' || typeof(gradeType) === 'undefined') {
        return;
    }

    var store = Ext.create('Ext.data.Store', {
        autoLoad: false,
        fields: ['id', 'seasonId', 'gradeType', 'startTime', 'endTime'],
        proxy: {
            type: 'ajax',
            url: '/tutor/ajax/period_find',
            reader: {
                rootProperty: 'data.rows',
                totalProperty: 'data.total'
            }
        }
    });

    store.load({
        params: {
            seasonId: seasonId,
            gradeType: gradeType
        },
        callback: function() {
            var data = getPeriodDisplayData(store);
            targetStore.loadData(data);
            if (callback) {
                callback();
            }
        }
    });
};

var getPeriodSelectStore = function getPeriodSelectStore(seasonId, gradeType) {
    var result = Ext.create('Ext.data.ArrayStore', {
        storeId: 'period_select_store',
        fields: [
            { name: 'id', type: 'number' },
            { name: 'text', type: 'string' }
        ],
        data: []
    });

    loadPeriodSelectStoreData(result, seasonId, gradeType);
    return result;
};


var renderPeriod = function renderPeriod(periodId) {
    var record = allPeriodStore.findRecord('id', periodId);
    return rendPeriod(record.data);
};
var renderGradeType = function renderGradeType(periodId) {
    var record = allPeriodStore.findRecord('id', periodId);
    return rendGradeType(record.data);
}
var rendGradeType = function rendGradeType(data) {
    var typeMap = { "0": "", "1": "初中", "2": "高中" };
    return typeMap[data.gradeType];
}


var rendPeriod = function rendPeriod(data) {
    return data.startTime + ' ~ ' + data.endTime;
};

var classTemplateStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['id', 'seasonId', 'periodId', 'subjectId', 'grade', 'cycleDay', 'startTime', 'endTime', 'maxClassNum', 'maxStudentNum'],
    pageSize: 25, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/class_template_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    }
});

var getCycleDaySelectStoreData = function getCycleDaySelectStoreData(store, seasonType) {
    if (typeof(seasonType) === 'undefined') {
        return;
    }
    var simpleSeasonData = [
        [5, '每周五'],
        [6, '每周六'],
        [7, '每周日']
    ];
    var vacationSeasonData = [
        [8, '周一到周六']
    ];
    var data = seasonType == 1 || seasonType == 3 ? simpleSeasonData : vacationSeasonData;
    store.loadData(data);
};

var getCycleDaySelectStore = function getCycleDaySelectStore(seasonType) {
    var store = Ext.create('Ext.data.ArrayStore', {
        storeId: 'cycle_day_select_store',
        fields: [
            { name: 'cycle', type: 'number' },
            { name: 'text', type: 'string' }
        ],
        data: []
    });
    getCycleDaySelectStoreData(store, seasonType);
    return store;
};

var getAllCycleDaySelectStore = function getAllCycleDaySelectStore() {
    var store = Ext.create('Ext.data.ArrayStore', {
        storeId: 'cycle_day_select_store',
        fields: [
            { name: 'cycle', type: 'number' },
            { name: 'text', type: 'string' }
        ],
        data: [
            [1, "每周一"],
            [2, "每周二"],
            [3, "每周三"],
            [4, "每周四"],
            [5, "每周五"],
            [6, "每周六"],
            [7, "每周日"],
            [8, "周一至六"],

        ]
    });
    return store;
}


var getGradeType = function getGradeType(grade) {
    var gradeMap = ['', 0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 2];
    return gradeMap[grade];
};

var gradeSelectStore = Ext.create('Ext.data.ArrayStore', {
    storeId: 'grade_select_store',
    fields: [
        { name: 'grade', type: 'number' },
        { name: 'text', type: 'string' }
    ],
    data: [
        [7, '初一'],
        [8, '初二'],
        [9, '初三'],
        [10, '高一'],
        [11, '高二'],
        [12, '高三']
    ]
});


var getPeriodAllSelectStore = function getPeriodAllSelectStore() {
    var store = Ext.create('Ext.data.ArrayStore', {
        storeId: 'period_all_select_store',
        fields: [
            { name: 'period_id', type: 'number' },
            { name: 'text', type: 'string' }
        ],
        data: []
    });
    getPeriodAllSelectStoreData(store);
    return store;
}
var getPeriodAllSelectStoreData = function getPeriodAllSelectStoreData(store) {
    var periodData = allPeriodStore.getData().items;
    var result = [];
    for (var i = 0; i < periodData.length; ++i) {
        var period = periodData[i].data;
        result.push(
            [
                period.id,
                renderGradeType(period.id) + " " + renderPeriod(period.id)
            ]);
    }
    store.loadData(result);
    //return result;
}

var subjectSelectStore = Ext.create('Ext.data.ArrayStore', {
    storeId: 'subject_select_store',
    fields: [
        { name: 'subject', type: 'number' },
        { name: 'text', type: 'string' }
    ],
    data: [
        [1, '语文'],
        [2, '数学'],
        [3, '英语'],
        [4, '物理'],
        [5, '化学'],
        [6, '生物'],
        [7, '历史'],
        [8, '地理'],
        [9, '政治'],
        [10, '文科综合'],
        [11, '理科综合'],
        [12, '其他'],
        [13, '科学']
    ]
});

// var getcoachItem = function getcoachItem(coachUsername) {
//   return coachStore.findRecord('userName', coachUsername);
// };

// var rendercoach = function rendercoach(coachUsername) {
//   var coachRecord = getcoachItem(coachUsername);
//   return getcoachName(coachRecord.data.year, coachRecord.data.coachType);
// };


var coachStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['userName', 'realName', 'areaCode', 'gradeType', 'subjectId', 'phone', 'qq', 'jobStatus', 'isForbidCity', 'schoolName', 'areaDisplay', 'rank'],
    pageSize: 25, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/coach_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    }
});


var studentStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['userName', 'realName', 'areaCode', 'grade', 'phone', 'qq', 'giftServiceTotal', 'usedServiceTotal', 'buyServiceTotal', 'schoolName', 'areaDisplay'],
    pageSize: 25, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/student_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    }
});

var areaStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: [
        { name: 'areaCode', type: 'string' },
        { name: 'text', type: 'string' }
    ],

    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/area_data',
        reader: {
            rootProperty: 'data',
            type: 'json'
        }
    }
});

var classCreateTaskStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['id', 'grade', 'subjectId', 'periodId', 'classDay', 'startTime', 'endTime', 'studentNum', 'remainNum', 'taskStatus', 'newClassNum', 'acceptCoachNum', 'testSuccessCoachNum', 'isNear'],
    pageSize: 25, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/class_create_task_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    }
});

//班级管理列表model
var classStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['classID', 'startTime', 'endTime',
        'coach', 'year', 'season', 'grade', 'subject', 'circleDay',
        'timeBlock', 'maxOneClass', 'numberOfPeople', 'percent', 'changeCoach', 'isClosed'
    ],
    pageSize: 25, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/class_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    }
});

var classTemporarySubstituteStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['classID', 'startTime', 'endTime',
        'coach', 'year', 'season', 'grade', 'subject', 'circleDay',
        'timeBlock', 'maxOneClass', 'numberOfPeople', 'percent', 'changeCoach'
    ],
    pageSize: 25, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/class_temporary_substitute_state',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    }
});

var classTemplateEnrollmentScheduleStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['templateId', 'season', 'subject',
        'grade', 'circleDay', 'startTime', 'endTime', 'totalNumber', 'usedNumber', 'currentClassNumber',
        'totalRestNumber', 'currentRestNumber', 'lastClassContinueNumber', 'lastClassUnContinueNumber', 'currentContinueNumber', 'lastClassNewNumber', 'lastWeekTotalNumber'
    ],
    pageSize: 50, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/class_template_enrollment_schedule',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    }
});

var classCreateTaskInviteStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['id', 'taskId', 'classTemplateId', 'coach', 'inviteStatus', 'inviteType', 'expireTime', 'inviteTime', 'coachPhone', 'coachRealName'],
    pageSize: 1000, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/task_invite_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    }
});

var succcessClassCreateTaskInviteStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['id', 'taskId', 'classTemplateId', 'coach', 'inviteStatus', 'inviteType', 'expireTime', 'inviteTime', 'coachPhone', 'coachRealName'],
    pageSize: 1000, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/task_invite_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    },
    filters: [
        function(item) {
            return item.get('inviteStatus') >= 2;
        }
    ]
});

var taskStudentStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['userName', 'realName', 'areaCode', 'grade', 'phone', 'qq', 'schoolName', 'areaDisplay'],
    pageSize: 1000, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/task_student_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        },
    },
    sorters: [{
        property: 'areaCode',
        direction: 'DESC'
    }, {
        property: 'userName',
        direction: 'ASC'
    }]
});

// 获取教练可用时段的内容
var getUsablePeriod = function(userName) {
    var list = Ext.create('Ext.data.Store', {
        autoLoad: true,
        fields: ['seasonId', 'startDay', 'endDay', 'periodId'],
        pageSize: 25, // items per page
        proxy: {
            type: 'ajax',
            url: '/tutor/ajax/coach_usable_period_by_id?userName=' + userName,
            reader: {
                rootProperty: 'data.rows',
                totalProperty: 'data.total'
            }
        }
    });
    return list;
}
var getFiredHistory = function(userName) {
    var list = Ext.create('Ext.data.Store', {
        autoLoad: true,
        fields: ['firedReason', 'firedDate', 'operator', 'operateType'],
        pageSize: 25, // items per page
        proxy: {
            type: 'ajax',
            url: '/tutor/ajax/fire_coach_info_by_name?userName=' + userName,
            reader: {
                rootProperty: 'data.rows',
                totalProperty: 'data.total'
            }
        }
    });
    return list;
}

// 报名情况列表
var getEnlistList = function(userName) {
    var list = Ext.create('Ext.data.Store', {
        autoLoad: true,
        fields: ['subjectId', 'classId', 'cycleDay', 'period_id'],
        pageSize: 25, // items per page
        proxy: {
            type: 'ajax',
            url: '/tutor/ajax/enlist_list_by_user_name?userName=' + userName,
            reader: {
                rootProperty: 'data.rows',
                totalProperty: 'data.total'
            }
        }
    });
    return list;
}

//获取学生所在的班级列表
var getClassListOfStudent = function(userName) {
    var list = Ext.create('Ext.data.Store', {
        autoLoad: true,
        fields: ['subjectId', 'classId', 'cycleDay', 'period_id'],
        pageSize: 100, // items per page
        proxy: {
            type: 'ajax',
            url: '/tutor/ajax/class_list_of_student_by_user_name?userName=' + userName,
            reader: {
                rootProperty: 'data.rows',
                totalProperty: 'data.total'
            }
        }
    });
    return list;
}

var getStudentInClassList = function(class_id) {
    var list = Ext.create('Ext.data.Store', {
        autoLoad: true,
        fields: ['userName', 'realName', 'phone', 'firstClassDate', 'lastClassDate', 'areaDisplay'],
        pageSize: 100, // items per page
        proxy: {
            type: 'ajax',
            url: '/tutor/ajax/student_info_in_class?class_id=' + class_id,
            reader: {
                rootProperty: 'data.rows',
                totalProperty: 'data.total'
            }
        }
    });
    return list;
}

var reservationStoreInTemplate = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['id', 'seasonId', 'periodId', 'subjectId', 'grade',
        'cycleDay', 'startTime', 'endTime', 'maxClassNum', 'maxStudentNum', 'unallotStudentNumber', 'minNeededCoachNumber', 'usableCoachNumber', 'allotStudentNumber', 'allStudentNumber'
    ],
    pageSize: 25, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/reservation_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    }
});

var getTempReplaceClassTimeStore = function getTempReplaceClassTimeStore(class_id) {

    var store = Ext.create('Ext.data.ArrayStore', {
        autoLoad: false,
        fields: [
            { name: 'classTime', type: 'string' },
            { name: 'timeBlock', type: 'string' },
        ],
        proxy: {
            type: 'ajax',
            url: '/tutor/ajax/temp_replace_class_time?class_id=' + class_id,
            reader: {
                rootProperty: 'data.rows',
                totalProperty: 'data.total'
            },
        },

        writer: {
            type: "json"
        }
    });
    store.load();
    return store;
}


var monitorCoachStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    listeners: {
        beforeload: function(store, operation) {
            // 表示取课程+教练数据
            this.getProxy().setExtraParam("type", 0);
            // 表示取非异常数据
            this.getProxy().setExtraParam("unusual", 0)
            return true;
        }
    },
    fields: ['classID', 'startTime', 'endTime', 'startDate',
        'year', 'season', 'grade', 'subject', 'circleDay',
        'coach', 'realName', 'coachStatus', 'coachOnline', 'disconnectTime', 'phone'
    ],
    pageSize: 1000, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/monitor_class_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    },
    sorters: [{
        property: 'disconnectTime',
        direction: 'DESC'
    }, {
        property: 'classID',
        direction: 'ASC'
    }]
});

var uMonitorCoachStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    listeners: {
        beforeload: function(store, operation) {
            // 表示取课程+教练数据
            this.getProxy().setExtraParam("type", 0);
            // 表示取异常数据
            this.getProxy().setExtraParam("unusual", 1)
            return true;
        }
    },
    fields: ['classID', 'startTime', 'endTime', 'startDate',
        'year', 'season', 'grade', 'subject', 'circleDay',
        'coach', 'realName', 'coachStatus', 'coachOnline', 'disconnectTime', 'phone'
    ],
    pageSize: 1000, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/monitor_class_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    },
    sorters: [{
        property: 'disconnectTime',
        direction: 'DESC'
    }, {
        property: 'classID',
        direction: 'ASC'
    }]
});

var monitorStudentStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    listeners: {
        beforeload: function(store, operation) {
            // 表示取课程+学生数据
            this.getProxy().setExtraParam("type", 1);
            // 表示取非异常数据
            this.getProxy().setExtraParam("unusual", 0)
            return true;
        }
    },
    fields: ['classID', 'startTime', 'endTime', 'startDate',
        'year', 'season', 'grade', 'subject', 'circleDay',
        'studentNum', 'loginNum', 'onlineNum', 'notlogNum',
        'loginPercent', 'onlinePercent', 'offlineNum'
    ],
    pageSize: 1000, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/monitor_class_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    },
    sorters: [{
        property: 'loginNum',
        direction: "ASC"
    }]
});

var uMonitorStudentStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    listeners: {
        beforeload: function(store, operation) {
            // 表示取课程+学生数据
            this.getProxy().setExtraParam("type", 1);
            // 表示取异常数据
            this.getProxy().setExtraParam("unusual", 1)
            return true;
        }
    },
    fields: ['classID', 'startTime', 'endTime', 'startDate',
        'year', 'season', 'grade', 'subject', 'circleDay',
        'studentNum', 'loginNum', 'onlineNum', 'notlogNum',
        'loginPercent', 'onlinePercent', 'offlineNum'
    ],
    pageSize: 1000, // items per page
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/monitor_class_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    },
    sorters: [{
        property: 'loginNum',
        direction: "ASC"
    }]
});

var coachHiringStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['userName', 'realName', 'areaDisplay', 'schoolName', 'gradeType', 'subjectId', 'phone', 'qq'],
    pageSize: 25,
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/coach_hiring_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    }
});

var changeCoachTaskStore = Ext.create('Ext.data.Store', {
    autoLoad: false,
    fields: ['classID', 'originCoach', 'seasonId', 'grade', 'subjectId', 'circleDay', 'periodId', 'startTime', 'endTime',
      'newCoach', 'beginDate', 'status'],
    pageSize: 25,
    proxy: {
        type: 'ajax',
        url: '/tutor/ajax/change_coach_status_list',
        reader: {
            rootProperty: 'data.rows',
            totalProperty: 'data.total'
        }
    }
});

var RankStore = Ext.create('Ext.data.Store', {
  autoLoad: false,
  autoSync:false,
  fields: ['id', 'rank', 'spring_base_num', 'spring_max_num', 'winter_base_num', 'winter_max_num'],
  pageSize: 1000,
  proxy: {
    type: 'ajax',
    reader: {
      rootProperty: 'data.rows',
      totalProperty: 'data.total'
    },
    writer: {
        writeAllFields : false,  //just send changed fields
        allowSingle :false      //always wrap in an array
    },
    api: {
        read: '/tutor/ajax/get_rank_class_num',
        update: '/tutor/ajax/update_rank_class_num',
    }
  },
  listeners: {
    write: function(store, operation, opts){
            // console.log('wrote!');
            // console.log(operation.getRecords())
            // console.log(operation)
            // Ext.each(operation.getRecords(), function(record){
            //     console.log(record)
            //     if (record.dirty) {
            //         record.commit();
            //     }
            // });
        },
    update : function(){
        // console.log(this.proxy.reader.rawData);
    },
    beforesync: function (options, eOpts) {
        // console.log(options)
    }
  },
});


Ext.Ajax.on('beforerequest', function (conn, options) {
    if (!(/^http:.*/.test(options.url) || /^https:.*/.test(options.url))) {
        if (typeof(options.headers) == "undefined") {
            options.headers = {'X-CSRFToken': Ext.util.Cookies.get('csrftoken')};
        } else {
            options.headers.extend({'X-CSRFToken': Ext.util.Cookies.get('csrftoken')});
        }
    }
}, this);
