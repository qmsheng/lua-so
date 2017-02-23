local msg = {
	-- 返回成功
	MSG_SUCCESS				                ={"0", "ok!"},
	MSG_SUCCESS_WITH_RESULT			        ={"0", "%s"},

	--> 参数错误
	MSG_ERROR_REQ_FAILED_GET_SECRET                     ={"ME01002", "appKey error"},

	MSG_ERROR_ACCESS_TOKEN_NOT_MATCH                    ={"ME01003", "access token not matched"},
	MSG_ERROR_ACCESS_TOKEN_EXPIRE                       ={"ME01004", "access token expired"},
	MSG_ERROR_ACCESS_TOKEN_NO_AUTH                      ={"ME01005", "access token not this authorization"},


	MSG_ERROR_REQ_BAD_JSON                              ={"ME01006", "error json data!"},

	MSG_ERROR_REQ_SIGN                                  ={"ME01019", "sign is not match!"},

	--> mysql
	MSG_DO_MYSQL_FAILED		                            ={"ME01020", "mysql failed!"},
	--> redis
	MSG_DO_REDIS_FAILED		                            ={"ME01021", "redis failed!"},
	--> 系统错误
	SYSTEM_ERROR                                        ={"ME01022", "internal data error!"},

	MSG_ERROR_REQ_ARG			                        ={"ME01023", "%s is error!"},
	MSG_ERROR_REQ_NO_BODY                               ={"ME01024", "http body is null!"},

	--> htt
	MSG_DO_HTTP_FAILED		                            ={"ME01025", "http failed!"},
	-->当有多人同时进行请求时，只处理一个请求，后面的请求便会报这个错误，目前只用在accountapi/api/add_custom_account and generate_daoke_account 中
	MSG_ERROR_SYSTEM_BUSY                                   ={"ME01026", "system is busy now !"},

	--> 结果错误
	MSG_ERROR_REQ_CODE			                        ={"ME18001", "%s"},        ---- 即将废弃 , 新api杜绝使用此错误码 2015-04-18 
	MSG_ERROR_USER_NAME_EXIST		                    ={"ME18002", "user name is already exist!"},
	MSG_ERROR_SINA_OAUTH_NOT_EXIST	                    ={"ME18003", "sina oauth is not exist in db!"},

	MSG_ERROR_MORE_RECORD	                            ={"ME18004", "%s has more record in db!"},

	MSG_ERROR_FIELD_NOT_EXIST	                        ={"ME18005", "this input field does not exist"},
	MSG_ERROR_IMEI_HAS_NOT_BIND                         ={"ME18006", "IMEI has not bind!"},
	MSG_ERROR_SINA_OAUTH_IS_EXPIRE                      ={"ME18007", "sina oauth access token has expire!"},
	MSG_ERROR_NO_POWER_ON                               ={"ME18008", "mirrtalk is not power on!"},
	MSG_ERROR_CONFIG_NOT_EXIST	                        ={"ME18009", "default config does not exist!"},
	MSG_ERROR_ACCOUNT_NOT_EXIST                         ={"ME18010", "this third account does not exists!"},
	MSG_ERROR_ACCOUNT_EXIST                             ={"ME18011", "this third account has existed!"},
	MSG_ERROR_MTNUM_NO_ACCOUNT_ID                       ={"ME18012", "this mirrtalkNumber has not accountID"},

	-- weibo group
	MSG_ERROR_CANNOT_DEL                                ={"ME18013", "this user cannot be deleted"},
	MSG_ERROR_CODE_USER_NO_GROUP                        ={"ME18014", "this user hasn't this group"},

	MSG_ERROR_ACCOUNT_ID_NO_MONEY                       ={"ME18015", "this accountID has no finance information!"},
	MSG_ERROR_NO_DAOKE_PWD                              ={"ME18016", "no daoke password"},
	MSG_ERROR_MONEY_NOT_ENOUGH_2                        ={"ME18017", "the withdraw amount is larger than the apply withdraw amount:%s"},
	MSG_ERROR_NO_MONEY                                  ={"ME18018", "this user has no money"},
	MSG_ERROR_NOT_ALLOW_CHANGE_DEPOSIT_TYPE             ={"ME18019", "deposit type is valid, not allow to change it"},
	MSG_ERROR_NOT_ALLOW_WITHDRAW                        ={"ME18020", "no right to withdraw the deposit"},
	MSG_ERROR_NOT_ALLOW_EXCHANGE                        ={"ME18021", "no right to exchange the WEME"},


	MSG_ERROR_DEL_TOO_MANY                              ={"ME18025", "delete too many members"},

	-- reward（众酬)---[18030--18051]---
	-- 设备编号已经存在
	MSG_ERROR_IMEI_EXIST	                        ={"ME18030", "IMEI is already exist!"},
	--设备编号不存在
	MSG_ERROR_IMEI_NOT_EXIST	                        ={"ME18031", "IMEI is not exist!"},
	--设备编号非法
	MSG_ERROR_IMEI_ILLEGAL                              ={"ME18032", "IMEI is illegal!"},
	--没有提现账户
	MSG_ERROR_NO_WITHDRAW_ACCOUNT                       ={"ME18033", "no account of withdrawing"},
	--没有押金密码
	MSG_ERROR_NO_DEPOSIT_PWD                            ={"ME18034", "no deposit password"},
	--押金密码不匹配
	MSG_ERROR_DEPOSIT_PWD_NOT_MATCH                     ={"ME18035", "deposit password is not matched"},
	--用户没有支付押金     
	MSG_ERROR_NOT_PAY_DEPOSIT                           ={"ME18036", "the user hasn't paid the deposit"},
	--申请提现金额大于可用金额 
	MSG_ERROR_MONEY_NOT_ENOUGH                          ={"ME18037", "the applying amount is larger than the usable amount:%s"},
	--还没达到允许提现时间
	MSG_ERROR_TIME_TOO_EARLY                            ={"ME18038", "it's not up to the withdrawable time:%s"},
	--WE码不存在
	MSG_ERROR_WECODE_NOT_EXIST	                        ={"ME18039", "WECODE is not exist!"},
	--WE码已经期满
	MSG_ERROR_WECODE_EXPIRE                             ={"ME18040", "WECODE has expired!"},
	--用户没有申请取消合约
	MSG_ERROR_NOT_APPLY_QUIT_CONTRACT                   ={"ME18041", "the user hasn't applied quit contract"},
	--用户没有申请换货
	MSG_ERROR_NOT_APPLY_EXCHANGE                        ={"ME18042", "the user hasn't applied exchanging mirrtalk"},

	----- 2015-10-12 错误提示内容固定,禁止出现不缺定的
	----- modify by jiang z.s.  ME18043 
	--此imei设备不能使用
	MSG_ERROR_IMEI_UNUSABLE                             ={"ME18043", "the IMEI is unusable"},

	--奖励类型不存在
	MSG_ERROR_REWARD_TYPE_NOT_EXIST			       ={"ME18044", "reward type is not exist!"},
	MSG_ERROR_REWARD_TYPE_UNUSABLE                      ={"ME18045", "the reward type is unusable"},
	--押金类型非法
	MSG_ERROR_DEPOSIT_TYPE_ILLEGAL                      ={"ME18046", "the deposit type is illegal!"},
	MSG_ERROR_DEPOSIT_TYPE_UNUSABLE                     ={"ME18047", "the deposit type is unusable"},
	--输入金额与提供金额不匹配
	MSG_ERROR_DEPOSIT_AMOUNT_NOT_MATCH                  ={"ME18048", "the input deposit amount is not match the given deposit amount"},
	MSG_ERROR_HAS_SAME_REWARD_TYPE                      ={"ME18049", "the user has the same rewards type"},
	MSG_ERROR_WECODE_UNUSABLE                           ={"ME18050", "WECODE has expired!"},
	MSG_ERROR_BUSSINESS_ID_NOT_EXIST	              	={"ME18051", "business ID not exist!"},
	-- end of reward

	-- weibo group
	MSG_ERROR_GROUP_EXIST				                ={"ME18052", "this group is already exist!"},
	MSG_ERROR_ACCOUNT_ID_NOT_EXIST                      ={"ME18053", "this accountID is not exist!"},
	MSG_ERROR_GROUP_ID_NOT_EXIST                        ={"ME18054", "this groupID is not exist!"},
	MSG_ERROR_GROUP_ID_UNUSABLE                         ={"ME18055", "this groupID is unusable"},
	MSG_ERROR_APPLICANT_NOT_EXIST                       ={"ME18056", "this applyAccountID is not group member!"},
	MSG_ERROR_NO_DEL_RIGHT                              ={"ME18057", "this applicant hasn't delete right"},
	MSG_ERROR_DEL_ACCOUNT_ID_NOT_EXIST                  ={"ME18058", "this deleteAccountID is not group member!"},


	-- account api
	MSG_ERROR_IMEI_HAS_BIND                             ={"ME18059", "IMEI has been bind!"},
	MSG_ERROR_ACCOUNT_ID_NO_SERVICE                     ={"ME18060", "accountID is not in service!"},
	MSG_ERROR_USER_NAME_NOT_EXIST	                ={"ME18061", "user name is not exist!"},
	MSG_ERROR_USER_NAME_UNUSABLE                        ={"ME18062", "user name is not in service!"},
	MSG_ERROR_PWD_NOT_MATCH                             ={"ME18063", "password is not matched"},

	MSG_ERROR_GROUP_MEMBER_EXIST                        ={"ME18064", "this user already in the group"},

	MSG_ERROR_NO_AUTH                                   ={"ME18065", "this user hasn't authorization"},
	MSG_ERROR_AUTH_EXPIRE                               ={"ME18066", "this user hasn't authorization"},

	-- reward api
	MSG_ERROR_IMEI_BEEN_USED	                        ={"ME18067", "IMEI has already been used!"},
	--
	MSG_ERROR_NOT_MOBILE_AUTH	                        ={"ME18068", "user mobile hasn't authorization!"},

	MSG_ERROR_REDIRECT_URL_NOT_MATCH	                ={"ME18069", "redirect url don't match!"},
	MSG_ERROR_AUTHORIZATION_CODE_NOT_EXIST              ={"ME18070", "Authorization code don't exist!"},
	MSG_ERROR_AUTHORIZATION_CODE_EXPIRE                 ={"ME18071", "Authorization code expire!"},

	MSG_ERROR_REFRESH_TOKEN_NOT_EXIST                   ={"ME18072", "Refresh Token don't exist!"},
	MSG_ERROR_REFRESH_TOKEN_EXPIRE                      ={"ME18073", "Refresh Token expire!"},

	MSG_ERROR_CLIENT_APP_KEY_NOT_EXIST                  ={"ME18074", "app key don't exist!"},
	MSG_ERROR_NOT_ALLOW_CREATE_GROUP                  	={"ME18075", "not allow to create group!"},

	--> developer

	MSG_ERROR_WAIT_AUDIT                                ={"ME18076", "developer Info is waiting audit"},
	MSG_ERROR_AUDIT_SUCCESS                             ={"ME18078", "developer Info have audit success"},
	MSG_ERROR_DEVELOPER_NOT_EXIST                       ={"ME18079", "developer has not registered !"},
	MSG_WEBSITE_NOT_EXIST                               ={"ME18080", "website is not exist !"},

	----WEME Setting
	MSG_ERROR_OFFLINE                                  ={"ME18081", "user must online"},
	MSG_NO_BUSINESS_INFO                                ={"ME18082", "this appKey has no business info !"},
	MSG_ERROR_IMEI_NOT_MATCH_APPKEY                     ={"ME18083", "this IMEI is not match current business appKey !"},


	MSG_ERROR_UNABLE_APP                                ={"ME18084", "this app is unable to use!"},
	MSG_ERROR_DEVELOPER_NOT_VERIFIED                    ={"ME18085", "this developer has not been verified !"},
	MSG_ERROR_APP_NOT_EXIST                             ={"ME18086", "this app is not exist!"},
	MSG_ERROR_CLIENT_APPKEY_NOT_EXIST                   ={"ME18087", "clientAppKey is not exist !"},
	MSG_ERROR_CLIENT_APPKEY_UNUSABLE                    ={"ME18088", "clientAppKey is unusable !"},
	MSG_ERROR_NO_APPLY                                  ={"ME18089", "have no such apply !"},
	MSG_ERROR_CONTROL_FREQUENCY                        ={"ME18090", "ERROR"},    ----废弃 2015-04-07 jiang z.s. 
	MSG_ERROR_VOICECOMMAND_NOT_SETTING                ={"ME18091", "voicecommand not set"}, --用户未设置+键的操作   
	MSG_ERROR_TEMPCHANNEL                               ={"ME18092", "current channel not start"},    ---- 当前临时频道不是直播模式
	MSG_ERROR_ADMIN_HAS_NO_GROUP                        ={"ME18093", "this administrator has no business group !"},

	--sharePoints
	MSG_ERROR_POINTS_UNUSABLE                           ={"ME18094", "this user has no share points"},
	MSG_ERROR_POINTS_HAS_MORE_RECORDS                   ={"ME18095", "the same share points records more than one !"},
	MSG_ERROR_POINTS_HAS_BEEN_GOTTEN                    ={"ME18096", "the share points has been gotten !"},
	MSG_ERROR_POINTS_HAS_OVERTIME                       ={"ME18097", "this share points has overtime"},
	MSG_ERROR_POINTS_MUST_BIG_THAN_ZERO                 ={"ME18098", "user's share points must bigger than zero"},
	MSG_ERROR_LEVEL_OUT_OF_RANGE                        ={"ME18099", "user's level has out of range "},
	MSG_ERROR_POINTS_HAS_DISPATCHED                     ={"ME18100", "share points has dispatched alreadly !"},
	MSG_ERROR_HAS_NO_GROWTH_INFO                        ={"ME18101", "this user has no growth information !"},

	MSG_ERROR_TEMPCHANNEL_LIVE_MODE                   = {"ME18102", "current Channel already live mode"},

	MSG_ERROR_TEMPCHANNEL_DISBAND_MODE               = {"ME18103", "current Channel already disband mode"},

	---- 当前用户申请的频道已经被审核通过了
	MSG_ERROR_USER_CHANNEL_EXISTS                     = {"ME18104", "current user channel already exist"},

	---- 当前用户重复提交相同的数据
	MSG_ERROR_USER_CHANNEL_REP_SUBMITTED             = {"ME18105", "Repeat submitted" },

	---- 当前用户的频道已经达到最大值, 
	MSG_ERROR_USER_CHANNEL_MAX_COUNT                  = {"ME18106", "user channel Maximum" },

	---- 唯一码错误
	MSG_ERROR_USER_CHANNEL_UNIQUECODE                 = {"ME18107", "uniquecode is error " },

	---- 有效的邀请码太多,需要先删除一些无效的
	MSG_ERROR_USER_CHANNEL_LIST_MAX_COUNT           = {"ME18108", "user too many" },

	---- 当前频道编码错误 
	MSG_ERROR_USER_CHANNEL_IDX                           = {"ME18109", "channel number is error" },

	-- map api [ME18110 ~ ME18300]
	MSG_ERROR_FAILED_POINT_MATCH_ROAD                 = {"ME18110", "location failed!"},
	-- +++++++++++++++++++

	-- channel Info [ME18300 ~ ME18500 ] 
	---- 之前从未之前从未关注过
	MSG_ERROR_USER_CHANNEL_UNFOLLOW                    = {"ME18301", "before not follow" },

	---- 禁止关注自己创建的微频道
	MSG_ERROR_USER_CHANNEL_FOLLOW_SELF                 = {"ME18302", "do not follow yourself" },

	---- 当前已经是关注状态,不需要再关注
	MSG_ERROR_USER_CHANNEL_FOLLOWED                    = {"ME18303", "do not repeat follow"},

	---- 当前已经是取消关注状态,请不要继续操作取消关注
	MSG_ERROR_USER_CHANNEL_UNFOLLOWED                 ={"ME18304", "do not repeat unfollow" },

	---- 群聊频道管理员不能管理自己
	MSG_ERROR_USER_CHANNEL_MG_SELF                     ={"ME18305", "do not manage self" },

	---- 当前不是群聊频道管理员
	MSG_ERROR_USER_CHANNEL_NOT_MG                     ={"ME18306", "you are not manager" },

	---- 文本转语音失败,审核微频道
	MSG_ERROR_TXT2VOICE_FAILED                            ={"ME18307", "txt2voice failed!" },

	---- 用户不能加入自己的群聊频道,创建的时候已经加入
	MSG_ERROR_USER_CHANNEL_JOIN_SELF                     ={"ME18308", "do not join yourself" },

	---- 当前用户已经加入该频道
	MSG_ERROR_USER_CHANNEL_ALREADY_JOINED               ={"ME18309", "already joined" },

	---- 当前验证消息已经处理
	MSG_ERROR_USER_CHANNEL_MSG_DEAL                      ={"ME18310", "message is dealed" },

	---- 当前群聊频道已经关联按键,不能退出,(需要取消关联才能退出)
	MSG_ERROR_USER_CHANNEL_IS_BINDED                       ={"ME18311", "current channel is binded" },

	---- 当前用户之前未加入该群聊频道,不能退出
	MSG_ERROR_USER_CHANNEL_DID_NOT_JOINED               = {"ME18312", "did not join" },

	---- 创建者不允许退出群聊频道
	MSG_ERROR_USER_CHANNEL_QUIT_SELF                     = {"ME18313", "deny quit" },
	---- 当前用户已被拉黑，不能设置关联键
	MSG_ERROR_USER_IS_BLACK                              = {"ME18314" ,"current user is BLACK"},

	---- 当前频道已经被关闭 2015-05-08 jiang z.s. 
	MSG_ERROR_CURRENT_CHANNEL_IS_CLOSE                 = {"ME18315" ,"current channel is closed"},

	---- 当前服务频道不正确
	MSG_ERROR_CURRENT_CUSTOMTYPE_NOT_EXIT                = {"ME18316" ,"current customType is not exist"},

	---- 当前用户不在此频道中
	MSG_ERROR_CURRENT_USER_NOT_EXIT_SERVERID                = {"ME18317" ,"current user is not exist channel"},
	---- 当前model没有imei		
	MSG_ERROR_MODEL_HAS_NOT_THIS_IMEI                        = { "ME18318", " model has not this imei" },		

	---- model没有设置开机频道		
	MSG_ERROR_MODEL_OR_IMEI_NOT_SET_CONFIG                      = { "ME18319", " this model or imei have not set config " },

	-----------------------------End channel-----------------------------------------------------

	-- reward 众酬[ME18501 ~ ME18800 ] 
	--申请提现金额不能少于10元
	MSG_ERROR_APPLY_WITHDRAW_AMOUNT_LESS_TEN         	 = {"ME18502","this user apply withdraw amount less than ten"},

	--对多组imei号，输出错误号，已废弃
	MSG_SUCCESS_INPUT_IMEI_NOT_EXIT                  	 = {"ME18503","%s imei input not exit!"},    --废弃

	--该用户不存在
	MSG_ERROR_ACCOUNT_ID_EXIST                           ={"ME18504", "this accountID is exist!"},

	--此交易已经完成
	MSG_ERROR_TRADE_HAS_FINISHED                   	 ={"ME18505","this trade has finished"},

	--企业编号不存在
	MSG_ERROR_BUSINESS_ID_NOT_EXIST                	 ={"ME18506","this businessID not exist"},

	--该用户没有密点
	MSG_ERROR_NO_MEPOINTS                          	 ={"ME18507","this account has no mepoints"},

	--该用户没有微点
	MSG_ERROR_NO_WEPOINTS                          	 ={"ME18508","this account has no wepoints"},

	--该用户没有足够的密点(消费金额不够)
	MSG_ERROR_NOT_ENOUGH_MEPOINTS                  	 ={"ME18509","this account has not enough mepoints"},

	--该用户没有足够的微点(消费金额不够)
	MSG_ERROR_NOT_ENOUGH_WEPOINTS                  	 ={"ME18510","this account has not enough wepoints"},

	--查找数据为空
	MSG_ERROR_DATA_NIL	  	   		   	 ={"ME18511","this pageCount is Nil"},

	--用户消费时，密点个微点不能同时为空
	MSG_MEPOINTS_AND_WEPOINTS_CAN_NOT_ALL_EMPTY	   	 ={"ME18512","mePoints and wePoints can not all empty"},

	--没有此项交易
	MSG_ERROR_HAS_NO_TRADE                         	 ={"ME18513","the data has no this tradeNumber "},

	--企业编号已经存在
	MSG_ERROR_BUSINESSID_HAS_EXIT	           	 ={"ME18514","the businessID has exit"},

	--此设备不允许申请退货
	MSG_ERROR_NO_ALLOWED_QUIT_CONTRACT             	 ={"ME18515","This device is not allowed to quit"},

	--用户申请密点不允许少于1000
	MSG_ERROR_APPLY_WITHDRAW_AMOUNT_LESS_THOUSAND 	 ={"ME18516","this user apply withdraw amount less than thousand mePoints"},

	--系统正在清算中
	MSG_ERROR_SYSTEM_IS_UNDER_LIQUIDATION      		 ={"ME18517","The system is under liquidation"},	

	MSG_ERROR_TRADE_NO_APPLY_CANCEL                      ={"ME18518","The trade no apply cancel"},

	MSG_ERROR_TRADE_NO_ALLOW_OPERATE                     ={"ME18519","The trade not allowd opearte"},

	MSG_ERROR_BUSINESS_NAME_EXIST                        ={"ME18520","The businessName is exist"},

	MSG_ERROR_BUSINESS_ACCOUNTID_EXIST                   ={"ME18521","The business accountID is exist"},

	--商家与买家不允许为同一个用户
	MSG_ERROR_INCOME_EXPENSE_NOT_ALLOW_EQUAL            ={"ME18522", "incomeAccountID and expenseAccountID not allow is a user"},

	MSG_ERROR_APPIDENTIYY_IS_ILL                        ={"ME18523", "appIdentity is Illegal"},

	-- 用户资金已经被冻结
	MSG_ERROR_USER_AMOUNT_FROZEN                        ={"ME18524","user amount is frozen!"},

	MSG_ERROR_BUSINESS_GET_APPKEY_FAIL                  ={"ME18525","The business get appkey is failed"},
	---------------------------End reward---------------------------------------------------------

	-- accountapi [ME18801 ~ ME18900 ] 2014-11-17
	--用于预入库api_prestorage.lua中 表示当前状态不允许预入库操作
	MSG_ERROR_CUR_NO_ALLOW_PRESTORGE			       ={"ME18801", "cur IMEI status not allow prestorge"},

	--没有收到开机信息
	MSG_ERROR_NOT_RECEIVE_BOOT_INFO                    ={"ME18802","not receive boot information"},
	--没有接受到GPS信息
	MSG_ERROR_NOT_RECEIVE_GPS_INFO                     ={"ME18803","not receive GPS information"},
	--用于预入库api_prestorage.lua中 表示不允许重复入库
	MSG_ERROR_IMEI_ALREADY_PRESTORGE 			={"ME18804", "cur IMEI has already prestorge!"},
	--用于预入库api_prestorage.lua中 表示没有收到语音文件
	MSG_ERROR_NO_ACCEPT_VOICEFILE			={"ME18805", "No accept voice file!"},
	--用于预入库api_prestorage.lua中 表示语音不正常
	MSG_ERROR_VOICE_IS_ABNORMAL				={"ME18806", "voice is abnormal!"},
	--用于车机设备绑定IMEI中对APPKey和model匹配的校验
	MSG_ERROR_APPKEY_NOT_MATCH                      ={"ME18807","appkey is not match !"},

	---- 账户API error范围 [ ME18901 ~  ME18999 ] 
	--18901错误码用于账户API中
	--用于车机绑定API，表示车机设备deviceID已经绑定了imei
	MSG_ERROR_DEVICE_ID_HAS_BIND                        =  {"ME18901", "deviceID  has binded imei!"},

	MSG_ERROR_ACCOUNT_ID_HAS_BIND                       = {"ME18902","this accountID has bind!"},

	---- MODEL不存在
	MSG_ERROR_DEVICE_MODEL_INVALID                     =  {"ME18903", "model invalid"},

	---- MODEL已经过期
	MSG_ERROR_DEVICE_MODEL_EXPIRE                      =  {"ME18904", "model expire"},

	---- MODELModel下面的IMEI池已经耗尽exhaust
	MSG_ERROR_DEVICE_MODEL_IMEI_EXHAUST               =  {"ME18905", "model imei exhaust"},

	----IMEI无效  可能validity为0,或者不等于13g 2015-04-10
	MSG_ERROR_IMEI_INVALIDITY                          =  {"ME18906", "IMEI is invalidity"},

	---- IMEI 与accountID重复绑定
	MSG_ERROR_DEVICE_REBIND                            =  {"ME18907", "device rebind"},

	---- 账户未绑定IMEI
	MSG_ERROR_ACCOUNTID_NOT_BIND                            =  {"ME18908", "account is not bind"},


	---- 短信发送失败 2015-04-22
	MSG_ERROR_SMS_SEND_FAILED                            =  {"ME18909", "sms send failed"},
	----验证码过期
	MSG_ERROR_VERIFYCODE_EXPIRE                            =  {"ME18910", "verifycode is expire !"},  

	---- 验证码过期(手机用户通过短信重置密码)(2015-05-26)
	MSG_ERROR_VERIFY_CODE_EXPIRED                       =       {"ME18911", "VerifyCode expired!"},
	---- 验证码不匹配(手机用户通过短信重置密码)(2015-05-26)
	MSG_ERROR_VERIFY_CODE_NOT_MATCH                     =       {"ME18912", "VerifyCode isn't match!"},
	---- 验证码已经被使用(手机用户通过短信重置密码)(2015-05-26)
	MSG_ERROR_VERIFY_CODE_USED                          =       {"ME18913", "VerifyCode already used!"},
	---- 还未获得验证码(手机用户通过短信重置密码)(2015-05-26)
	MSG_ERROR_NO_VERIFY_CODE                            =       {"ME18914", "Please get a verifyCode first!"},
	---- 身份证绑定达到上限（更新用户资料,一个身份证最多绑定10个账号)
	MSG_ERROR_IDNUMBER__UPPER_LIMIT                     =       {"ME18915", "The binding of the ID card reaches the upper limit!"},                
	---- 手机已经被注册( 道客账户绑定手机号)(2015-06-08)
	MSG_ERROR_MOBILE_ALREAD_REGISTER                    =    { "ME18916", " mobile already registered !"},
	---- 手机已经被绑定( 道客账户绑定手机号)(2015-06-08)
	MSG_ERROR_MOBILE_ALREAD_BIND                         =    { "ME18917", "mobile already binded" },
	---- 手机号对应的accountID和输入的accountID不匹配
	MSG_ERROR_MOBILE_ACCOUNT_NOT_MATCH              =       { " ME18918 ", " mobile and accountID is not match " },
	---- 手机用户无法解除账号关联
	MSG_ERROR_MOBILE_USER_NOT_RELEASE_CONNECT          =       { " ME18919 ", " Mobile users is not release account connection " },
	---- 手机号没有关联账户
	MSG_ERROR_MOBILE_NOT_CONNECT_ACCOUNT                = { "ME18920", " Mobile number is not connection with account" },
	---- 请输入参数
	MSG_ERROR_NOT_INPUT_PARAMETER                 = { "ME18921", "Please input parameters " },
	---- 手机号已经绑定第三方账号
	MSG_ERROR_IS_THIRD_ACCOUNT                    = {"ME18922", "already bind third account" },
	---- 注销账号失败
	MSG_ERROR_CANCELL_ACCOUNT_FAILED            = {"ME18923", "cancellation account is failed!"},
	---- 用户不是手机用户
	MSG_ERROR_NOT_MOBILE_USER                   = {"ME18924", "this user is not mobile user "},
	---- 修改手机用户密码失败
	MSG_ERROR_MODEFY_PSW_FAILED                 = {"ME18925", "modify password failed"},

	MSG_ERROR_EMAIL_HAS_EXISTS                  = {"ME18926", "this email has used"},
	---- 短信发送次数太多
	MSG_ERROR_TOO_MANY_SEND_SMS                 = {"ME18927", "SMS sending too fast"},
	---- 手机号发送短信超出每日最大限制
	MSG_ERROR_SMS_SEND_BEYOND_LIMIT             = {"ME18928", "SMS sending Beyond the maximum limit"},
	------------- other --------------------------

	----新增范围 [ME240000] 2015_04_08 请各位同学留意
	----OAUTH error         [ME24000 ~ 24199  ]  200 个
	MSG_ERROR_OAUTH_SCOPE_NOT_EXIST               =  {"ME24000", "scope not exist"},
	MSG_ERROR_OAUTH_FREQUENCY_NOT_EXIST           =  {"ME24001", "frequecy type not exist"},
	--没有注册成为开发者
	MSG_ERROR_ACCOUNT_ID_HAS_REGISTEED            =  {"ME24002", "This account has been registered!"},
	--没有审核通过，不能申请第三方应用
	MSG_ERROR_ACCOUNT_ID_IS_NOT_APPROVED          =  {"ME24003", "This account is not approved!"},

	MSG_ERROR_APP_FREQ_RECORD_EXISTED             =  {"ME24004", "This frequecy record already existed!"},
	MSG_ERROR_APP_FREQ_RECORD_NOT_EXISTED         =  {"ME24005", "Frequecy record not exists!"},


	----application error  [ME24200 ~ 24399  ]  200 个
	----mapapi error       [ME24400 ~ 24499  ]  100 个
	----rewardapi error    [ME24500 ~ 24699  ]  200 个
	----dfsapi error       [ME24700 ~ 24799  ]  100 个

	MSG_ERROR_DFSSAVE_FAILED                 ={"ME24700","save file to dfs failed!"},

	----messageapi error        [ME24800 ~ 24899  ]  100 个
	MSG_ERROR_ZMQ_DO_FAILED                 ={"ME24800","zmq do failed!"},
	MSG_ERROR_JSON_ENCODE_FAILED            ={"ME24801","json encode do failed!"},
	MSG_ERROR_SEND_JSON_DATA_TOO_LONG            ={"ME24802","send json data too long"},
	MSG_ERROR_SEND_PARAMETER_IS_ERROR            ={"ME24803","send parameter is error "},
	----imsiapi error        [ME24900 ~ 24999  ]  100 个
	MSG_ERROR_IP_NO_DATA                  ={"ME24900","this ip not find data in database"},
	MSG_ERROR_SET_THRESHOLD_FAILED          ={"ME24901","set threshold value failed"},
	MSG_ERROR_IMSI_NO_IP                    ={"ME24902","this imsi not find  ip in database"},
	MSG_ERROR_QUERY_FLOW_FAILED             ={"ME24903","query sim flow failed!"},
	MSG_ERROR_NO_RIGHT_QUERY_SIM_FLOW       ={"ME24904","the user has no right to query sim flow"},
	MSG_ERROR_USER_HAS_NEVER_USE_SIM        ={"ME24905","the user has never use sim"},
	MSG_ERROR_GET_SERVER_IP_FAILED          ={"ME24906","get server ip failed!"},
	MSG_ERROR_UPDATE_FLOW_THRESHOLD         ={"ME24907","update sim flow threshold failed"},
	----其他 error          [ME25000 ~ 25099  ]  100 个


}

return msg
